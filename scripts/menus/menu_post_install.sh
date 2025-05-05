#!/bin/bash

# ==========================================================
# ProxMenu - A menu-driven script for Proxmox VE management
# ==========================================================
# Author      : MacRimi
# Copyright   : (c) 2024 MacRimi
# License     : MIT (https://raw.githubusercontent.com/MacRimi/ProxMenux/main/LICENSE)
# Version     : 1.0
# Last Updated: 24/02/2025
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
show_proxmenux_logo
# ==========================================================

# Define scripts array
scripts=(
    "Customizable script post-installation|ProxMenux|bash <(curl -s $REPO_URL/scripts/customizable_post_install.sh)"
    "Proxmox VE Post Install|Helper-Scripts|bash -c \"\$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/misc/post-pve-install.sh)\""
    "xshok-proxmox Post install|fork xshok-proxmox|wget https://raw.githubusercontent.com/MacRimi/xshok-proxmox/master/install-post.sh -c -O install-post.sh && bash install-post.sh && rm install-post.sh"
    "Uninstall Tools|ProxMenux|bash <(curl -s $REPO_URL/scripts/uninstall-tools.sh)"

)

show_menu() {
    while true; do
        HEADER=$(printf "  %-52s %-20s" "$(translate "Name")" "$(translate "Repository")")

        menu_items=()
        for i in "${!scripts[@]}"; do
            IFS='|' read -r name repository command <<< "${scripts[$i]}"
            number=$((i+1))
            padded_option=$(printf "%2d %-50s" "$number" "$(translate "$name")")
            menu_items+=("$padded_option" "$repository")
        done

        menu_items+=("$(printf "%2d %-40s" "$((${#scripts[@]}+1))" "$(translate "Return to Main Menu")")" "")
        
        cleanup
        
        script_selection=$(whiptail --title "$(translate "Post-Installation Scripts Menu")" \
                                    --menu "\n$HEADER" 20 78 $((${#scripts[@]}+1)) \
                                    "${menu_items[@]}" 3>&1 1>&2 2>&3)

        if [ -n "$script_selection" ]; then
            selected_number=$(echo "$script_selection" | awk '{print $1}')
            
            if [ "$selected_number" = "$((${#scripts[@]}+1))" ]; then
                exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh")
            fi

            index=$((selected_number - 1))
            if [ $index -ge 0 ] && [ $index -lt ${#scripts[@]} ]; then
                IFS='|' read -r name repository command <<< "${scripts[$index]}"
                eval "$command"
            fi

        else
            exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh")
        fi
    done
}


if [[ "$LANGUAGE" != "en" ]]; then
    msg_lang "$(translate "Generating automatic translations...")"
fi

show_menu