#!/bin/bash

# ==========================================================
# ProxMenux - Uninstall Tools Menu for Proxmox
# ==========================================================
# Author      : MacRimi
# Copyright   : (c) 2024 MacRimi
# License     : MIT (https://raw.githubusercontent.com/MacRimi/ProxMenux/main/LICENSE)
# Version     : 1.1
# Last Updated: 19/06/2025
# ==========================================================
# Description:
# This script provides a dynamic menu for uninstalling optional tools 
# installed through ProxMenux on Proxmox Virtual Environment (VE). 
# ==========================================================

REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
RETURN_SCRIPT="$REPO_URL/scripts/menus/menu_post_install.sh"
BASE_DIR="/usr/local/share/proxmenux"
UTILS_FILE="$BASE_DIR/utils.sh"
TOOLS_JSON="$BASE_DIR/installed_tools.json"
VENV_PATH="/opt/googletrans-env"

if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
fi
load_language
initialize_cache


ensure_tools_json() {
  [ -f "$TOOLS_JSON" ] || echo "{}" > "$TOOLS_JSON"
}

register_tool() {
  local tool="$1"
  local state="$2"  
  ensure_tools_json
  jq --arg t "$tool" --argjson v "$state" '.[$t]=$v' "$TOOLS_JSON" > "$TOOLS_JSON.tmp" && mv "$TOOLS_JSON.tmp" "$TOOLS_JSON"
}



migrate_installed_tools() {
    local TOOLS_JSON="/usr/local/share/proxmenux/installed_tools.json"

    if [[ -f "$TOOLS_JSON" ]]; then
        return
    fi
    clear
    show_proxmenux_logo
    msg_info "$(translate 'Detecting previous adjustments...')"   

    echo "{}" > "$TOOLS_JSON"
    local updated=false

    # --- Fastfetch ---
    if command -v fastfetch >/dev/null 2>&1 || [[ -x /usr/local/bin/fastfetch ]] || [[ -x /usr/bin/fastfetch ]]; then
        jq '. + {"fastfetch": true}' "$TOOLS_JSON" > "$TOOLS_JSON.tmp" && mv "$TOOLS_JSON.tmp" "$TOOLS_JSON"
        updated=true
    fi

    # --- Figurine ---
    if command -v figurine >/dev/null 2>&1 || [[ -x /usr/local/bin/figurine ]]; then
        jq '. + {"figurine": true}' "$TOOLS_JSON" > "$TOOLS_JSON.tmp" && mv "$TOOLS_JSON.tmp" "$TOOLS_JSON"
        updated=true
    fi

    # --- Kexec ---
    if dpkg -s kexec-tools >/dev/null 2>&1 && systemctl list-unit-files | grep -q kexec-pve.service; then
        jq '. + {"kexec": true}' "$TOOLS_JSON" > "$TOOLS_JSON.tmp" && mv "$TOOLS_JSON.tmp" "$TOOLS_JSON"
        updated=true
    fi

 
    if [[ "$updated" == true ]]; then
        sleep 2
        msg_ok "$(translate 'Adjustments detected and ready to revert.')"
        sleep 1
    fi
}



################################################################

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
    register_tool "fastfetch" false
}

################################################################

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
    register_tool "figurine" false
}

################################################################

uninstall_kexec() {
    if ! dpkg -s kexec-tools >/dev/null 2>&1 && [ ! -f /etc/systemd/system/kexec-pve.service ]; then
        msg_warn "$(translate "kexec-tools is not installed or already removed.")"
        return 0
    fi

    msg_info2 "$(translate "Uninstalling kexec-tools and removing custom service...")"
    systemctl disable --now kexec-pve.service &>/dev/null
    rm -f /etc/systemd/system/kexec-pve.service
    sed -i "/alias reboot-quick='systemctl kexec'/d" /root/.bash_profile
    apt-get purge -y kexec-tools >/dev/null 2>&1

    msg_ok "$(translate "kexec-tools and related settings removed")"
    register_tool "kexec" false
}

################################################################

show_uninstall_menu() {
    ensure_tools_json
    mapfile -t tools_installed < <(jq -r 'to_entries | map(select(.value==true)) | .[].key' "$TOOLS_JSON")
    if [[ ${#tools_installed[@]} -eq 0 ]]; then
        dialog --backtitle "ProxMenux" --title "ProxMenux" --msgbox "\n\n$(translate "No uninstallable tools detected.")" 10 60
        return 0
    fi

    local menu_options=()
    for tool in "${tools_installed[@]}"; do
        case "$tool" in
            fastfetch) desc="Fastfetch";;
            figurine)  desc="Figurine";;
            kexec)     desc="Kexec quick reboot";;
            *)         desc="$tool";;
        esac
        menu_options+=("$tool" "$desc" "off")
    done

    selected_tools=$(dialog --backtitle "ProxMenux" \
        --title "$(translate "Uninstall Tools")" \
        --checklist "$(translate "Select tools post-install to uninstall:")" 20 60 12 \
        "${menu_options[@]}" 3>&1 1>&2 2>&3)
    local dialog_result=$?

    if [[ $dialog_result -ne 0 || -z "$selected_tools" ]]; then
        return 0

    fi

    for tool in $selected_tools; do
        tool=$(echo "$tool" | tr -d '"')
        if declare -f "uninstall_$tool" > /dev/null 2>&1; then
           clear
           show_proxmenux_logo 
           "uninstall_$tool"
        else
            msg_warn "$(translate "No uninstaller found for:") $tool"
        fi
    done

  msg_success "$(translate "All related files and settings have been removed. Reboot required.")"
  msg_success "$(translate "Press Enter to return to menu...")"
  read -r

}
################################################################

migrate_installed_tools
show_uninstall_menu