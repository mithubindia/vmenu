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

# Configuration ============================================
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
RETURN_SCRIPT="$REPO_URL/scripts/menus/menu_post_install.sh"
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


# ==========================================================

uninstall_figurine() {
    if ! command -v figurine &>/dev/null; then
        msg_warn "$(translate "Figurine is not installed.")"
        return 0
    fi

    msg_info2 "$(translate "Uninstalling Figurine...")"

    rm -f /usr/local/bin/figurine
    rm -f /etc/profile.d/figurine.sh
    sed -i '/figurine/d' "$HOME/.bashrc" "$HOME/.profile" 2>/dev/null

    msg_ok "$(translate "Figurine removed from system")"
    msg_success "$(translate "You can reinstall it anytime from the post-installation script")"
    msg_success "$(translate "Press ENTER to continue...")"
    read -r
}

# ==========================================================

show_uninstall_menu() {
    local options=()
    
    if command -v fastfetch >/dev/null 2>&1; then
        options+=("$index" "$(translate "Uninstall") Fastfetch")
        local fastfetch_option="$index"
        index=$((index + 1))
    fi

    if command -v figurine >/dev/null 2>&1; then
        options+=("$index" "$(translate "Uninstall") Figurine")
        local figurine_option="$index"
        index=$((index + 1))
    fi

    if [ ${#options[@]} -eq 0 ]; then
        whiptail --title "ProxMenux" --msgbox "$(translate "No uninstallable tools detected.")" 10 60
        return_to_menu
    fi

    local choice
    choice=$(whiptail --title "$(translate "Uninstall Tools")" \
                      --menu "$(translate "Select a tool to uninstall:")" 15 60 6 \
                      "${options[@]}" 3>&1 1>&2 2>&3)

    case "$choice" in
        "$fastfetch_option") uninstall_fastfetch ;;
        "$figurine_option") uninstall_figurine ;;
    esac

    return_to_menu
}

return_to_menu() {
    # Descargar temporalmente el script
    TEMP_SCRIPT=$(mktemp)
    if curl --fail -s -o "$TEMP_SCRIPT" "$RETURN_SCRIPT"; then
        bash "$TEMP_SCRIPT"
        rm -f "$TEMP_SCRIPT"
    else
        msg_error "$(translate "Error: Could not return to menu. URL returned 404.")"
        msg_info2 "$(translate "Please check the menu URL in the script.")"
        read -r
        exit 1
    fi
}


show_uninstall_menu
