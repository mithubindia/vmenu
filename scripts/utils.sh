#!/bin/bash

# Repository and directory structure
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
INSTALL_DIR="/usr/local/bin"
BASE_DIR="/usr/local/share/proxmenux"
CONFIG_FILE="$BASE_DIR/config.json"
CACHE_FILE="$BASE_DIR/cache.json"
LOCAL_VERSION_FILE="$BASE_DIR/version.txt"
MENU_SCRIPT="menu.sh"
VENV_PATH="/opt/googletrans-env"

# Translation context
TRANSLATION_CONTEXT="Context: Technical message for Proxmox and IT. Translate:"

# Color and style definitions
YW='\033[33m'    # Yellow
BL='\033[36m'    # Blue
RD='\033[01;31m' # Red
BGN='\033[4;92m' # Background Green
GN='\033[32m'    # Green
CL='\033[m'      # Clear
BFR="\\r\\033[K" # Carriage return
HOLD="-"         # Separator
TAB="    "       # Tab

# Default language
LANGUAGE="${LANGUAGE:-en}"

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

# Display info message with spinner
msg_info() {
    local msg="$1"
    echo -ne "${TAB}${YW}${HOLD}${msg}${HOLD}"
    spinner &
    SPINNER_PID=$!
}

# Display success message
msg_ok() {
    if [ -n "$SPINNER_PID" ] && ps -p $SPINNER_PID > /dev/null; then 
        kill $SPINNER_PID > /dev/null
    fi
    printf "\e[?25h"
    local msg="$1"
    echo -e "${BFR}${CM}${GN}${msg}${CL}"
}

# Display error message
msg_error() {
    echo -e " ${RD}[ERROR] $1${CL}"
}

# Initialize cache
initialize_cache() {
    if [ ! -f "$CACHE_FILE" ]; then
        mkdir -p "$(dirname "$CACHE_FILE")"
        echo "{}" > "$CACHE_FILE"
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

# Check required dependencies
check_dependencies() {
    local deps=("$@")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        msg_error "Missing dependencies: ${missing[*]}"
        return 1
    fi
    
    return 0
}
