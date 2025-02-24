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
# This script provides a set of utility functions used across
# ProxMenux to facilitate Proxmox VE management.
#
# - Defines color codes for consistent output formatting.
# - Implements a spinner-based loading animation.
# - Provides standardized message functions (info, success, error, warning).
# - Handles translation with caching to reduce API requests.
# - Initializes and manages a local cache for improved performance.
# - Loads language settings from a configuration file.
#
# These utilities ensure a streamlined and uniform user experience
# across different ProxMenux scripts.
# ==========================================================

# Repository and directory structure
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
INSTALL_DIR="/usr/local/bin"
BASE_DIR="/usr/local/share/proxmenux"
CONFIG_FILE="$BASE_DIR/config.json"
CACHE_FILE="$BASE_DIR/cache.json"
LOCAL_VERSION_FILE="$BASE_DIR/version.txt"
MENU_SCRIPT="menu"
VENV_PATH="/opt/googletrans-env"


# Translation context
TRANSLATION_CONTEXT="Context: Technical message for Proxmox and IT. Translate:"

# Color and style definitions
YW="\033[33m"
YWB="\033[1;33m"
GN="\033[1;92m"
RD="\033[01;31m"
CL="\033[m"
BL="\033[36m"
BOLD="\033[1m"
BFR="\\r\\033[K"
HOLD="-"
BOR=" | "
CM="${GN}✓${CL}"
TAB="    "  


