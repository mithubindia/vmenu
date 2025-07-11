


# Configuration ============================================
REPO_URL="https://raw.githubusercontent.com/mithubindia/vmenu/main"
BASE_DIR="/usr/local/share/vmenu"
UTILS_FILE="$BASE_DIR/utils.sh"
VENV_PATH="/opt/googletrans-env"

if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
fi
load_language
initialize_cache


while true; do
    OPTION=$(whiptail --title "$(translate "Disk and Storage Manager Menu")" --menu "$(translate "Select an option:")" 20 70 10 \
        "1" "$(translate "Add Disk Passthrough to a VM")" \
        "2" "$(translate "Add Disk") Passthrough $(translate "to a CT")" \
        "3" "$(translate "Import Disk Image to a VM")" \
        "4" "$(translate "Mount point to CT")" \
        "5" "$(translate "Mount disk on HOST")" \
        "6" "$(translate "Unmount disk from HOST")" \
        "7" "$(translate "Format disk")" \
        "8" "$(translate "Return to Main Menu")" 3>&1 1>&2 2>&3)

    case $OPTION in
        1)
            msg_info2 "$(translate "Running script: Add Disk Passthrough to a VM")..."
            bash <(curl -s "$REPO_URL/scripts/storage/disk-passthrough.sh")
            ;;
        2)
            msg_info2 "$(translate "Running script: Add Disk Passthrough to a CT")..."
            bash <(curl -s "$REPO_URL/scripts/storage/disk-passthrough_ct.sh")
            ;;
        3)
            msg_info2 "$(translate "Running script: Import Disk Image to a VM")..."
            bash <(curl -s "$REPO_URL/scripts/storage/import-disk-image.sh")
            ;;
        4)
            msg_info2 "$(translate "Running script: Mount point to CT")..."
            bash <(curl -s "$REPO_URL/scripts/storage/mount-point-to-ct.sh")
            ;;
        5)
            msg_info2 "$(translate "Running script: Mount disk on HOST")..."
            bash <(curl -s "$REPO_URL/scripts/storage/mount-disk-on-host.sh")
            ;;
        6)
            msg_info2 "$(translate "Running script: Unmount disk from HOST")..."
            bash <(curl -s "$REPO_URL/scripts/storage/unmount-disk-from-host.sh")
            ;;
        7)
            msg_info2 "$(translate "Running script: Format disk")..."
            bash <(curl -s "$REPO_URL/scripts/storage/format-disk.sh")
            ;;
        8)
            exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh")
            ;;
        *)
            exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh")
            ;;
    esac
done

