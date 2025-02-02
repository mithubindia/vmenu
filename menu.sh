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
# Description:
# This script serves as the main entry point for ProxMenux,
# a menu-driven tool designed for Proxmox VE management.
#
# - Displays the ProxMenu logo on startup.
# - Loads necessary configurations and language settings.
# - Checks for available updates and installs them if confirmed.
# - Downloads and executes the latest main menu script.
#
# Key Features:
# - Ensures ProxMenu is always up-to-date by fetching the latest version.
# - Uses whiptail for interactive menus and language selection.
# - Loads utility functions and translation support.
# - Maintains a cache system to improve performance.
# - Executes the ProxMenux main menu dynamically from the repository.
#
# This script ensures a streamlined and automated experience
# for managing Proxmox VE using ProxMenux.
# ==========================================================

# Configuration ============================================
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
BASE_DIR="/usr/local/share/proxmenux"
CONFIG_FILE="$BASE_DIR/config.json"
CACHE_FILE="$BASE_DIR/cache.json"
UTILS_FILE="$BASE_DIR/utils.sh"
LOCAL_VERSION_FILE="$BASE_DIR/version.txt"
VENV_PATH="/opt/googletrans-env"

if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
fi
# ==========================================================

show_proxmenu_logo

# Initialize language configuration
initialize_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        LANGUAGE=$(whiptail --title "$(translate "Select Language")" --menu "$(translate "Choose a language for the menu:")" 20 60 12 \
            "en" "$(translate "English (Recommended)")" \
            "es" "$(translate "Spanish")" \
            "fr" "$(translate "French")" \
            "de" "$(translate "German")" \
            "it" "$(translate "Italian")" \
            "pt" "$(translate "Portuguese")" \
            "zh-cn" "$(translate "Simplified Chinese")" \
            "ja" "$(translate "Japanese")" 3>&1 1>&2 2>&3)

        if [ -z "$LANGUAGE" ]; then
            msg_error "$(translate "No language selected. Exiting.")"
            exit 1
        fi

        echo "{\"language\": \"$LANGUAGE\"}" > "$CONFIG_FILE"
        msg_ok "$(translate "Initial language set to:") $LANGUAGE"
    fi

}


check_updates() {
    local INSTALL_SCRIPT="$BASE_DIR/install_proxmenux.sh" 
 
    # Fetch the remote version
    local REMOTE_VERSION
    REMOTE_VERSION=$(curl -fsSL "$REPO_URL/version.txt" | head -n 1)

    # Exit silently if unable to fetch the remote version
    if [ -z "$REMOTE_VERSION" ]; then
        return 0
    fi

    # Read the local version
    local LOCAL_VERSION
    LOCAL_VERSION=$(head -n 1 "$LOCAL_VERSION_FILE")

    # If the local version matches the remote version, no update is needed
    [ "$LOCAL_VERSION" = "$REMOTE_VERSION" ] && return 0

    # Prompt the user for update confirmation
    if whiptail --title "$(translate "Update Available")" \
                --yesno "$(translate "New version available") ($REMOTE_VERSION)\n\n$(translate "Do you want to update now?")" \
                10 60 --defaultno; then


        msg_warn "$(translate "Starting ProxMenu update...")"

        # Download the installation script
        if wget -qO "$INSTALL_SCRIPT" "$REPO_URL/install_proxmenux.sh"; then
            chmod +x "$INSTALL_SCRIPT"

            # Execute the script directly in the current environment
            source "$INSTALL_SCRIPT"

        fi
    else
        msg_warn "$(translate "Update postponed. You can update later from the menu.")"
    fi
}



main_menu() {
    exec bash <(curl -fsSL "$REPO_URL/scripts/menus/main_menu.sh")
}


# Main flow
initialize_config
load_language
initialize_cache
check_updates
main_menu
