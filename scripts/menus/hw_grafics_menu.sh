#!/bin/bash

# ==========================================================
# ProxMenu - A menu-driven script for Proxmox VE management
# ==========================================================
# Author      : MacRimi
# Copyright   : (c) 2024 MacRimi
# License     : MIT (https://raw.githubusercontent.com/MacRimi/ProxMenux/main/LICENSE)
# Version     : 1.0
# Last Updated: 28/01/2025
# ==========================================================


# Configuration ============================================
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
UTILS_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main/scripts/utils.sh"
BASE_DIR="/usr/local/share/proxmenux"
CACHE_FILE="$BASE_DIR/cache.json"
VENV_PATH="/opt/googletrans-env"
LANGUAGE=$(jq -r '.language // "en"' "$BASE_DIR/config.json" 2>/dev/null)

if ! source <(curl -sSf "$UTILS_URL"); then
    echo "$(translate 'Error: Could not load utils.sh from') $UTILS_URL"
    exit 1
fi

initialize_cache() {
    if [ ! -f "$CACHE_FILE" ]; then
        echo "{}" > "$CACHE_FILE"
        return
    fi
}

load_language() {
    if [ -f "$CONFIG_FILE" ]; then
        LANGUAGE=$(jq -r '.language' "$CONFIG_FILE")
    fi
}
# ==========================================================

    while true; do
        OPTION=$(whiptail --title "$(translate "GPUs and Coral-TPU Menu")" --menu "$(translate "Select an option:")" 15 60 8 \
            "1" "$(translate "Add HW iGPU acceleration to an LXC")" \
            "2" "$(translate "Add Coral TPU to an LXC")" \
            "3" "$(translate "Install/Update Coral TPU on the Host")" \
            "4" "$(translate "Return to Main Menu")" 3>&1 1>&2 2>&3)

        case $OPTION in
            1)
                echo -e "\033[33m[INFO] $(translate "Running script:") $(translate "HW iGPU LXC")...\033[0m"
                bash <(curl -s "$REPO_URL/scripts/configure_igpu_lxc.sh")
                if [ $? -ne 0 ]; then
                    msg_info "$(translate "Operation cancelled.")"
                    sleep 2
                fi
                ;;
            2)
                echo -e "\033[33m[INFO] $(translate "Running script:") $(translate "Coral TPU LXC")...\033[0m"
                bash <(curl -s "$REPO_URL/scripts/install_coral_lxc.sh")
                if [ $? -ne 0 ]; then
                    msg_info "$(translate "Operation cancelled.")"
                    sleep 2
                fi
                ;;
            3)
                echo -e "\033[33m[INFO] $(translate "Running script:") $(translate "Install/Update Coral")...\033[0m"
                bash <(curl -s "$REPO_URL/scripts/install_coral_pve.sh")
                if [ $? -ne 0 ]; then
                    msg_info "$(translate "Operation cancelled.")"
                    sleep 2
                fi
                ;;
                
            4) exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh") ;;
            *) exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh") ;;
        esac
    done

