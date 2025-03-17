#!/usr/bin/env bash

# ==========================================================
# Synology VM Creator for ProxMenuX version TEST
# ==========================================================
# Author      : MacRimi
# Copyright   : (c) 2024 MacRimi
# License     : MIT (https://raw.githubusercontent.com/MacRimi/ProxMenux/main/LICENSE)
# Version     : 1.0
# Last Updated: 13/03/2025
# ==========================================================
# This script creates a Synology DSM virtual machine in Proxmox
# ==========================================================

# Configuration
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
UTILS_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main/scripts/utils.sh"


# Source utils.sh for common functions and styles
if ! source <(curl -sSf "$UTILS_URL"); then
    echo "Error: Could not load utils.sh from $UTILS_URL"
    exit 1
fi
# ==========================================================

GEN_MAC="02"
for i in {1..5}; do
  BYTE=$(printf "%02X" $((RANDOM % 256)))
  GEN_MAC="${GEN_MAC}:${BYTE}"
done

NEXTID=$(pvesh get /cluster/nextid 2>/dev/null || echo "100")
NAME="Synology VM"
IMAGES_DIR="/var/lib/vz/template/iso"
ERROR_FLAG=false





function exit_script() {
  clear
      if whiptail --backtitle "ProxMenuX" --title "$NAME" --yesno "This will create a New $NAME. Proceed?" 10 58; then
        start_script
      else
        clear
        exit
      fi
}


# Definir función header_info al inicio del script

function header_info() {
  clear
  show_proxmenux_logo
  echo -e "${BL}╔═══════════════════════════════════════════════╗${CL}"
  echo -e "${BL}║                                               ║${CL}"
  echo -e "${BL}║${YWB}              Synology VM Creator              ${BL}║${CL}"
  echo -e "${BL}║                                               ║${CL}"
  echo -e "${BL}╚═══════════════════════════════════════════════╝${CL}"
  echo -e
}
# ==========================================================






# ==========================================================
# start Script
# ==========================================================
function start_script() {
  if (whiptail --backtitle "ProxMenuX" --title "SETTINGS" --yesno "Use Default Settings?" --no-button Advanced 10 58); then
    header_info
    echo -e "${DEF}Using Default Settings${CL}"
    default_settings
  else
    header_info
    echo -e "${CUS}Using Advanced Settings${CL}"
    advanced_settings
  fi
}
# ==========================================================




# ==========================================================
# Default Settings
# ==========================================================
function default_settings() {
  VMID="$NEXTID"
  FORMAT=""
  MACHINE=" -machine q35"
  BIOS_TYPE=" -bios ovmf"
  DISK_CACHE=""
  HN="Synology-DSM"
  CPU_TYPE=" -cpu host"
  CORE_COUNT="2"
  RAM_SIZE="4096"
  BRG="vmbr0"
  MAC="$GEN_MAC"
  VLAN=""
  MTU=""
  SERIAL_PORT="socket"
  START_VM="no"
  
  echo -e "${DGN}Using Virtual Machine ID: ${BGN}${VMID}${CL}"
  echo -e "${DGN}Using Machine Type: ${BGN}q35${CL}"
  echo -e "${DGN}Using BIOS Type: ${BGN}OVMF (UEFI)${CL}"
  echo -e "${DGN}Using Hostname: ${BGN}${HN}${CL}"
  echo -e "${DGN}Using CPU Model: ${BGN}Host${CL}"
  echo -e "${DGN}Allocated Cores: ${BGN}${CORE_COUNT}${CL}"
  echo -e "${DGN}Allocated RAM: ${BGN}${RAM_SIZE}${CL}"
  echo -e "${DGN}Using Bridge: ${BGN}${BRG}${CL}"
  echo -e "${DGN}Using MAC Address: ${BGN}${MAC}${CL}"
  echo -e "${DGN}Using VLAN: ${BGN}Default${CL}"
  echo -e "${DGN}Using Interface MTU Size: ${BGN}Default${CL}"
  echo -e "${DGN}Configuring Serial Port: ${BGN}${SERIAL_PORT}${CL}"
  echo -e "${DGN}Start VM when completed: ${BGN}${START_VM}${CL}"
  echo -e
  echo -e "${DEF}Creating a $NAME using the above default settings${CL}"
 
  sleep 1
  select_disk_type
}
# ==========================================================





