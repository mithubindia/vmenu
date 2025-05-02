#!/bin/bash

# ==========================================================
# ProxMenux - Uninstall Tools Menu for Proxmox
# ==========================================================
# Author      : MacRimi
# Copyright   : (c) 2024 MacRimi
# License     : MIT (https://raw.githubusercontent.com/MacRimi/ProxMenux/main/LICENSE)
# Version     : 1.0
# Last Updated: 02/05/2025
# ==========================================================
# Description:
# This script provides a dynamic menu for uninstalling optional tools 
# installed through ProxMenux on Proxmox Virtual Environment (VE). 
# ==========================================================

# Configuration
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

uninstall_fastfetch() {
    if ! command -v fastfetch &>/dev/null; then
        msg_warn "$(translate "Fastfetch is not installed.")"
        return 0
    fi

    msg_info2 "$(translate "Uninstalling Fastfetch...")"

    rm -f /usr/local/bin/fastfetch /usr/bin/fastfetch
    rm -rf "$HOME/.config/fastfetch"
    rm -rf /usr/local/share/fastfetch
    sed -i '/fastfetch/d' "$HOME/.bashrc" "$HOME/.profile" 2>/dev/null
    rm -f /etc/profile.d/fastfetch.sh /etc/update-motd.d/99-fastfetch
    dpkg -r fastfetch &>/dev/null

    msg_ok "$(translate "Fastfetch removed from system")"
    msg_success "$(translate "You can reinstall it anytime from the post-installation script")"
    msg_success "$(translate "Press Enter to return...")"
    read -r
}

show_uninstall_menu() {
    local options=()
    
    # Fastfetch
    if command -v fastfetch &>/dev/null; then
        options+=("1" "$(translate "Uninstall Fastfetch")")
    fi

    if [ ${#options[@]} -eq 0 ]; then
        whiptail --title "ProxMenux" --msgbox "$(translate "No uninstallable tools detected.")" 10 60
        exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh")
    fi

    local choice=$(whiptail --title "$(translate "Uninstall Tools")" \
                             --menu "$(translate "Select a tool to uninstall:")" 15 60 6 \
                             "${options[@]}" 3>&1 1>&2 2>&3)

    case "$choice" in
        1) uninstall_fastfetch ;;
    esac


    exec bash <(curl -s "$REPO_URL/scripts/menus/uninstall-menu.sh")
}

show_uninstall_menu
