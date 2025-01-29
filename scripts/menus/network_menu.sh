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
# ==========================================================

    while true; do
        OPTION=$(whiptail --title "$(translate "Network Menu")" --menu "$(translate "Select an option:")" 15 60 2 \
            "1" "$(translate "Repair Network")" \
            "2" "$(translate "Return to Main Menu")" 3>&1 1>&2 2>&3)

        case $OPTION in
            1)
                msg_info "$(translate "Running network repair...")"
                if bash <(curl -s "$REPO_URL/scripts/repair_network.sh"); then
                    msg_ok "$(translate "Network repair completed.")"
                else
                    msg_error "$(translate "Error in network repair.")"
                fi
                ;;
            2)
                return
                ;;
            *)
                msg_error "$(translate "Invalid option.")"
                sleep 2
                ;;
        esac
    done