# ==========================================================
# advanced Settings
# ==========================================================
function advanced_settings() {
  # VM ID Selection
  while true; do
    if VMID=$(whiptail --backtitle "ProxMenuX" --inputbox "Set Virtual Machine ID" 8 58 $NEXTID --title "VIRTUAL MACHINE ID" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
      if [ -z "$VMID" ]; then
        VMID="$NEXTID"
      fi
      if pct status "$VMID" &>/dev/null || qm status "$VMID" &>/dev/null; then
        echo -e "${CROSS}${RD} ID $VMID is already in use${CL}"
        sleep 1
        continue
      fi
      echo -e "${DGN}Virtual Machine ID: ${BGN}$VMID${CL}"
      break
    else
      exit_script
    fi
  done

  # Machine Type Selection
  if MACH=$(whiptail --backtitle "ProxMenuX" --title "MACHINE TYPE" --radiolist --cancel-button Exit-Script "Choose Type" 10 58 2 \
    "q35" "Machine q35" ON \
    "i440fx" "Machine i440fx" OFF \
    3>&1 1>&2 2>&3); then
    if [ $MACH = q35 ]; then
      echo -e "${DGN}Using Machine Type: ${BGN}$MACH${CL}"
      FORMAT=""
      MACHINE=" -machine q35"
    else
      echo -e "${DGN}Using Machine Type: ${BGN}$MACH${CL}"
      FORMAT=",efitype=4m"
      MACHINE=""
    fi
  else
    exit_script
  fi

    # BIOS Type Selection 
  if BIOS=$(whiptail --backtitle "ProxMenuX" --title "BIOS TYPE" --radiolist --cancel-button Exit-Script "Choose BIOS Type" 10 58 2 \
    "ovmf" "UEFI (OVMF)" ON \
    "seabios" "SeaBIOS (Legacy)" OFF \
    3>&1 1>&2 2>&3); then
    if [ "$BIOS" = "seabios" ]; then
        echo -e "${DGN}Using BIOS Type: ${BGN}SeaBIOS${CL}"
        BIOS_TYPE=" -bios seabios"
    else
        echo -e "${DGN}Using BIOS Type: ${BGN}OVMF (UEFI)${CL}"
        BIOS_TYPE=" -bios ovmf"
    fi
  else
    exit_script
   fi

  # Hostname Selection
  if VM_NAME=$(whiptail --backtitle "ProxMenuX" --inputbox "Set Hostname" 8 58 Synology-DSM --title "HOSTNAME" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
    if [ -z $VM_NAME ]; then
      HN="Synology-DSM"
      echo -e "${DGN}Using Hostname: ${BGN}$HN${CL}"
    else
      HN=$(echo ${VM_NAME,,} | tr -d ' ')
      echo -e "${DGN}Using Hostname: ${BGN}$HN${CL}"
    fi
  else
    exit_script
  fi

  # CPU Type Selection 
  if CPU_TYPE1=$(whiptail --backtitle "ProxMenuX" --title "CPU MODEL" --radiolist "Choose" --cancel-button Exit-Script 10 58 2 \
    "1" "Host" ON \
    "0" "KVM64" OFF \
    3>&1 1>&2 2>&3); then
    if [ $CPU_TYPE1 = "1" ]; then
      echo -e "${DGN}Using CPU Model: ${BGN}Host${CL}"
      CPU_TYPE=" -cpu host"
    else
      echo -e "${DGN}Using CPU Model: ${BGN}KVM64${CL}"
      CPU_TYPE=""
    fi
  else
    exit_script
  fi

  # Core Count Selection
  if CORE_COUNT=$(whiptail --backtitle "ProxMenuX" --inputbox "Allocate CPU Cores" 8 58 2 --title "CORE COUNT" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
    if [ -z $CORE_COUNT ]; then
      CORE_COUNT="2"
      echo -e "${DGN}Allocated Cores: ${BGN}$CORE_COUNT${CL}"
    else
      echo -e "${DGN}Allocated Cores: ${BGN}$CORE_COUNT${CL}"
    fi
  else
    exit_script
  fi

  # RAM Size Selection
  if RAM_SIZE=$(whiptail --backtitle "ProxMenuX" --inputbox "Allocate RAM in MiB" 8 58 4096 --title "RAM" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
    if [ -z $RAM_SIZE ]; then
      RAM_SIZE="4096"
      echo -e "${DGN}Allocated RAM: ${BGN}$RAM_SIZE${CL}"
    else
      echo -e "${DGN}Allocated RAM: ${BGN}$RAM_SIZE${CL}"
    fi
  else
    exit_script
  fi

  # Bridge Selection
  if BRG=$(whiptail --backtitle "ProxMenuX" --inputbox "Set a Bridge" 8 58 vmbr0 --title "BRIDGE" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
    if [ -z $BRG ]; then
      BRG="vmbr0"
      echo -e "${DGN}Using Bridge: ${BGN}$BRG${CL}"
    else
      echo -e "${DGN}Using Bridge: ${BGN}$BRG${CL}"
    fi
  else
    exit_script
  fi

  # MAC Address Selection
  if MAC1=$(whiptail --backtitle "ProxMenuX" --inputbox "Set a MAC Address" 8 58 $GEN_MAC --title "MAC ADDRESS" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
    if [ -z $MAC1 ]; then
      MAC="$GEN_MAC"
      echo -e "${DGN}Using MAC Address: ${BGN}$MAC${CL}"
    else
      MAC="$MAC1"
      echo -e "${DGN}Using MAC Address: ${BGN}$MAC1${CL}"
    fi
  else
    exit_script
  fi

  # VLAN Selection
  if VLAN1=$(whiptail --backtitle "ProxMenuX" --inputbox "Set a Vlan(leave blank for default)" 8 58 --title "VLAN" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
    if [ -z $VLAN1 ]; then
      VLAN1="Default"
      VLAN=""
      echo -e "${DGN}Using Vlan: ${BGN}$VLAN1${CL}"
    else
      VLAN=",tag=$VLAN1"
      echo -e "${DGN}Using Vlan: ${BGN}$VLAN1${CL}"
    fi
  else
    exit_script
  fi

  # MTU Selection
  if MTU1=$(whiptail --backtitle "ProxMenuX" --inputbox "Set Interface MTU Size (leave blank for default)" 8 58 --title "MTU SIZE" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
    if [ -z $MTU1 ]; then
      MTU1="Default"
      MTU=""
      echo -e "${DGN}Using Interface MTU Size: ${BGN}$MTU1${CL}"
    else
      MTU=",mtu=$MTU1"
      echo -e "${DGN}Using Interface MTU Size: ${BGN}$MTU1${CL}"
    fi
  else
    exit_script
  fi



  # Confirmation
  if (whiptail --backtitle "ProxMenuX" --title "ADVANCED SETTINGS COMPLETE" --yesno "Ready to create a $NAME?" --no-button Do-Over 10 58); then
    echo -e
    echo -e "${CUS}Creating a $NAME using the above advanced settings${CL}"

    # Ahora preguntamos por el tipo de disco
    sleep 1
    select_disk_type
  else
   header_info
   sleep 1
   echo -e "${CUS}Using Advanced Settings${CL}"
   advanced_settings
  fi
}
# ==========================================================





# ==========================================================
# Select Disk
# ==========================================================
function select_disk_type() {

  DISK_TYPE=$(whiptail --backtitle "ProxMenuX" --title "DISK TYPE" --menu "Choose disk type:" 12 58 2 \
    "virtual" "Create virtual disk" \
    "passthrough" "Use physical disk passthrough" \
    --ok-button "Select" --cancel-button "Cancel" 3>&1 1>&2 2>&3)

  EXIT_STATUS=$?

  if [[ $EXIT_STATUS -ne 0 ]]; then
      clear
      header_info
      msg_error "Operation cancelled by user. Returning to start scrip..."
      sleep 2
      if whiptail --backtitle "ProxMenuX" --title "$NAME" --yesno "This will create a New $NAME. Proceed?" 10 58; then
        start_script
      else
        clear
        exit
      fi
  fi

  if [[ "$DISK_TYPE" == "virtual" ]]; then
      select_virtual_disk
  else
      select_passthrough_disk
  fi
}

# ==========================================================





# ==========================================================
# Select Virtual Disks
# ==========================================================
function select_virtual_disk() {


  # Inicializar variables
  VIRTUAL_DISKS=()      

  # Bucle para añadir múltiples discos
  local add_more_disks=true
  while $add_more_disks; do

  msg_info "Detecting available storage volumes..."

    # Obtener lista de almacenamiento disponible
    STORAGE_MENU=()
    while read -r line; do
      TAG=$(echo $line | awk '{print $1}')
      TYPE=$(echo $line | awk '{print $2}')
      FREE=$(echo $line | numfmt --field 4-6 --from-unit=K --to=iec --format "%.2f" | awk '{printf( "%9sB", $6)}')
      ITEM=$(printf "%-15s %-10s %-15s" "$TAG" "$TYPE" "$FREE")
      STORAGE_MENU+=("$TAG" "$ITEM" "OFF")
    done < <(pvesm status -content images | awk 'NR>1')

    # Comprobar que hay almacenamiento disponible
    VALID=$(pvesm status -content images | awk 'NR>1')
    if [ -z "$VALID" ]; then
      msg_error "Unable to detect a valid storage location."
      sleep 2
      select_disk_type
    fi

    
    # Seleccionar almacenamiento
    if [ $((${#STORAGE_MENU[@]} / 3)) -eq 1 ]; then
      STORAGE=${STORAGE_MENU[0]}
      msg_ok "Using ${CL}${BL}$STORAGE${CL} ${GN}for Storage Location."
    else

      kill $SPINNER_PID > /dev/null
      STORAGE=$(whiptail --backtitle "ProxMenuX" --title "Select Storage Volume" --radiolist \
        "Choose the storage volume for the virtual disk:\n" 20 78 10 \
        "${STORAGE_MENU[@]}" 3>&1 1>&2 2>&3)
      
      if [ $? -ne 0 ] || [ -z "$STORAGE" ]; then
        if [ ${#VIRTUAL_DISKS[@]} -eq 0 ]; then
          msg_error "No storage selected. At least one disk is required."
          select_disk_type
        else
          # Si ya hay discos añadidos, continuar con el script
          add_more_disks=false
          continue
        fi
      fi
      

    fi

    # Solicitar tamaño del disco
    DISK_SIZE=$(whiptail --backtitle "ProxMenuX" --inputbox "System Disk Size (GB)" 8 58 32 --title "VIRTUAL DISK" --cancel-button Cancel 3>&1 1>&2 2>&3)
    
    if [ $? -ne 0 ]; then
      if [ ${#VIRTUAL_DISKS[@]} -eq 0 ]; then
        msg_error "Disk size not specified. At least one disk is required."
        sleep 2
        select_disk_type
        
      else
        # Si ya hay discos añadidos, continuar con el script
        add_more_disks=false
        continue
      fi
    fi
    
    if [ -z "$DISK_SIZE" ]; then
      DISK_SIZE="32"
    fi

    # Almacenar la configuración en la lista de discos
    VIRTUAL_DISKS+=("${STORAGE}:${DISK_SIZE}")


    # Preguntar si desea crear otro disco
    if ! whiptail --backtitle "ProxMenuX" --title "Add Another Disk" \
      --yesno "Do you want to add another virtual disk?" 8 58; then
      add_more_disks=false
    fi
  done

  # Mostrar resumen de los discos creados
  if [ ${#VIRTUAL_DISKS[@]} -gt 0 ]; then

    msg_ok "Virtual Disks Created:"
    for i in "${!VIRTUAL_DISKS[@]}"; do
      echo -e "${TAB}${BL}- Disk $((i+1)): ${VIRTUAL_DISKS[$i]}GB${CL}"
    done
  fi


  export VIRTUAL_DISKS


  select_loader
}

# ==========================================================






# ==========================================================
# Select Physical Disks
# ==========================================================
function select_passthrough_disk() {


  FREE_DISKS=()

  # Obtener la lista de discos montados
  USED_DISKS=$(lsblk -n -o PKNAME,TYPE | grep 'lvm' | awk '{print "/dev/" $1}')
  MOUNTED_DISKS=$(mount | grep -o '/dev/[a-z]*' | sort | uniq)
  
  # Obtener todos los discos físicos
  while read -r DISK; do

    if ! echo "$USED_DISKS" | grep -q "$DISK" && ! echo "$MOUNTED_DISKS" | grep -q "$DISK"; then

      MODEL=$(lsblk -dn -o MODEL "$DISK" | xargs)
      SIZE=$(lsblk -dn -o SIZE "$DISK" | xargs)
      DESCRIPTION=$(printf "%-40s %10s" "$MODEL" "$SIZE")
      FREE_DISKS+=("$DISK" "$DESCRIPTION" "OFF")
    fi
  done < <(lsblk -dn -e 7,11 -o PATH)


  # Handle no available disks
  if [ "${#FREE_DISKS[@]}" -eq 0 ]; then
    whiptail --title "Error" --msgbox "No disks available for this VM." 8 40
    select_disk_type
  fi

  # Calculate maximum content length
  MAX_WIDTH=$(printf "%s\n" "${FREE_DISKS[@]}" | awk '{print length}' | sort -nr | head -n1)
  TOTAL_WIDTH=$((MAX_WIDTH + 20)) # Add additional margin

  # Set a reasonable minimum width
  if [ $TOTAL_WIDTH -lt 70 ]; then
    TOTAL_WIDTH=70
  fi

  # Display menu to select multiple free disks with dynamically calculated width
  SELECTED_DISKS=$(whiptail --title "Select Disks" --checklist \
    "Select the disks you want to use (use spacebar to select):" 20 $TOTAL_WIDTH 10 \
    "${FREE_DISKS[@]}" 3>&1 1>&2 2>&3)

  # Check if at least one disk was selected
  if [ -z "$SELECTED_DISKS" ]; then
        msg_error "Disk not specified. At least one disk is required."
        sleep 2
        select_disk_type
  fi

  # Process selected disks
  msg_ok "Disk passthrough selected:"
  PASSTHROUGH_DISKS=()
  for DISK in $(echo "$SELECTED_DISKS" | tr -d '"'); do
    DISK_INFO=$(lsblk -ndo MODEL,SIZE "$DISK" | xargs)
    echo -e "${TAB}${CL}${BL}- $DISK $DISK_INFO${GN}${CL}"
    PASSTHROUGH_DISKS+=("$DISK")
  done

  
  select_loader
}
# ==========================================================






# ==========================================================
# Select Loader
# ==========================================================
function select_loader() {
  # Ensure the images directory exists
  if [ ! -d "$IMAGES_DIR" ]; then
    msg_info "Creating images directory"
    mkdir -p "$IMAGES_DIR"
    chmod 755 "$IMAGES_DIR"
    msg_ok "Images directory created: $IMAGES_DIR"
  fi

  # Create the loader selection menu
  LOADER_OPTION=$(whiptail --backtitle "ProxMenuX" --title "SELECT LOADER" --menu "Choose a loader for Synology DSM:" 15 70 4 \
    "1" "AuxXxilium Arc Loader" \
    "2" "RedPill Loader (RROrg - rr)" \
    "3" "TinyCore RedPill Loader (PeterSuh-Q3 M-shell)" \
    "4" "Custom Loader Image (from $IMAGES_DIR)" \
    3>&1 1>&2 2>&3)

  if [ -z "$LOADER_OPTION" ]; then
    exit_script
  fi

  case $LOADER_OPTION in
    1)
      LOADER_TYPE="arc"
      LOADER_NAME="AuxXxilium Arc"
      LOADER_URL="https://github.com/AuxXxilium/arc/releases/latest"
      echo -e "${DGN}${TAB}Selected Loader: ${BGN}$LOADER_NAME${CL}"
      download_loader
      ;;
    2)
      LOADER_TYPE="redpill"
      LOADER_NAME="RedPill rr"
      LOADER_URL="https://github.com/RROrg/rr/releases/latest"
      echo -e "${DGN}${TAB}Selected Loader: ${BGN}$LOADER_NAME${CL}"
      download_loader
      ;;
    3)
      LOADER_TYPE="tinycore"
      LOADER_NAME="TinyCore RedPill M-shell"
      LOADER_URL="https://github.com/PeterSuh-Q3/tinycore-redpill/releases/latest"
      echo -e "${DGN}${TAB}Selected Loader: ${BGN}$LOADER_NAME${CL}"
      download_loader
      ;;
    4)
      LOADER_TYPE="custom"
      LOADER_NAME="Custom Image"
      echo -e "${DGN}${TAB}Selected Loader: ${BGN}$LOADER_NAME${CL}"
      select_custom_image
      ;;
  esac
}

function select_custom_image() {
  # Check if there are any images in the directory
  IMAGES=$(find "$IMAGES_DIR" -type f -name "*.img" -o -name "*.iso" -o -name "*.qcow2" -o -name "*.vmdk" | sort)
  
  if [ -z "$IMAGES" ]; then
    whiptail --title "No Images Found" --msgbox "No compatible images found in $IMAGES_DIR\n\nSupported formats: .img, .iso, .qcow2, .vmdk\n\nPlease add some images and try again." 15 70
    select_loader
  fi
  
  # Create an array of image options for whiptail
  IMAGE_OPTIONS=()

  while read -r img; do
    filename=$(basename "$img")
    filesize=$(du -h "$img" | cut -f1)
    IMAGE_OPTIONS+=("$img" "$filesize")
  done <<< "$IMAGES"
  
  # Let the user select an image
  LOADER_FILE=$(whiptail --backtitle "ProxMenuX" --title "SELECT CUSTOM IMAGE" --menu "Choose a custom image:" 20 70 10 "${IMAGE_OPTIONS[@]}" 3>&1 1>&2 2>&3)
  
  if [ -z "$LOADER_FILE" ]; then
    msg_error "No custom image selected"
    exit_script
  fi
  
  echo -e "${DGN}${TAB}Using Custom Image: ${BGN}$(basename "$LOADER_FILE")${CL}"
  FILE=$(basename "$LOADER_FILE")
}
# ==========================================================







# ==========================================================
# Download Loader
# ==========================================================
function download_loader() {

  echo -e "${DGN}${TAB}Retrieving the URL for the ${BGN}$LOADER_NAME loader${CL}"
  
  case $LOADER_TYPE in
    arc)
      curl -s https://api.github.com/repos/AuxXxilium/arc/releases/latest \
      | grep "browser_download_url.*evo.img.zip" \
      | cut -d '"' -f 4 \
      | xargs  wget -q --show-progress -O "$IMAGES_DIR/evo.img.zip"
      
      if [ -f "$IMAGES_DIR/evo.img.zip" ]; then
        cd "$IMAGES_DIR"
        unzip -q evo.img.zip
        rm evo.img.zip
        FILE="arc.img"
        LOADER_FILE="$IMAGES_DIR/$FILE"
        cd - > /dev/null
      else
        msg_error "Failed to download $LOADER_NAME loader"
        sleep 1
        select_loader
      fi
      ;;
      
    redpill)
      curl -s https://api.github.com/repos/RROrg/rr/releases/latest \
      | grep "browser_download_url.*\.img\.zip" \
      | cut -d '"' -f 4 \
      | xargs wget -q --show-progress -O "$IMAGES_DIR/rr.img.zip"

      if [ -f "$IMAGES_DIR/rr.img.zip" ]; then
          cd "$IMAGES_DIR"
          msg_info "Unzipping $LOADER_NAME loader. Please wait..."
          unzip -qo rr.img.zip
          msg_ok "Unzipped $LOADER_NAME loader successfully."
          rm -f rr.img.zip
          FILE="rr.img"
          LOADER_FILE="$IMAGES_DIR/$FILE"
          cd - > /dev/null
      fi

      ;;
      
    tinycore)
      curl -s https://api.github.com/repos/PeterSuh-Q3/tinycore-redpill/releases/latest \
      | grep "browser_download_url.*tinycore-redpill.v.*img.gz" \
      | cut -d '"' -f 4 \
      | xargs wget -q --show-progress -O "$IMAGES_DIR/tinycore.img.gz"
      
      if [ -f "$IMAGES_DIR/tinycore.img.gz" ]; then
        cd "$IMAGES_DIR"

        msg_info "Unzipping $LOADER_NAME loader. Please wait..."
        gunzip -f tinycore.img.gz 2> /dev/null
        msg_ok "Unzipped $LOADER_NAME loader successfully."
        FILE="tinycore.img"
        LOADER_FILE="$IMAGES_DIR/$FILE"
        cd - > /dev/null

      else
        msg_error "Failed to download $LOADER_NAME loader"
        sleep 1
        select_loader
        
      fi
      ;;
  esac
  
  msg_ok "Downloaded ${CL}${BL}${FILE}${CL} to ${IMAGES_DIR}"
}
# =======================================================





# ==========================================================
# Select UEFI Storage 
# ==========================================================
function select_efi_storage() {
  local vmid=$1
  local STORAGE=""

  STORAGE_MENU=()

  while read -r line; do
    TAG=$(echo $line | awk '{print $1}')
    TYPE=$(echo $line | awk '{printf "%-10s", $2}')
    FREE=$(echo $line | numfmt --field 4-6 --from-unit=K --to=iec --format "%.2f" | awk '{printf( "%9sB", $6)}')
    
    # Crear la línea del menú
    ITEM="  Type: $TYPE Free: $FREE"
    OFFSET=2
    if [[ $((${#ITEM} + $OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
      MSG_MAX_LENGTH=$((${#ITEM} + $OFFSET))
    fi

    STORAGE_MENU+=("$TAG" "$ITEM" "OFF")
  done < <(pvesm status -content images | awk 'NR>1')

  VALID=$(pvesm status -content images | awk 'NR>1')
  if [ -z "$VALID" ]; then
    msg_error "Unable to detect a valid storage location for EFI disk."

  elif [ $((${#STORAGE_MENU[@]} / 3)) -eq 1 ]; then
    # Si hay solo una opción, usarla directamente
    STORAGE=${STORAGE_MENU[0]}

  else
    # Mostrar menú radiolist para seleccionar el volumen
    kill $SPINNER_PID > /dev/null
    while [ -z "${STORAGE:+x}" ]; do
      STORAGE=$(whiptail --backtitle "ProxMenuX" --title "EFI Disk Storage" --radiolist \
        "Choose the storage volume for the EFI disk (4MB):\n\nUse Spacebar to select." \
        16 $(($MSG_MAX_LENGTH + 23)) 6 \
        "${STORAGE_MENU[@]}" 3>&1 1>&2 2>&3) || exit 

    done

  fi
  
  echo "$STORAGE"
}
# ==========================================================





# ==========================================================
# Select Storage Loader 
# ==========================================================
function select_storage_volume() {
  local vmid=$1
  local purpose=$2
  local STORAGE=""

  STORAGE_MENU=()

  while read -r line; do
    TAG=$(echo $line | awk '{print $1}')
    TYPE=$(echo $line | awk '{printf "%-10s", $2}')
    FREE=$(echo $line | numfmt --field 4-6 --from-unit=K --to=iec --format "%.2f" | awk '{printf( "%9sB", $6)}')
    
    # Crear la línea del menú
    ITEM="  Type: $TYPE Free: $FREE"
    OFFSET=2
    if [[ $((${#ITEM} + $OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
      MSG_MAX_LENGTH=$((${#ITEM} + $OFFSET))
    fi

    STORAGE_MENU+=("$TAG" "$ITEM" "OFF")
  done < <(pvesm status -content images | awk 'NR>1')

  VALID=$(pvesm status -content images | awk 'NR>1')
  if [ -z "$VALID" ]; then
    msg_error "Unable to detect a valid storage location."
    exit 1
  elif [ $((${#STORAGE_MENU[@]} / 3)) -eq 1 ]; then
    # Si hay solo una opción, usarla directamente
    STORAGE=${STORAGE_MENU[0]}
  else
    # Mostrar menú radiolist para seleccionar el volumen
    while [ -z "${STORAGE:+x}" ]; do
      STORAGE=$(whiptail --backtitle "ProxMenuX" --title "Storage Pools" --radiolist \
        "Choose the storage volume for $purpose:\n\nUse Spacebar to select." \
        16 $(($MSG_MAX_LENGTH + 23)) 6 \
        "${STORAGE_MENU[@]}" 3>&1 1>&2 2>&3) || exit
    done
  fi
  
  echo "$STORAGE"
}






# ==========================================================
# Create VM
# ==========================================================
function create_vm() {

  # Create the VM
  qm create $VMID -agent 1${MACHINE} -tablet 0 -localtime 1${BIOS_TYPE}${CPU_TYPE} -cores $CORE_COUNT -memory $RAM_SIZE \
    -name $HN -tags proxmenux -net0 virtio,bridge=$BRG,macaddr=$MAC$VLAN$MTU -onboot 1 -ostype l26 -scsihw virtio-scsi-pci \
    -serial0 socket
  msg_ok "Create a $NAME"


 
# Verificar si se está usando UEFI (OVMF) ===================
  if [[ "$BIOS_TYPE" == *"ovmf"* ]]; then

    msg_info "Configuring EFI disk"
    EFI_STORAGE=$(select_efi_storage $VMID)
    EFI_DISK_NAME="vm-${VMID}-disk-efivars"
    
    # Determinar tipo de almacenamiento y extensión
    STORAGE_TYPE=$(pvesm status -storage $EFI_STORAGE | awk 'NR>1 {print $2}')
    case $STORAGE_TYPE in
      nfs | dir)
        EFI_DISK_EXT=".raw"
        EFI_DISK_REF="$VMID/"
        ;;
      *)
        EFI_DISK_EXT=""
        EFI_DISK_REF=""
        ;;
    esac
    
    # Crear disco EFI
    if pvesm alloc "$EFI_STORAGE" "$VMID" "$EFI_DISK_NAME$EFI_DISK_EXT" 4M >/dev/null 2>&1; then
        # Configurar disco EFI sin preinstalar llaves
        if qm set "$VMID" -efidisk0 "$EFI_STORAGE:${EFI_DISK_REF}$EFI_DISK_NAME$EFI_DISK_EXT,pre-enrolled-keys=0" >/dev/null 2>&1; then
            msg_ok "EFI disk created and configured on ${CL}${BL}$EFI_STORAGE${GN}${CL}"
        else
            msg_error "Failed to configure EFI disk"
            ERROR_FLAG=true
        fi
    else
        msg_error "Failed to create EFI disk"
        ERROR_FLAG=true
    fi

  fi
# ==========================================================


# Select storage volume for loader =======================

    LOADER_STORAGE=$(select_storage_volume $VMID "loader disk")
      

    # Ejecutar el comando en segundo plano y capturar su PID
    qm importdisk $VMID ${LOADER_FILE} $LOADER_STORAGE > /tmp/import_log_$VMID.txt 2>&1 &
    import_pid=$!

    # Mostrar un indicador simple de progreso
    echo -n "Importing loader disk: "
    while kill -0 $import_pid 2>/dev/null; do
        echo -n "."
        sleep 2.5
    done

    # Esperar a que termine el proceso
    wait $import_pid
    # Limpiar
    rm -f /tmp/import_log_$VMID.txt


    # Obtener el disco importado
    IMPORTED_DISK=$(qm config $VMID | grep -E 'unused[0-9]+' | tail -1 | cut -d: -f1)

    # Si el disco no se importó correctamente, mostrar mensaje de error, pero continuar
    if [ -z "$IMPORTED_DISK" ]; then
          msg_error "Loader import failed. No disk detected."
          ERROR_FLAG=true
      else
          msg_ok "Loader imported successfully to ${CL}${BL}$LOADER_STORAGE${GN}${CL}"
    fi

    # Configure the loader disk as scsi0
    DISK_NAME="vm-${VMID}-disk-0"
    result=$(qm set "$VMID" -scsi0 "${LOADER_STORAGE}:${DISK_NAME}" 2>&1 > /dev/null)
    if [[ $? -eq 0 ]]; then
          msg_ok "Configured loader disk as scsi0"
      else
          ERROR_FLAG=true
    fi

    # Set boot order to scsi0
    result=$(qm set "$VMID" -boot order=scsi0 2>&1)
    if [[ $? -eq 0 ]]; then
          msg_ok "Loader configured as boot device."
      else
          ERROR_FLAG=true
    fi

# ==========================================================

if [ "$DISK_TYPE" = "virtual" ]; then
    # Comprobar que hay discos virtuales configurados
    if [ ${#VIRTUAL_DISKS[@]} -eq 0 ]; then
        msg_error "No virtual disks configured."
        exit_script
    fi

    DISK_INFO=""
    CONSOLE_DISK_INFO=""

    for i in "${!VIRTUAL_DISKS[@]}"; do
        # Extraer almacenamiento y tamaño
        IFS=':' read -r STORAGE SIZE <<< "${VIRTUAL_DISKS[$i]}"
        
        # Determinar tipo de almacenamiento y extensión
        STORAGE_TYPE=$(pvesm status -storage $STORAGE | awk 'NR>1 {print $2}')
        case $STORAGE_TYPE in
            nfs | dir)
                DISK_EXT=".raw"
                DISK_REF="$VMID/"
                ;;
            *)
                DISK_EXT=""
                DISK_REF=""
                ;;
        esac
        

        DISK_NUM=$((i+1))
        DISK_NAME="vm-${VMID}-disk-${DISK_NUM}${DISK_EXT}"

        
        # Crear disco virtual
        msg_info "Creating virtual disk..."
        if ! pvesm alloc "$STORAGE" "$VMID" "$DISK_NAME" "$SIZE"G >/dev/null 2>&1; then
            msg_error "Failed to allocate virtual disk $DISK_NUM"
            cleanup_vmid

        fi
        
        # Configurar disco en la VM (sata0, sata1, etc.)
        SATA_ID="sata$i"
        if ! qm set "$VMID" -$SATA_ID "$STORAGE:${DISK_REF}$DISK_NAME" >/dev/null 2>&1; then
            msg_error "Failed to configure virtual disk as $SATA_ID"
            cleanup_vmid

        fi
        msg_ok "Configured virtual disk as $SATA_ID, ${SIZE}GB on ${CL}${BL}$STORAGE${CL} ${GN}"
        
        # Añadir información a la descripción
        DISK_INFO="${DISK_INFO}<p>Virtual Disk $DISK_NUM: ${SIZE}GB on ${STORAGE}</p>"
        CONSOLE_DISK_INFO="${CONSOLE_DISK_INFO}- Virtual Disk $DISK_NUM: ${SIZE}GB on ${STORAGE} ($SATA_ID)\n"
    done
    

    
    # Preparar descripción HTML
    HTML_DESC="<div align='center'>
    <h1>Synology DSM Virtual Machine</h1>
    <p>Created with ProxMenuX</p>
    <p>Loader: $LOADER_NAME</p>
    ${DISK_INFO}
    </div>"
    
    # Configurar descripción
    msg_info "Setting VM description"
    if ! qm set "$VMID" -description "$HTML_DESC" >/dev/null 2>&1; then
        msg_error "Failed to set VM description"
        exit_script
    fi
    msg_ok "Configured VM description"


else


      # Configurar múltiples discos passthrough
      DISK_INFO=""
      CONSOLE_DISK_INFO=""

      for i in "${!PASSTHROUGH_DISKS[@]}"; do
          DISK="${PASSTHROUGH_DISKS[$i]}"
          DISK_MODEL=$(lsblk -ndo MODEL "$DISK" | xargs)
          DISK_SIZE=$(lsblk -ndo SIZE "$DISK" | xargs)
          DISK_ID="sata$i"
          
          
          # Configurar disco passthrough
          result=$(qm set $VMID -${DISK_ID} ${DISK} 2>&1)
          if [[ $? -eq 0 ]]; then
              msg_ok "Configured disk ${CL}${BL}($DISK_MODEL $DISK_SIZE)${CL}${GN} as $DISK_ID"
          fi
          
          # Añadir información del disco para la descripción HTML
          DISK_INFO="${DISK_INFO}<p>Passthrough Disk $((i+1)): $DISK ($DISK_MODEL $DISK_SIZE)</p>"
          
          # Añadir información del disco para la consola
          CONSOLE_DISK_INFO="${CONSOLE_DISK_INFO}- Passthrough Disk $((i+1)): $DISK ($DISK_MODEL $DISK_SIZE) (${DISK_ID})\n"
      done


      # Preparar descripción HTML
      HTML_DESC="<div align='center'>
      <h1>Synology DSM Virtual Machine</h1>
      <p>Created with ProxMenuX</p>
      <p>Loader: $LOADER_NAME</p>
      ${DISK_INFO}
      </div>"

      # Configurar descripción
      result=$(qm set $VMID -description "$HTML_DESC" 2>&1)
      if [[ $? -eq 0 ]]; then
         msg_ok "Configured VM description"
      fi
      

fi
  
  
if [ "$ERROR_FLAG" = true ]; then
   msg_error "VM created with errors. Check configuration." 
else
   msg_success "Completed Successfully!"

     echo -e "\n${TAB}${GN}Next Steps:${CL}"
  echo -e "${TAB}1. Start the VM"
  echo -e "${TAB}2. Open the VM console and wait for the loader to boot"
  echo -e "${TAB}3. In the loader interface, follow the instructions to select your Synology model"
  echo -e "${TAB}4. Complete the DSM installation wizard"
  echo -e "${TAB}5. Find your device using: https://find.synology.com"
  echo -e
fi
  
}

# ==========================================================






# ==========================================================
# Main execution
# ==========================================================
header_info
echo -e "\n Loading..."
sleep 1

# Start script
if whiptail --backtitle "ProxMenuX" --title "$NAME" --yesno "This will create a New $NAME. Proceed?" 10 58; then
  start_script
else
  clear
  exit
fi

# Create VM
create_vm

# ==========================================================