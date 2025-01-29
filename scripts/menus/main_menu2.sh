#!/bin/bash

# Configuration
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
BASE_DIR="/usr/local/share/proxmenux"
CONFIG_FILE="$BASE_DIR/config.json"
CACHE_FILE="$BASE_DIR/cache.json"
VENV_PATH="/opt/googletrans-env"
LOCAL_VERSION_FILE="$BASE_DIR/version.txt"
TRANSLATION_CONTEXT="Context: Technical message for Proxmox and IT. Translate:"

# Output colors
YW="\033[33m"; GN="\033[1;92m"; RD="\033[01;31m"; CL="\033[m"
msg_info() { echo -e " ${YW}[INFO] $1${CL}"; }
msg_ok() { echo -e " ${GN}[OK] $1${CL}"; }
msg_error() { echo -e " ${RD}[ERROR] $1${CL}"; }

# Create necessary directories
mkdir -p "$BASE_DIR"

# Initialize cache
initialize_cache() {
    if [ ! -f "$CACHE_FILE" ]; then
        echo "{}" > "$CACHE_FILE"
        return
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





# Initialize language configuration
initialize_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        LANGUAGE=$(whiptail --title "$(translate "Select Language")" --menu "$(translate "Choose a language for the menu:")" 20 60 12 \
            "en" "$(translate "English (Recommended)")" \
            "es" "$(translate "Spanish")" \
            "fr" "$(translate "French")" \
            "de" "$(translate "German")" \
            "it" "$(translate "Italian")" \
            "pt" "$(translate "Portuguese")" \
            "zh-cn" "$(translate "Simplified Chinese")" \
            "ja" "$(translate "Japanese")" 3>&1 1>&2 2>&3)

        if [ -z "$LANGUAGE" ]; then
            msg_error "$(translate "No language selected. Exiting.")"
            exit 1
        fi

        echo "{\"language\": \"$LANGUAGE\"}" > "$CONFIG_FILE"
        msg_ok "$(translate "Initial language set to:") $LANGUAGE"
    fi
}

# Load language from JSON file
load_language() {
    if [ -f "$CONFIG_FILE" ]; then
        LANGUAGE=$(jq -r '.language' "$CONFIG_FILE")
    else
        initialize_config
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
    exec "$0"
}

# Function to check and perform updates
check_updates() {
    # Obtener la versión remota directamente
    REMOTE_VERSION=$(curl -fsSL "$REPO_URL/version.txt")

    # Si falla la descarga o la versión remota es vacía, abortar
    if [ -z "$REMOTE_VERSION" ]; then
        msg_error "$(translate "Error getting remote version.")"
        return 1
    fi

    # Leer la versión local desde el archivo (o asignar "0.0.0" si no existe)
    LOCAL_VERSION="0.0.0"
    [ -f "$LOCAL_VERSION_FILE" ] && LOCAL_VERSION=$(<"$LOCAL_VERSION_FILE")

    # Si la versión remota y la local son diferentes, preguntar al usuario si desea actualizar
    if [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
        if whiptail --title "$(translate "Update Available")" --yesno "$(translate "New version available") ($REMOTE_VERSION)" 10 60; then
            perform_update "$REMOTE_VERSION"
        else
            msg_info "$(translate "Update postponed. You can update later from the menu.")"
        fi
    fi
}


# Function to perform the update
perform_update() {
    REMOTE_VERSION=$1
    msg_info "$(translate "Updating to version") $REMOTE_VERSION..."

    # Si se requiere una reinstalación completa
    if [ ! -d "$VENV_PATH" ]; then
        whiptail --title "$(translate "Major Update")" --msgbox "$(translate "To improve experience and functionality, this new version of ProxMenu requires a complete reinstallation. The reinstallation process will start automatically.")" 10 60
        
        msg_info "$(translate "Starting ProxMenu reinstallation...")"

        if bash <(curl -fsSL "$REPO_URL/install_proxmenux.sh"); then
            msg_ok "$(translate "ProxMenu has been updated and reinstalled successfully.")"
            whiptail --title "$(translate "Reinstallation Completed")" --msgbox "$(translate "ProxMenu has been updated and reinstalled successfully. The program will restart now.")" 10 60
            exec "$0"
        else
            msg_error "$(translate "Error during ProxMenu reinstallation.")"
            whiptail --title "$(translate "Reinstallation Error")" --msgbox "$(translate "An error occurred during ProxMenu reinstallation. Please try again later or contact support.")" 10 60
            exit 1
        fi
    fi

    # Descarga y reemplazo de archivos clave
    curl -fsSL "$REPO_URL/menu.sh" -o /usr/local/bin/menu.sh
    curl -fsSL "$REPO_URL/lang/cache.json" -o "$BASE_DIR/cache.json"

    chmod +x /usr/local/bin/menu.sh
    echo "$REMOTE_VERSION" > "$LOCAL_VERSION_FILE"

    msg_ok "$(translate "Update completed to version") $REMOTE_VERSION"

    exec /usr/local/bin/menu.sh
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
