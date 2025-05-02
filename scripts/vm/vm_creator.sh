#!/usr/bin/env bash

# ==========================================================
# VM Creator Module - ProxMenux
# ==========================================================
# Este módulo recibe las variables globales y crea la VM
# con su configuración, discos y descripción.
# ==========================================================

BASE_DIR="/usr/local/share/proxmenux"
UTILS_FILE="$BASE_DIR/utils.sh"
VENV_PATH="/opt/googletrans-env"

if [[ -f "$UTILS_FILE" ]]; then
  source "$UTILS_FILE"
fi

load_language
initialize_cache

# ==========================================================
# Función para montar ISOs
# ==========================================================
function mount_iso_to_vm() {
  local vmid="$1"
  local iso_path="$2"
  local device="$3"

  if [[ -f "$iso_path" ]]; then
    local iso_basename
    iso_basename=$(basename "$iso_path")
    qm set "$vmid" -$device "local:iso/$iso_basename,media=cdrom" >/dev/null 2>&1
    msg_ok "$(translate "Mounted ISO on device") $device → $iso_basename"
  else
    msg_warn "$(translate "ISO not found to mount on device") $device"
  fi
}




# ==========================================================
# Select Interface Type
# ==========================================================
function select_interface_type() {
  INTERFACE_TYPE=$(whiptail --backtitle "ProxMenux" --title "$(translate "Select Disk Interface")" --radiolist \
    "$(translate "Select the bus type for the disks:")" 15 70 4 \
    "scsi"    "$(translate "SCSI   (recommended for Linux and Windows)")" ON \
    "sata"    "$(translate "SATA   (standard - high compatibility)")" OFF \
    "virtio"  "$(translate "VirtIO (advanced - high performance)")" OFF \
    "ide"     "IDE    (legacy)" OFF \
    3>&1 1>&2 2>&3) || exit 1

  case "$INTERFACE_TYPE" in
    "scsi"|"sata")
      DISCARD_OPTS=",discard=on,ssd=on"
      ;;
    "virtio")
      DISCARD_OPTS=",discard=on"
      ;;
    "ide")
      DISCARD_OPTS=""
      ;;
  esac

  msg_ok "$(translate "Disk interface selected:") $INTERFACE_TYPE"
}


