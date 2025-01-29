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
CONFIG_FILE="$BASE_DIR/config.json"
VENV_PATH="/opt/googletrans-env"


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

    # Descargar el script nuevamente
    TMP_FILE=$(mktemp)
    curl -s "$REPO_URL/scripts/menus/config_menu.sh" > "$TMP_FILE"
    chmod +x "$TMP_FILE"

    # Programar la eliminación del archivo cuando termine el proceso
    trap 'rm -f "$TMP_FILE"' EXIT

    exec bash "$TMP_FILE"
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

# Show configuration menu
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

# Show graphics and video menu
show_graphics_menu() {
    while true; do
        OPTION=$(whiptail --title "$(translate "HW: GPUs and Coral")" --menu "$(translate "Select an option:")" 15 60 2 \
            "1" "IGPU/TPU" \
            "2" "$(translate "Return to Main Menu")" 3>&1 1>&2 2>&3)

        case $OPTION in
            1)
                msg_info "$(translate "Running script") IGPU/TPU..."
                if bash <(curl -s "$REPO_URL/scripts/igpu_tpu.sh"); then
                    msg_ok "$(translate "Script executed successfully.")"
                else
                    msg_error "$(translate "Error executing script.")"
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
}



# Show storage menu
show_storage_menu() {
    while true; do
        OPTION=$(whiptail --title "$(translate "Disk and Storage Menu")" --menu "$(translate "Select an option:")" 15 60 3 \
            "1" "$(translate "Add Disk Passthrough to a VM")" \
            "2" "$(translate "Import Disk Image to a VM")" \
            "3" "$(translate "Return to Main Menu")" 3>&1 1>&2 2>&3)

        case $OPTION in
            1)
                msg_info "$(translate "Running script:") $(translate "Disk Passthrough")..."
                bash <(curl -s "$REPO_URL/scripts/disk-passthrough.sh")
                if [ $? -ne 0 ]; then
                    msg_info "$(translate "Operation cancelled.")"
                    sleep 2
                fi
                ;;
            2)
                msg_info "$(translate "Running script:") $(translate "Import Disk Image")..."
                bash <(curl -s "$REPO_URL/scripts/import-disk-image.sh")
                if [ $? -ne 0 ]; then
                    msg_info "$(translate "Operation cancelled.")"
                    sleep 2
                fi
                ;;
            3)
                return
                ;;
            *)
                return
                ;;
        esac
    done
}





# Show network menu
show_network_menu() {
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
}

# Show main menu
show_menu() {
    while true; do
        OPTION=$(whiptail --title "$(translate "Main Menu")" --menu "$(translate "Select an option:")" 15 60 5 \
            "1" "$(translate "GPUs and Coral-TPU")" \
            "2" "$(translate "Hard Drives, Disk Images, and Storage")" \
            "3" "$(translate "Network")" \
            "4" "$(translate "Settings")" \
            "5" "$(translate "Exit")" 3>&1 1>&2 2>&3)

        case $OPTION in
            1)
                show_graphics_menu
                ;;
            2)
                show_storage_menu
                ;;
            3)
                show_network_menu
                ;;
            4)
                show_config_menu
                ;;
            5)
                clear
                msg_ok "$(translate "Thank you for using ProxMenu. Goodbye!")"
                exit 0
                ;;
            *)
                msg_error "$(translate "Invalid option.")"
                sleep 2
                ;;
        esac
    done
}



# Main flow
initialize_cache
load_language
show_menu
