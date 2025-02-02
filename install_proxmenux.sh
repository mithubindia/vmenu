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


# Try to load utils.sh from GitHub
if ! source <(curl -sSf "$UTILS_URL"); then
    echo "$(translate 'Error: Could not load utils.sh from') $UTILS_URL"
    exit 1
fi
# ==========================================================

# Verify that it's run as root
if [ "$(id -u)" -ne 0 ]; then
    msg_error "This script must be run as root."
    exit 1
fi

show_proxmenu_logo

# Display installation confirmation
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

# Check system dependencies
msg_info "Checking system dependencies..."

# Install `whiptail`
if ! command -v whiptail &> /dev/null; then
    msg_info "Installing whiptail..."
    if apt-get update && apt-get install -y whiptail; then
        msg_ok "whiptail installed successfully."
    else
        msg_error "Failed to install whiptail. Please install it manually."
        exit 1
    fi
else
    msg_ok "whiptail is already installed."
fi

# Install `curl`
if ! command -v curl &> /dev/null; then
    msg_info "Installing curl..."
    if apt-get update && apt-get install -y curl; then
        msg_ok "curl installed successfully."
    else
        msg_error "Failed to install curl. Please install it manually."
        exit 1
    fi
else
    msg_ok "curl is already installed."
fi

# Install `jq`
if ! command -v jq &> /dev/null; then
    msg_info "Installing jq..."
    if apt-get update && apt-get install -y jq; then
        msg_ok "jq installed successfully."
    else
        msg_error "Failed to install jq. Please install it manually."
        exit 1
    fi
else
    msg_ok "jq is already installed."
fi

# Install Python and virtualenv
if ! command -v python3 &> /dev/null; then
    msg_info "Installing Python 3..."
    if apt-get update && apt-get install -y python3 python3-venv python3-pip; then
        msg_ok "Python 3 installed successfully."
    else
        msg_error "Failed to install Python 3. Please install it manually."
        exit 1
    fi
else
    msg_ok "Python 3 is already installed."
fi

# Create and configure the virtual environment
msg_info "Setting up the virtual environment for translations..."
if [ ! -d "$VENV_PATH" ]; then
    python3 -m venv "$VENV_PATH"
    source "$VENV_PATH/bin/activate"
    if pip install googletrans==4.0.0-rc1; then
        msg_ok "Virtual environment configured and googletrans installed."
    else
        msg_error "Failed to configure the virtual environment or install googletrans."
        deactivate
        exit 1
    fi
    deactivate
else
    msg_ok "Virtual environment already configured."
fi

# Create necessary folders
msg_info "Creating necessary directories..."
mkdir -p "$BASE_DIR"
msg_ok "Directories created."

# Download the cache file
msg_info "Downloading the cache file..."
if wget -qO "$CACHE_FILE" "$REPO_URL/lang/cache.json"; then
    msg_ok "Cache file downloaded successfully."
else
    msg_error "Failed to download the cache file. Check the URL and your Internet connection."
    exit 1
fi

# Download utils.sh
msg_info "Downloading utils.sh..."
if wget -qO "$UTILS_FILE" "$REPO_URL/scripts/utils.sh"; then
    msg_ok "utils.sh downloaded successfully."
else
    msg_error "Failed to download utils.sh. Check the URL and your Internet connection."
    exit 1
fi

# Download the main script (menu.sh)
msg_info "Downloading the main script..."
if wget -qO "$INSTALL_DIR/$MENU_SCRIPT" "$REPO_URL/$MENU_SCRIPT"; then
    chmod +x "$INSTALL_DIR/$MENU_SCRIPT"
    msg_ok "Main script downloaded and made executable."
else
    msg_error "Failed to download the main script. Check the URL and your Internet connection."
    exit 1
fi

# Download the initial version
msg_info "Downloading version file..."
if wget -qO "$LOCAL_VERSION_FILE" "$REPO_URL/version.txt"; then
    msg_ok "Version file downloaded."
else
    msg_error "Failed to download the version file."
    exit 1
fi

# Confirmation
#msg_ok "ProxMenux has been installed successfully."
#echo -e "${GN} 🌟 Run: menu.sh as root to start the menu.${CL}"

#msg_ok "ProxMenux has been installed successfully."
echo
echo -e "${YW}╭─────────────────────────────────────────────────────╮${CL}"
echo -e "${YW}│${CL}    ${GN}🌟  ProxMenux has been installed successfull 🌟 ${CL}   ${YW}│${CL}"
echo -e "${YW}╰─────────────────────────────────────────────────────╯${CL}"
echo
echo -ne "${GN}"
type_text "To run  ProxMenu, simply execute this command in the console or terminal:"
echo -e "${YWB}    menu.sh${CL}"
echo


# Exit
exit 0