# Create and display spinner
spinner() {
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local spin_i=0
    local interval=0.1
    printf "\e[?25l"
    
    local color="${YW}"
    
    while true; do
        printf "\r ${color}%s${CL}" "${frames[spin_i]}"
        spin_i=$(( (spin_i + 1) % ${#frames[@]} ))
        sleep "$interval"
    done
}


# Function to simulate typing effect
type_text() {
    local text="$1"
    local delay=0.05
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep $delay
    done
    echo
}


# Stop the spinner if it is active
cleanup() {
    if [ -n "$spinner_pid" ]; then
        kill $spinner_pid 2>/dev/null
    fi
    echo -e "\n$(translate "Operation canceled by the user.")"
    exit 1
}


# Display info message with spinner
msg_info() {
    local msg="$1"
    echo -ne "${TAB}${YW}${HOLD}${msg}"
    spinner &
    SPINNER_PID=$!
}


# Display info2 message
msg_info2() {
    local msg="$1"
    echo -e "${TAB}${BOLD}${YW}${HOLD}${msg}${CL}"
}

# Display success message
msg_success() {
    if [ -n "$SPINNER_PID" ] && ps -p $SPINNER_PID > /dev/null; then 
        kill $SPINNER_PID > /dev/null
    fi
    printf "\e[?25h"
    local msg="$1"
    echo -e "${TAB}${BOLD}${BL}${HOLD}${msg}${CL}"
    echo -e ""
}


# Display title script
msg_title() {
    local msg="$1"
    echo -e "\n"
    echo -e "${TAB}${BOLD}${HOLD}${BOR}${msg}${BOR}${HOLD}${CL}"
}

# Display warning or highlighted information message
msg_warn() {
    if [ -n "$SPINNER_PID" ] && ps -p $SPINNER_PID > /dev/null; then 
        kill $SPINNER_PID > /dev/null
    fi
    printf "\e[?25h"
    local msg="$1"
    echo -e "${BFR}${TAB}${NV}${CL} ${YWB}${msg}${CL}"
}


# Display success message
msg_ok() {
    if [ -n "$SPINNER_PID" ] && ps -p $SPINNER_PID > /dev/null; then 
        kill $SPINNER_PID > /dev/null
    fi
    printf "\e[?25h"
    local msg="$1"
    echo -e "${BFR}${TAB}${CM}${GN}${msg}${CL}"
}


# Display error message
msg_error() {
    if [ -n "$SPINNER_PID" ] && ps -p $SPINNER_PID > /dev/null; then 
        kill $SPINNER_PID > /dev/null
    fi
    printf "\e[?25h"
    local msg="$1"
    echo -e "${BFR}${TAB}${RD}[ERROR] ${msg}${CL}"
}
    

# Initialize cache
initialize_cache() {
    if [ ! -f "$CACHE_FILE" ]; then
        mkdir -p "$(dirname "$CACHE_FILE")"
        echo "{}" > "$CACHE_FILE"
    fi
}

load_language() {
    if [ -f "$CONFIG_FILE" ]; then
        LANGUAGE=$(jq -r '.language' "$CONFIG_FILE")
    fi
}

# Translation with cache and predefined terms
translate() {
    local text="$1"
    local dest_lang="$LANGUAGE"

    # If the language is English, return the original text without translating or caching
    if [ "$dest_lang" = "en" ]; then
        echo "$text"
        return
    fi

    if [ ! -s "$CACHE_FILE" ] || ! jq -e . "$CACHE_FILE" > /dev/null 2>&1; then
        echo "{}" > "$CACHE_FILE"
    fi

    local cached_translation=$(jq -r --arg text "$text" --arg lang "$dest_lang" '.[$text][$lang] // .[$text]["notranslate"] // empty' "$CACHE_FILE")
    if [ -n "$cached_translation" ]; then
        echo "$cached_translation"
        return
    fi

    if [ ! -d "$VENV_PATH" ]; then
        echo "$text"
        return
    fi

    source "$VENV_PATH/bin/activate"
    local translated
    translated=$(python3 -c "
from googletrans import Translator
import sys, json, re

def translate_text(text, dest_lang):
    translator = Translator()
    context = '$TRANSLATION_CONTEXT'
    try:
        full_text = context + ' ' + text
        result = translator.translate(full_text, dest=dest_lang).text
        # Remove context and any leading/trailing whitespace
        translated = re.sub(r'^.*?(Translate:|Traducir:|Traduire:|Übersetzen:|Tradurre:|Traduzir:|翻译:|翻訳:)', '', result, flags=re.IGNORECASE | re.DOTALL).strip()
        translated = re.sub(r'^.*?(Context:|Contexto:|Contexte:|Kontext:|Contesto:|上下文：|コンテキスト：).*?:', '', translated, flags=re.IGNORECASE | re.DOTALL).strip()
        return json.dumps({'success': True, 'text': translated})
    except Exception as e:
        return json.dumps({'success': False, 'error': str(e)})

print(translate_text('$text', '$dest_lang'))
")
    deactivate

    local translation_result=$(echo "$translated" | jq -r '.')
    local success=$(echo "$translation_result" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        translated=$(echo "$translation_result" | jq -r '.text')
        
        # Additional cleaning step
        translated=$(echo "$translated" | sed -E 's/^(Context:|Contexto:|Contexte:|Kontext:|Contesto:|上下文：|コンテキスト：).*?(Translate:|Traducir:|Traduire:|Übersetzen:|Tradurre:|Traduzir:|翻译:|翻訳:)//gI' | sed 's/^ *//; s/ *$//')
        
        # Only cache if the language is not English
        if [ "$dest_lang" != "en" ]; then
            local temp_cache=$(mktemp)
            jq --arg text "$text" --arg lang "$dest_lang" --arg translated "$translated" '
                if .[$text] == null then .[$text] = {} else . end |
                .[$text][$lang] = $translated
            ' "$CACHE_FILE" > "$temp_cache" && mv "$temp_cache" "$CACHE_FILE"
        fi
        
        echo "$translated"
    else
        local error=$(echo "$translation_result" | jq -r '.error')
        echo "$text"
    fi
}



show_proxmenux_logo() {
clear

if [[ -z "$SSH_TTY" && -z "$(who am i | awk '{print $NF}' | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}')" ]]; then

        # Logo for terminal noVNC

        BOLD="\033[1m"
        NEON_PURPLE_BLUE="\033[38;5;99m"
        WHITE="\033[38;5;15m"
        RESET="\033[0m"

        # Logo ASCII 
        LOGO=$(cat << "EOF"
        \e[0m\e[38;2;61;61;61m▆\e[38;2;60;60;60m▄\e[38;2;54;54;54m▂\e[0m \e[38;2;0;0;0m             \e[0m \e[38;2;54;54;54m▂\>
        \e[38;2;59;59;59;48;2;62;62;62m▏  \e[38;2;61;61;61;48;2;37;37;37m▇\e[0m\e[38;2;60;60;60m▅\e[38;2;56;56;56m▃\e[38;2;37>
        \e[38;2;59;59;59;48;2;62;62;62m▏  \e[0m\e[7m\e[38;2;61;61;61m▂\e[0m\e[38;2;62;62;62;48;2;61;61;61m┈\e[48;2;62;62;62m >
        \e[38;2;59;59;59;48;2;62;62;62m▏  \e[0m\e[38;2;32;32;32m▏\e[7m\e[38;2;39;39;39m▇\e[38;2;57;57;57m▅\e[38;2;60;60;60m▃\>
        \e[38;2;59;59;59;48;2;62;62;62m▏  \e[0m\e[38;2;32;32;32m▏\e[0m \e[38;2;203;63;2m▄\e[38;2;147;45;1m▂\e[0m \e[7m\e[38;2>
        \e[38;2;59;59;59;48;2;62;62;62m▏  \e[0m\e[38;2;32;32;32m▏\e[7m\e[38;2;121;37;1m▉\e[0m\e[38;2;0;0;0;48;2;231;72;3m  \e>
        \e[38;2;59;59;59;48;2;62;62;62m▏  \e[0m\e[38;2;32;32;32m▏\e[0m \e[7m\e[38;2;190;59;2m▅\e[38;2;216;67;2m▃\e[38;2;225;7>
        \e[38;2;59;59;59;48;2;62;62;62m▏  \e[0m\e[38;2;32;32;32m▏   \e[0m \e[7m\e[38;2;172;53;1m▆\e[38;2;213;66;2m▄\e[38;2;21>
        \e[38;2;59;59;59;48;2;62;62;62m▏  \e[0m\e[38;2;32;32;32m▏             \e[0m \e[38;2;0;0;0;48;2;231;72;3m  \e[38;2;231>
        \e[7m\e[38;2;52;52;52m▆\e[38;2;59;59;59m▄\e[38;2;61;61;61m▂\e[0m\e[38;2;31;31;31m▏             \e[0m \e[7m\e[38;2;228>
        EOF
        )

        TEXT=(
            ""
            ""
            "${BOLD}ProxMenux${RESET}"
            ""
            "${BOLD}${NEON_PURPLE_BLUE}A menu-driven script for${RESET}"
            "${BOLD}${NEON_PURPLE_BLUE}Proxmox VE management${RESET}"
            ""
            ""
            ""
            ""
        )

        mapfile -t logo_lines <<< "$LOGO"

        for i in {0..9}; do
            echo -e "${logo_lines[i]}  ${WHITE}│${RESET}  ${TEXT[i]}"
        done

else


        # Logo for terminal SSH

        DARK_GRAY="\033[38;5;244m"   
        ORANGE="\033[38;5;202m"     
        BOLD="\033[1m"              
        NEON_PURPLE_BLUE="\033[38;5;99m"  
        WHITE="\033[38;5;15m" 
        RESET="\033[0m"        

        TEXT=(
            ""
            ""
            ""
            ""
            "${BOLD}ProxMenux${RESET}"
            ""
            "${BOLD}${NEON_PURPLE_BLUE}A menu-driven script for${RESET}"
            "${BOLD}${NEON_PURPLE_BLUE}Proxmox VE management${RESET}"
            ""
            ""
            ""
            ""
            ""
            ""
        )

        LOGO=(
            "${DARK_GRAY}░░░░                     ░░░░${RESET}"
            "${DARK_GRAY}░░░░░░░               ░░░░░░ ${RESET}"
            "${DARK_GRAY}░░░░░░░░░░░       ░░░░░░░    ${RESET}"
            "${DARK_GRAY}░░░░    ░░░░░░ ░░░░░░      ${ORANGE}░░${RESET}"
            "${DARK_GRAY}░░░░       ░░░░░░░      ${ORANGE}░░▒▒▒${RESET}"
            "${DARK_GRAY}░░░░         ░░░     ${ORANGE}░▒▒▒▒▒▒▒${RESET}"
            "${DARK_GRAY}░░░░   ${ORANGE}▒▒▒░       ░▒▒▒▒▒▒▒▒▒▒${RESET}"
            "${DARK_GRAY}░░░░   ${ORANGE}░▒▒▒▒▒   ▒▒▒▒▒░░  ▒▒▒▒${RESET}"
            "${DARK_GRAY}░░░░     ${ORANGE}░░▒▒▒▒▒▒▒░░     ▒▒▒▒${RESET}"
            "${DARK_GRAY}░░░░         ${ORANGE}░░░         ▒▒▒▒${RESET}"
            "${DARK_GRAY}░░░░                     ${ORANGE}▒▒▒▒${RESET}"
            "${DARK_GRAY}░░░░                     ${ORANGE}▒▒▒░${RESET}"
            "${DARK_GRAY}  ░░                     ${ORANGE}░░  ${RESET}"
        )

        for i in {0..12}; do
            echo -e "${LOGO[i]}  ${WHITE}│${RESET}  ${TEXT[i]}"
        done

fi

}
