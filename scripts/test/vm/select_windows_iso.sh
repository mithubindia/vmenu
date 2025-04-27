#!/usr/bin/env bash

# ==============================================================
# ProxMenux - Windows ISO Selector
# ==============================================================

BASE_DIR="/usr/local/share/proxmenux"
UTILS_FILE="$BASE_DIR/utils.sh"
VENV_PATH="/opt/googletrans-env"

if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
fi

load_language
initialize_cache

ISO_DIR="/var/lib/vz/template/iso"
mkdir -p "$ISO_DIR"




function select_windows_iso() {
  local CHOICE=$(whiptail --title "ProxMenux - Windows ISO" --menu "$(translate "Select how to provide the Windows ISO")" 15 60 2 \
    "1" "$(translate "Use existing ISO from storage")" \
    "2" "$(translate "Download ISO using UUP Dump")" 3>&1 1>&2 2>&3)

  [[ $? -ne 0 ]] && msg_error "$(translate "Operation cancelled.")" && exit 1

  case "$CHOICE" in
    1)
      select_existing_iso
      ;;
    2)
      if [[ -f ./uupdump_creator.sh ]]; then
        source ./uupdump_creator.sh
        run_uupdump_creator || exit 1
        detect_latest_iso_created
      else
        msg_error "$(translate "UUP Dump script not found.")"
        exit 1
      fi
      ;;
  esac
}

function select_existing_iso() {
  ISO_LIST=()
  while read -r line; do
    FILENAME=$(basename "$line")
    SIZE=$(du -h "$line" | cut -f1)
    ISO_LIST+=("$FILENAME" "$SIZE")
  done < <(find "$ISO_DIR" -type f -iname "*.iso" ! -iname "virtio*" | sort)

  if [[ ${#ISO_LIST[@]} -eq 0 ]]; then
    msg_error "$(translate "No ISO images found in $ISO_DIR.")"
    exit 1
  fi

  ISO_FILE=$(whiptail --title "ProxMenux - Windows ISO" --menu "$(translate "Choose a Windows ISO to use:")" 20 70 10 "${ISO_LIST[@]}" 3>&1 1>&2 2>&3)

  if [[ -z "$ISO_FILE" ]]; then
    msg_error "$(translate "No ISO selected.")"
    exit 1
  fi

  ISO_PATH="$ISO_DIR/$ISO_FILE"
  ISO_NAME="$ISO_FILE"

  export ISO_PATH ISO_FILE ISO_NAME
}




function detect_latest_iso_created() {
  ISO_FILE=$(find "$ISO_DIR" -maxdepth 1 -type f -iname "*.iso" ! -iname "virtio*" -printf "%T@ %p\n" | sort -n | awk '{print $2}' | tail -n 1)

  if [[ -z "$ISO_FILE" ]]; then
    msg_error "$(translate "No ISO file detected after UUP Dump process.")"
    exit 1
  fi

  ISO_NAME=$(basename "$ISO_FILE")
  ISO_PATH="$ISO_FILE"

  export ISO_PATH ISO_FILE ISO_NAME
}

