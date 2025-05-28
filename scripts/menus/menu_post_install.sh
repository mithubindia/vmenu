#!/bin/bash

# ==========================================================
# ProxMenu - A menu-driven script for Proxmox VE management
# ==========================================================
# Author      : MacRimi
# Copyright   : (c) 2024 MacRimi
# License     : MIT (https://raw.githubusercontent.com/MacRimi/ProxMenux/main/LICENSE)
# Version     : 1.1
# Last Updated: 28/05/2025
# ==========================================================

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

confirm_and_run() {
    local name="$1"
    local command="$2"

    dialog --clear --title "$(translate "Confirmation")" \
           --yesno "\n\n$(translate "Do you want to run the post-installation script from") $name?" 10 70
    response=$?
    clear

    if [ $response -eq 0 ]; then
        eval "$command"
        echo
        msg_success "$(translate 'Press ENTER to continue...')"
        read -r _
    else
        msg_warn "$(translate "Cancelled by user.")"
        sleep 1
    fi
}

scripts_es=(
    "Script post-install personalizable |ProxMenux|bash <(curl -s $REPO_URL/scripts/customizable_post_install.sh)"
    "Script post-install Proxmox VE |Helper-Scripts|bash -c \"\$(wget -qLO - https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pve-install.sh); msg_success \\\"\$(translate 'Press ENTER to continue...')\\\"; read -r _\""
    "Script post-iinstall xshok-proxmox|fork xshok-proxmox|confirm_and_run \"Xshok\" \"wget https://raw.githubusercontent.com/MacRimi/xshok-proxmox/master/install-post.sh -c -O install-post.sh && bash install-post.sh && rm install-post.sh\""
    "Desinstalar herramientas|ProxMenux|bash <(curl -s $REPO_URL/scripts/uninstall-tools.sh)"
)

scripts_all_langs=(
    "Customizable script post-installation|ProxMenux|bash <(curl -s $REPO_URL/scripts/customizable_post_install.sh)"
    "Proxmox VE Post Install|Helper-Scripts|bash -c \"\$(wget -qLO - https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pve-install.sh); msg_success \\\"\$(translate 'Press ENTER to continue...')\\\"; read -r _\""
    "Xshok-proxmox Post install|fork xshok-proxmox|confirm_and_run \"Xshok\" \"wget https://raw.githubusercontent.com/MacRimi/xshok-proxmox/master/install-post.sh -c -O install-post.sh && bash install-post.sh && rm install-post.sh\""
    "Uninstall Tools|ProxMenux|bash <(curl -s $REPO_URL/scripts/uninstall-tools.sh)"
)

show_menu() {
    while true; do
        local HEADER
        local current_scripts=()

        if [[ "$LANGUAGE" == "es" ]]; then
            HEADER="\n Seleccione un script post-instalación:\n\n    Descripción                                     │ Fuente"
            current_scripts=("${scripts_es[@]}")
        else
            HEADER="\n$(translate " Select a post-installation script:")\n\n    Description                                     │ Source"
            current_scripts=("${scripts_all_langs[@]}")
        fi

        menu_items=()

        for i in "${!current_scripts[@]}"; do
            IFS='|' read -r name repository command <<< "${current_scripts[$i]}"
            number=$((i+1))
            local display_name="$name"
            [[ "$LANGUAGE" != "es" ]] && display_name="$(translate "$name")"
            formatted_line=$(printf "%-47s │ %s" "$display_name" "$repository")
            menu_items+=("$number" "$formatted_line")
        done

        menu_items+=("$(( ${#current_scripts[@]}+1 ))" "$(translate "Return to Main Menu")")

        exec 3>&1
        script_selection=$(dialog --clear --backtitle "ProxMenux" --title "$(translate "Post-Installation Scripts Menu")" \
                            --menu "$HEADER" 20 78 $((${#menu_items[@]}/2)) \
                            "${menu_items[@]}" 2>&1 1>&3)
        exit_status=$?
        exec 3>&-

        

        if [ $exit_status -ne 0 ]; then
            exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh")
        fi

        if [ "$script_selection" = "$(( ${#current_scripts[@]} + 1 ))" ]; then
            exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh")
        fi

        index=$((script_selection - 1))
        if [ $index -ge 0 ] && [ $index -lt ${#current_scripts[@]} ]; then
            IFS='|' read -r _ _ command <<< "${current_scripts[$index]}"
            eval "$command"
        fi
    done
}


#if [[ "$LANGUAGE" != "en" ]]; then
#    show_proxmenux_logo
#    msg_lang "$(translate "Generating automatic translations...")"
#fi
cleanup
show_menu