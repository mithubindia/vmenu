show_config_menu() {
    while true; do
        OPTION=$(whiptail --title "$(translate "Configuration Menu")" --menu "$(translate "Select an option:")" 15 60 4 \
            "1" "$(translate "Change Language")" \
            "2" "$(translate "Show Version Information")" \
            "3" "$(translate "Uninstall ProxMenu")" \
            "4" "$(translate "Return to Main Menu")" 3>&1 1>&2 2>&3)

        case $OPTION in
            1)
                change_language
                ;;
            2)
                show_version_info
                ;;
            3)
                uninstall_proxmenu
                ;;
            4)
                return
                ;;
            *)
                return
                ;;
        esac
    done
}



# Change language
change_language() {
    LANGUAGE=$(whiptail --title "$(translate "Change Language")" --menu "$(translate "Select a new language for the menu:")" 20 60 12 \
            "en" "$(translate "English (Recommended)")" \
            "es" "$(translate "Spanish")" \
            "fr" "$(translate "French")" \
            "de" "$(translate "German")" \
            "it" "$(translate "Italian")" \
            "pt" "$(translate "Portuguese")" \
            "zh-cn" "$(translate "Simplified Chinese")" \
            "ja" "$(translate "Japanese")" 3>&1 1>&2 2>&3)

    if [ -z "$LANGUAGE" ]; then
        msg_error "$(translate "No language selected.")"
        return
    fi

    echo "{\"language\": \"$LANGUAGE\"}" > "$CONFIG_FILE"
    msg_ok "$(translate "Language changed to") $LANGUAGE"
    exec "$0"
}



# Function to uninstall ProxMenu
uninstall_proxmenu() {
    if whiptail --title "$(translate "Uninstall ProxMenu")" --yesno "$(translate "Are you sure you want to uninstall ProxMenu?")" 10 60; then
        msg_info "$(translate "Uninstalling ProxMenu...")"
        rm -rf "$BASE_DIR"
        rm -f "/usr/local/bin/menu.sh"
        msg_ok "$(translate "ProxMenu has been completely uninstalled.")"
        exit 0
    fi
}

# Function to show version information
show_version_info() {
    local version=$(cat "$LOCAL_VERSION_FILE" 2>/dev/null || echo "1.0.0")
    whiptail --title "$(translate "Version Information")" --msgbox "$(translate "Current ProxMenu version:") $version" 12 60
}

# Main flow

show_config_menu
