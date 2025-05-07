#!/bin/bash

# ==========================================================
# ProxMenu - A menu-driven script for Proxmox VE management
# ==========================================================
# Author      : MacRimi
# Copyright   : (c) 2024 MacRimi
# License     : MIT (https://raw.githubusercontent.com/MacRimi/ProxMenux/main/LICENSE)
# Version     : 1.2
# Last Updated: 04/04/2025
# ==========================================================
# Description:
# This script installs and configures ProxMenux, a menu-driven
# tool for managing Proxmox VE.
#
# - Ensures the script is run with root privileges.
# - Displays an installation confirmation prompt.
# - Installs required dependencies:
# - whiptail (for interactive terminal menus)
# - curl (for downloading remote files)
# - jq (for handling JSON data)
# - Python 3 and virtual environment (for translations)
# - Configures the Python virtual environment and installs googletrans.
# - Creates necessary directories for storing ProxMenux data.
# - Downloads required files from GitHub, including:
# - Cache file (`cache.json`) for translation caching.
# - Utility script (`utils.sh`) for core functions.
# - Main script (`menu.sh`) to launch ProxMenux.
# - Sets correct permissions for execution.
# - Displays final instructions on how to start ProxMenux.
#
# This installer ensures a smooth setup process and prepares
# the system for running ProxMenux efficiently.
# ==========================================================


# Configuration ============================================
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
UTILS_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main/scripts/utils.sh"
INSTALL_DIR="/usr/local/bin"
BASE_DIR="/usr/local/share/proxmenux"
CONFIG_FILE="$BASE_DIR/config.json"
CACHE_FILE="$BASE_DIR/cache.json"
UTILS_FILE="$BASE_DIR/utils.sh"
LOCAL_VERSION_FILE="$BASE_DIR/version.txt"
MENU_SCRIPT="menu"
VENV_PATH="/opt/googletrans-env"

# Source utils.sh for common functions and styles
if ! source <(curl -sSf "$UTILS_URL"); then
    echo "Error: Could not load utils.sh from $UTILS_URL"
    exit 1
fi

# ==========================================================

update_config() {
    local component="$1"
    local status="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # List of components we want to track
    local tracked_components=("whiptail" "dialog" "curl" "jq" "python3" "python3-venv" "python3-pip" "virtual_environment" "pip" "googletrans")
    
    # Check if the component is in the list of tracked components
    if [[ " ${tracked_components[@]} " =~ " ${component} " ]]; then
        mkdir -p "$(dirname "$CONFIG_FILE")"


        if [ ! -f "$CONFIG_FILE" ]; then
            echo '{}' > "$CONFIG_FILE"
        fi
        
        tmp=$(mktemp)
        jq --arg comp "$component" --arg stat "$status" --arg time "$timestamp" \
           '.[$comp] = {status: $stat, timestamp: $time}' "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
    fi
}


show_progress() {
    local step="$1"
    local total="$2"
    local message="$3"
    
    echo -e "\n${BOLD}${BL}${TAB}Installing ProxMenu: Step $step of $total${CL}"
    echo
    msg_info2 "$message"
}


# # Main installation function =============================

