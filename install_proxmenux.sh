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
CACHE_FILE="$BASE_DIR/cache.json"
UTILS_FILE="$BASE_DIR/utils.sh"
LOCAL_VERSION_FILE="$BASE_DIR/version.txt"
MENU_SCRIPT="menu.sh"


if ! source <(curl -sSf "$UTILS_URL"); then
    echo "$(translate 'Error: Could not load utils.sh from') $UTILS_URL"
    exit 1
fi

# ==========================================================

if [ "$(id -u)" -ne 0 ]; then
    msg_error "This script must be run as root."
    exit 1
fi


show_proxmenu_logo


echo -e "${YW}To function correctly, ProxMenu needs to install the following components:${CL}"
echo -e "${TAB}- whiptail (if not already installed)"
echo -e "${TAB}- curl (if not already installed)"
echo -e "${TAB}- jq (if not already installed)"
echo -e "${TAB}- Python 3 (if not already installed)"
echo -e "${TAB}- Virtual environment for Google Translate"
echo -e "${TAB}- ProxMenu scripts and configuration files"
echo
read -p "Do you want to proceed with the installation? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    msg_warn "Installation cancelled."
    exit 1
fi


# Install dependencies =====================================

msg_info "Checking system dependencies..."


DEPS=("whiptail" "curl" "jq" "python3" "python3-venv" "python3-pip")
for pkg in "${DEPS[@]}"; do
    if ! dpkg -l | grep -qw "$pkg"; then
        msg_info "Installing $pkg..."
        if apt-get update && apt-get install -y "$pkg"; then
            msg_ok "$pkg installed successfully."
        else
            msg_error "Failed to install $pkg. Please install it manually."
            exit 1
        fi
    else
        msg_ok "$pkg is already installed."
    fi
done

# Set up virtual environment ==============================

msg_info "Setting up the virtual environment for translations..."
if [ ! -d "$VENV_PATH" ]; then
    python3 -m venv "$VENV_PATH"
    source "$VENV_PATH/bin/activate"

    if pip install --no-cache-dir googletrans==4.0.0-rc1; then
        msg_ok "Virtual environment configured and googletrans installed."
    else
        msg_error "Failed to install googletrans. Please check your internet connection."
        deactivate
        exit 1
    fi

    deactivate
else
    msg_ok "Virtual environment already configured."
fi

# Download necessary files =================================

msg_ok "Necessary directories created."
mkdir -p "$BASE_DIR"


FILES=(
    "$CACHE_FILE $REPO_URL/lang/cache.json"
    "$UTILS_FILE $REPO_URL/scripts/utils.sh"
    "$INSTALL_DIR/$MENU_SCRIPT $REPO_URL/$MENU_SCRIPT"
    "$LOCAL_VERSION_FILE $REPO_URL/version.txt"
)

for file in "${FILES[@]}"; do
    IFS=" " read -r dest url <<< "$file"
    msg_info "Downloading ${dest##*/}..."
    if wget -qO "$dest" "$url"; then
        msg_ok "${dest##*/} downloaded successfully."
    else
        msg_error "Failed to download ${dest##*/}. Check your Internet connection."
        exit 1
    fi
done


chmod +x "$INSTALL_DIR/$MENU_SCRIPT"

# Installation complete ====================================
echo
echo -e "${YW}╭─────────────────────────────────────────────────────╮${CL}"
echo -e "${YW}│${CL}    ${GN}🌟  ProxMenux has been installed successfull 🌟 ${CL}   ${YW}│${CL}"
echo -e "${YW}╰─────────────────────────────────────────────────────╯${CL}"
echo
echo -ne "${GN}"
type_text "To run  ProxMenu, simply execute this command in the console or terminal:"
echo -e "${YWB}    menu.sh${CL}"
echo



if [ -f "$BASE_DIR/install_proxmenux.sh" ]; then
    rm -f "$BASE_DIR/install_proxmenux.sh"
fi

exit 0
