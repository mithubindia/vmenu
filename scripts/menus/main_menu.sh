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


# Configuration
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
UTILS_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main/scripts/utils.sh"
BASE_DIR="/usr/local/share/proxmenux"
CACHE_FILE="$BASE_DIR/cache.json"
VENV_PATH="/opt/googletrans-env"
LANGUAGE=$(jq -r '.language // "en"' "$BASE_DIR/config.json" 2>/dev/null)


# Try to load utils.sh from GitHub
if ! source <(curl -sSf "$UTILS_URL"); then
    echo "$(translate 'Error: Could not load utils.sh from') $UTILS_URL"
    exit 1
fi

# Initialize cache
initialize_cache() {
    if [ ! -f "$CACHE_FILE" ]; then
        echo "{}" > "$CACHE_FILE"
        return
    fi
}

 # Load language from JSON file
load_language() {
    if [ -f "$CONFIG_FILE" ]; then
        LANGUAGE=$(jq -r '.language' "$CONFIG_FILE")
    fi
}

show_menu() {
    while true; do
        OPTION=$(whiptail --title "$(translate "Main Menu")" --menu "$(translate "Select an option:")" 15 60 5 \
            "1" "$(translate "GPUs and Coral-TPU")" \
            "2" "$(translate "Hard Drives, Disk Images, and Storage")" \
            "3" "$(translate "Network")" \
            "4" "$(translate "Settings")" \
            "5" "$(translate "Exit")" 3>&1 1>&2 2>&3)



    case $OPTION in
        1) exec bash <(curl -s "$REPO_URL/menu-almacenamiento.sh") ;;
        2) exec bash <(curl -s "$REPO_URL/scripts/menus/storage_menu.sh") ;;
        3) exec bash <(curl -s "$REPO_URL/scripts/menus/network_menu") ;;
        4) exec bash <(curl -s "$REPO_URL/scripts/menus/config_menu.sh") ;;
        5) clear; msg_ok "$(translate "Thank you for using ProxMenu. Goodbye!")"; exit 0 ;;
        *) msg_error "Opción inválida"; sleep 2 ;;
    esac
    
done
}

# Main flow
initialize_cache
load_language
show_menu