# ==========================================================
# Función select_efi_storage (no cambia)
# ==========================================================
function select_efi_storage() {
  local vmid=$1
  local STORAGE=""

  STORAGE_MENU=()
  while read -r line; do
    TAG=$(echo "$line" | awk '{print $1}')
    TYPE=$(echo "$line" | awk '{printf "%-10s", $2}')
    FREE=$(echo "$line" | numfmt --field 4-6 --from-unit=K --to=iec --format "%.2f" | awk '{printf("%9sB", $6)}')
    STORAGE_MENU+=("$TAG" "Type: $TYPE Free: $FREE" "OFF")
  done < <(pvesm status -content images | awk 'NR>1')

  if [ ${#STORAGE_MENU[@]} -eq 0 ]; then
    msg_error "$(translate "Unable to detect a valid storage location for EFI disk.")"
    exit 1
  elif [ $((${#STORAGE_MENU[@]} / 3)) -eq 1 ]; then
    STORAGE=${STORAGE_MENU[0]}
  else
    STORAGE=$(whiptail --backtitle "ProxMenux" --title "$(translate "EFI Disk Storage")" --radiolist \
      "$(translate "Choose the storage volume for the EFI disk (4MB):")" 16 70 6 \
      "${STORAGE_MENU[@]}" 3>&1 1>&2 2>&3) || exit 1
  fi

  echo "$STORAGE"
}




# ==========================================================
# Función principal para crear la VM
# ==========================================================
function create_vm() {
  local BOOT_ORDER=""
  local DISK_INFO=""
  local DISK_INDEX=0
  local ISO_DIR="/var/lib/vz/template/iso"


  # Descargar ISO si es necesario
  if [[ -n "$ISO_PATH" && -n "$ISO_URL" && ! -f "$ISO_PATH" ]]; then
    # Detectar si es una URL de SourceForge
    if [[ "$ISO_URL" == *"sourceforge.net"* ]]; then
      # SourceForge necesita --content-disposition para descargar correctamente
      wget --content-disposition --show-progress -O "$ISO_PATH" "$ISO_URL"
    else
      # Normal para el resto
      wget --no-verbose --show-progress -O "$ISO_PATH" "$ISO_URL"
    fi

    # Verificar si se descargó bien
    if [[ -f "$ISO_PATH" ]]; then
      msg_ok "$(translate "ISO image downloaded")"
    else
      msg_error "$(translate "Failed to download ISO image")"
      return
    fi
  fi



  # Crear la VM base primero (mínima)
  qm create "$VMID" -agent 1${MACHINE} -tablet 0 -localtime 1${BIOS_TYPE}${CPU_TYPE} \
    -cores "$CORE_COUNT" -memory "$RAM_SIZE" -name "$HN" -tags proxmenux \
    -net0 "virtio,bridge=$BRG,macaddr=$MAC$VLAN$MTU" -ostype l26 \
    -scsihw virtio-scsi-pci \
    $( [[ -n "$SERIAL_PORT" ]] && echo "-serial0 $SERIAL_PORT" )

  msg_ok "$(translate "Base VM created with ID") $VMID"


  # Crear disco EFI si corresponde
  if [[ "$BIOS_TYPE" == *"ovmf"* ]]; then
    msg_info "$(translate "Configuring EFI disk")"
    EFI_STORAGE=$(select_efi_storage "$VMID")
    EFI_DISK_NAME="vm-${VMID}-disk-efivars"

    STORAGE_TYPE=$(pvesm status -storage "$EFI_STORAGE" | awk 'NR>1 {print $2}')
    case "$STORAGE_TYPE" in
      nfs | dir)
        EFI_DISK_EXT=".raw"
        EFI_DISK_REF="$VMID/"
        ;;
      *)
        EFI_DISK_EXT=""
        EFI_DISK_REF=""
        ;;
    esac

    if pvesm alloc "$EFI_STORAGE" "$VMID" "$EFI_DISK_NAME$EFI_DISK_EXT" 4M >/dev/null 2>&1; then
      if qm set "$VMID" -efidisk0 "$EFI_STORAGE:${EFI_DISK_REF}$EFI_DISK_NAME$EFI_DISK_EXT,pre-enrolled-keys=0" >/dev/null 2>&1; then
        msg_ok "$(translate "EFI disk created and configured on") $EFI_STORAGE"
      else
        msg_error "$(translate "Failed to configure EFI disk")"
      fi
    else
      msg_error "$(translate "Failed to create EFI disk")"
    fi
  fi





  # Añadir TPM si es Windows
  if [[ "$OS_TYPE" == "windows" ]]; then
    msg_info "$(translate "Configuring TPM device")"
    TPM_STORAGE=$(select_efi_storage "$VMID")
    TPM_NAME="vm-${VMID}-tpmstate"

    STORAGE_TYPE=$(pvesm status -storage "$TPM_STORAGE" | awk 'NR>1 {print $2}')
    case "$STORAGE_TYPE" in
      nfs | dir)
        TPM_EXT=".raw"
        TPM_REF="$VMID/"
        ;;
      *)
        TPM_EXT=""
        TPM_REF=""
        ;;
    esac

    if pvesm alloc "$TPM_STORAGE" "$VMID" "$TPM_NAME$TPM_EXT" 4M >/dev/null 2>&1; then
      qm set "$VMID" -tpmstate0 "$TPM_STORAGE:${TPM_REF}${TPM_NAME}${TPM_EXT},version=2.0" >/dev/null 2>&1
      qm set "$VMID" -tpmdev "tpm-tis" >/dev/null 2>&1
      msg_ok "$(translate "TPM device added to VM")"
    else
      msg_warn "$(translate "Failed to add TPM device.")"
    fi
  fi




# ==========================================================
# Crear discos virtuales o físicos con interfaz seleccionada
# ==========================================================

# Primero seleccionar la interfaz
select_interface_type

  if [[ "$DISK_TYPE" == "virtual" && ${#VIRTUAL_DISKS[@]} -gt 0 ]]; then
    for i in "${!VIRTUAL_DISKS[@]}"; do
      DISK_INDEX=$((i+1))
      IFS=':' read -r STORAGE SIZE <<< "${VIRTUAL_DISKS[$i]}"
      DISK_NAME="vm-${VMID}-disk-${DISK_INDEX}"
      SLOT_NAME="${INTERFACE_TYPE}${i}"

      STORAGE_TYPE=$(pvesm status -storage "$STORAGE" | awk 'NR>1 {print $2}')
      case "$STORAGE_TYPE" in
        dir|nfs)
          DISK_EXT=".raw"
          DISK_REF="$VMID/"
          ;;
        *)
          DISK_EXT=""
          DISK_REF=""
          ;;
      esac

      if pvesm alloc "$STORAGE" "$VMID" "$DISK_NAME$DISK_EXT" "$SIZE"G >/dev/null 2>&1; then
        qm set "$VMID" -$SLOT_NAME "$STORAGE:${DISK_REF}${DISK_NAME}${DISK_EXT}${DISCARD_OPTS}" >/dev/null
        msg_ok "$(translate "Virtual disk") $DISK_INDEX ${SIZE}GB - $STORAGE ($SLOT_NAME)"
        DISK_INFO+="<p>Virtual Disk $DISK_INDEX: ${SIZE}GB ($STORAGE / $SLOT_NAME)</p>"
        [[ -z "$BOOT_ORDER" ]] && BOOT_ORDER="$SLOT_NAME"
      else
        msg_error "$(translate "Failed to create disk") $DISK_INDEX"
      fi
    done
  fi

  if [[ "$DISK_TYPE" == "passthrough" && ${#PASSTHROUGH_DISKS[@]} -gt 0 ]]; then
    for i in "${!PASSTHROUGH_DISKS[@]}"; do
      SLOT_NAME="${INTERFACE_TYPE}${i}"
      DISK="${PASSTHROUGH_DISKS[$i]}"
      MODEL=$(lsblk -ndo MODEL "$DISK")
      SIZE=$(lsblk -ndo SIZE "$DISK")
      qm set "$VMID" -$SLOT_NAME "$DISK${DISCARD_OPTS}" >/dev/null 2>&1
      msg_ok "$(translate "Passthrough disk assigned") ($DISK → $SLOT_NAME)"
      DISK_INFO+="<p>Passthrough Disk $((i+1)): $DISK ($MODEL $SIZE)</p>"
      [[ -z "$BOOT_ORDER" ]] && BOOT_ORDER="$SLOT_NAME"
    done
  fi




  # Ahora montamos las ISOs
  if [[ -f "$ISO_PATH" ]]; then
    mount_iso_to_vm "$VMID" "$ISO_PATH" "ide2"
  fi

  # Para Windows, preguntar y montar ISO VirtIO
  if [[ "$OS_TYPE" == "windows" ]]; then
    local VIRTIO_DIR="/var/lib/vz/template/iso"
    local VIRTIO_SELECTED=""
    local VIRTIO_DOWNLOAD_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso"

    while true; do
      VIRTIO_OPTION=$(whiptail --title "ProxMenux - VirtIO Drivers" --menu "$(translate "Select how to provide VirtIO drivers")" 15 70 2 \
        "1" "$(translate "Download latest VirtIO ISO automatically")" \
        "2" "$(translate "Use existing VirtIO ISO from storage")" 3>&1 1>&2 2>&3)

      [[ $? -ne 0 ]] && msg_warn "$(translate "VirtIO ISO selection cancelled.")" && break

      case "$VIRTIO_OPTION" in
        1)

          if [[ -f "$VIRTIO_DIR/virtio-win.iso" ]]; then
            if whiptail --title "ProxMenux" --yesno "$(translate "A VirtIO ISO already exists. Do you want to overwrite it?")" 10 60; then
              wget -q --show-progress -O "$VIRTIO_DIR/virtio-win.iso" "$VIRTIO_DOWNLOAD_URL"
              if [[ -f "$VIRTIO_DIR/virtio-win.iso" ]]; then
                msg_ok "$(translate "VirtIO driver ISO downloaded successfully.")"
              else
                msg_error "$(translate "Failed to download VirtIO driver ISO.")"
              fi
            fi
          else
            wget -q --show-progress -O "$VIRTIO_DIR/virtio-win.iso" "$VIRTIO_DOWNLOAD_URL"
            if [[ -f "$VIRTIO_DIR/virtio-win.iso" ]]; then
              msg_ok "$(translate "VirtIO driver ISO downloaded successfully.")"
            else
              msg_error "$(translate "Failed to download VirtIO driver ISO.")"
            fi
          fi

          VIRTIO_SELECTED="$VIRTIO_DIR/virtio-win.iso"
          ;;
        2)

          VIRTIO_LIST=()
          while read -r line; do
            FILENAME=$(basename "$line")
            SIZE=$(du -h "$line" | cut -f1)
            VIRTIO_LIST+=("$FILENAME" "$SIZE")
          done < <(find "$VIRTIO_DIR" -type f -iname "virtio*.iso" | sort)

          if [[ ${#VIRTIO_LIST[@]} -eq 0 ]]; then
            msg_warn "$(translate "No VirtIO ISO found. Please download one.")"
            continue  # Volver a preguntar
          fi

          VIRTIO_FILE=$(whiptail --title "ProxMenux - VirtIO ISOs" --menu "$(translate "Select a VirtIO ISO to use:")" 20 70 10 "${VIRTIO_LIST[@]}" 3>&1 1>&2 2>&3)

          if [[ -n "$VIRTIO_FILE" ]]; then
            VIRTIO_SELECTED="$VIRTIO_DIR/$VIRTIO_FILE"
          else
            msg_warn "$(translate "No VirtIO ISO selected. Please choose again.")"
            continue
          fi
          ;;
      esac

      if [[ -n "$VIRTIO_SELECTED" && -f "$VIRTIO_SELECTED" ]]; then
        mount_iso_to_vm "$VMID" "$VIRTIO_SELECTED" "ide3"
      else
        msg_warn "$(translate "VirtIO ISO not found after selection.")"
      fi

      break
    done
  fi


  # Configurar el orden de arranque (primer disco, luego CD)
  local BOOT_FINAL="$BOOT_ORDER"
  [[ -f "$ISO_PATH" ]] && BOOT_FINAL="$BOOT_ORDER;ide2"
  qm set "$VMID" -boot order="$BOOT_FINAL" >/dev/null
  msg_ok "$(translate "Boot order set to") $BOOT_FINAL"

  # Crear descripción
  local DESC="<div align='center'><h1>$HN</h1><p>Created with ProxMenux</p>$DISK_INFO</div>"
  qm set "$VMID" -description "$DESC" >/dev/null
  msg_ok "$(translate "VM description configured")"

  # Arrancar la VM si corresponde
  if [[ "$START_VM" == "yes" ]]; then
    qm start "$VMID"
    msg_ok "$(translate "VM started")"
  fi
  configure_guest_agent
  msg_success "$(translate "VM creation completed")"
}