install_proxmenu() {
    local total_steps=4
    local current_step=1

   # Step 1: Check and install system dependencies

   show_progress $current_step $total_steps "Checking system dependencies"


   if ! dpkg -l | grep -qw "jq"; then
       msg_info "Installing jq..."
       apt-get update > /dev/null 2>&1
       if apt-get install -y jq > /dev/null 2>&1; then
           msg_ok "jq installed successfully."
           update_config "jq" "installed"
       else
           msg_error "Failed to install jq. Please install it manually."
           update_config "jq" "failed"
           return 1
       fi
   else
       msg_ok "jq is already installed."
       update_config "jq" "already_installed"
   fi


   DEPS=("whiptail" "dialog" "curl" "python3" "python3-venv" "python3-pip")
   for pkg in "${DEPS[@]}"; do
       if ! dpkg -l | grep -qw "$pkg"; then
           msg_info "Installing $pkg..."
           if apt-get install -y "$pkg" > /dev/null 2>&1; then
               msg_ok "$pkg installed successfully."
               update_config "$pkg" "installed"
           else
               msg_error "Failed to install $pkg. Please install it manually."
               update_config "$pkg" "failed"
               return 1
           fi
       else
           msg_ok "$pkg is already installed."
           update_config "$pkg" "already_installed"
       fi
   done

   ((current_step++))


    # Step 2: Set up virtual environment

    show_progress $current_step $total_steps "Setting up virtual environment for translate"
    if [ ! -d "$VENV_PATH" ] || [ ! -f "$VENV_PATH/bin/activate" ]; then
        msg_info "Creating the virtual environment..."
        python3 -m venv --system-site-packages "$VENV_PATH" > /dev/null 2>&1

        if [ ! -f "$VENV_PATH/bin/activate" ]; then
            msg_error "Failed to create virtual environment. Please check your Python installation."
            update_config "virtual_environment" "failed"
            return 1
        else
            msg_ok "Virtual environment created successfully."
            update_config "virtual_environment" "created"
        fi
    else
        msg_ok "Virtual environment already exists."
        update_config "virtual_environment" "already_exists"
    fi
    source "$VENV_PATH/bin/activate"
    ((current_step++))

    # Step 3: Install and upgrade pip and googletrans

    show_progress $current_step $total_steps "Installing and upgrading pip and googletrans"
    msg_info "Upgrading pip..."
    if pip install --upgrade pip > /dev/null 2>&1; then
        msg_ok "Pip upgraded successfully."
        update_config "pip" "upgraded"
    else
        msg_error "Failed to upgrade pip."
        update_config "pip" "upgrade_failed"
        return 1
    fi

    msg_info "Installing googletrans..."
    if pip install --break-system-packages --no-cache-dir googletrans==4.0.0-rc1 > /dev/null 2>&1; then
        msg_ok "Googletrans installed successfully."
        update_config "googletrans" "installed"
    else
        msg_error "Failed to install googletrans. Please check your internet connection."
        update_config "googletrans" "failed"
        deactivate
        return 1
    fi
    deactivate
    ((current_step++))

    # Step 4: Download necessary files

    show_progress $current_step $total_steps "Downloading necessary files"
    mkdir -p "$BASE_DIR"
    FILES=(
        "$CACHE_FILE $REPO_URL/json/cache.json"
        "$UTILS_FILE $REPO_URL/scripts/utils.sh"
        "$INSTALL_DIR/$MENU_SCRIPT $REPO_URL/$MENU_SCRIPT"
        "$LOCAL_VERSION_FILE $REPO_URL/version.txt"
    )
    for file in "${FILES[@]}"; do
        IFS=" " read -r dest url <<< "$file"
        msg_info "Downloading ${dest##*/}..."
        sleep 2
        if wget -qO "$dest" "$url"; then
            msg_ok "${dest##*/} downloaded successfully."
        else
            msg_error "Failed to download ${dest##*/}. Check your Internet connection."
            return 1
        fi
    done
    ((current_step++))

    # Final setup

    chmod +x "$INSTALL_DIR/$MENU_SCRIPT"



# Installation complete ====================================
echo
#echo -e "${YW}╭─────────────────────────────────────────────────────╮${CL}"
#echo -e "${YW}│${CL}    ${GN}🌟  ProxMenux has been installed successfull 🌟 ${CL}   ${YW}│${CL}"
#echo -e "${YW}╰─────────────────────────────────────────────────────╯${CL}"
msg_title "ProxMenux has been installed successfull"
echo
echo -ne "${GN}"
type_text "To run  ProxMenu, simply execute this command in the console or terminal:"
echo -e "${YWB}    menu${CL}"
echo


}

# Main execution  ==========================================
if [ "$(id -u)" -ne 0 ]; then
    msg_error "This script must be run as root."
    exit 1
fi

clear
show_proxmenux_logo

echo
echo -e "${BOLD}${YW}To function correctly, ProxMenu needs to install the following components:${CL}"
echo -e "${TAB}- whiptail (if not already installed)"
echo -e "${TAB}- curl (if not already installed)"
echo -e "${TAB}- jq (if not already installed)"
echo -e "${TAB}- Python 3 (if not already installed)"
echo -e "${TAB}- Virtual environment for Google Translate"
echo -e "${TAB}- ProxMenu scripts and configuration files"
echo
read -p "Do you want to proceed with the installation? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    install_proxmenu
else
    msg_warn "Installation cancelled."
    exit 1
fi
