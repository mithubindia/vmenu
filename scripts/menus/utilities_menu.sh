#!/bin/bash

# ==========================================================
# ProxMenu - A menu-driven script for Proxmox VE management
# ==========================================================
# Author      : MacRimi
# Copyright   : (c) 2024 MacRimi
# License     : MIT (https://raw.githubusercontent.com/MacRimi/ProxMenux/main/LICENSE)
# Version     : 1.0
# Last Updated: 02/07/2025
# ==========================================================


# Configuration ============================================
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
BASE_DIR="/usr/local/share/proxmenux"
UTILS_FILE="$BASE_DIR/utils.sh"
VENV_PATH="/opt/googletrans-env"

if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
fi
load_language
initialize_cache
# ==========================================================

    while true; do
        OPTION=$(dialog --clear --backtitle "ProxMenux" --title "$(translate "Utilities Menu")" \
                        --menu "\n$(translate "Select an option:")" 20 70 8 \
                        "1" "$(translate "UUp Dump ISO creator Custom")" \
                        "2" "$(translate "System Utilities Installer")" \
                        "3" "$(translate "Proxmox System Update")" \
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
                bash <(curl -s "$REPO_URL/scripts/utilities/proxmox_update.sh")
                if [ $? -ne 0 ]; then
                    return
                fi
                ;;
            4) exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh") ;;
            *) exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh") ;;
        esac
    done
