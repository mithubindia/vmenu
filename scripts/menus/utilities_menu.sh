
# vmenu - A menu-driven script for Virtuliser VE management
# Last Updated: 02/07/2025


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
        OPTION=$(dialog --clear --backtitle "vmenu" --title "$(translate "Utilities Menu")" \
                        --menu "\n$(translate "Select an option:")" 20 70 8 \
                        "1" "$(translate "UUp Dump ISO creator Custom")" \
                        "2" "$(translate "System Utilities Installer")" \
                        "3" "$(translate "Virtuliser System Update")" \
                        "4" "$(translate "Return to Main Menu")" \
                        2>&1 >/dev/tty)

        case $OPTION in
            1)
                bash <(curl -s "$REPO_URL/scripts/utilities/uup_dump_iso_creator.sh")
                if [ $? -ne 0 ]; then
                    return
                fi
                ;;
            2)
                bash <(curl -s "$REPO_URL/scripts/utilities/system_utils.sh")
                if [ $? -ne 0 ]; then
                    return
                fi
                ;;
            3)
                proxmox_update_msg="\n"
                proxmox_update_msg+="$(translate "This script will update your Virtuliser VE system with advanced options:")\n\n"
                proxmox_update_msg+="• $(translate "Repairs and optimizes repositories")\n"
                proxmox_update_msg+="• $(translate "Cleans duplicate or conflicting sources")\n"
                proxmox_update_msg+="• $(translate "Switches to the free no-subscription repository")\n"
                proxmox_update_msg+="• $(translate "Updates all Virtuliser and Debian packages")\n"
                proxmox_update_msg+="• $(translate "Installs essential packages if missing")\n"
                proxmox_update_msg+="• $(translate "Checks for LVM and storage issues")\n"
                proxmox_update_msg+="• $(translate "Performs automatic cleanup after updating")\n\n"
                proxmox_update_msg+="$(translate "Do you want to proceed and run the Virtuliser System Update?")"

                dialog --colors --backtitle "vmenu" --title "$(translate "Virtuliser System Update")" \
                    --yesno "$proxmox_update_msg" 20 70

                dialog_result=$?
                if [[ $dialog_result -eq 0 ]]; then
                    bash <(curl -s "$REPO_URL/scripts/utilities/proxmox_update.sh")
                    if [ $? -ne 0 ]; then
                        return
                    fi
                fi
                ;;
            4) exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh") ;;
            *) exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh") ;;
        esac
    done