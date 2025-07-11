#!/usr/bin/env bash

# Configuration ============================================
REPO_URL="https://raw.githubusercontent.com/mithubindia/vmenu/main"
BASE_DIR="/usr/local/share/vmenu"
UTILS_FILE="$BASE_DIR/utils.sh"
VENV_PATH="/opt/googletrans-env"

if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
fi
load_language
initialize_cache


get_external_backup_mount_point() {
    local BACKUP_MOUNT_FILE="/usr/local/share/proxmenux/last_backup_mount.txt"
    local STORAGE_REPO="$REPO_URL/scripts/backup_restore"
    local MOUNT_POINT

    if [[ -f "$BACKUP_MOUNT_FILE" ]]; then
        MOUNT_POINT=$(head -n1 "$BACKUP_MOUNT_FILE" | tr -d '\r\n' | xargs)
        >&2 echo "DEBUG: Valor MOUNT_POINT='$MOUNT_POINT'"
        if [[ ! -d "$MOUNT_POINT" ]]; then
            msg_error "Mount point does not exist: $MOUNT_POINT"
            rm -f "$BACKUP_MOUNT_FILE"
            return 1
        fi
        if ! mountpoint -q "$MOUNT_POINT"; then
            msg_error "Mount point is not mounted: $MOUNT_POINT"
            rm -f "$BACKUP_MOUNT_FILE"
            return 1
        fi
 
        echo "$MOUNT_POINT"
        return 0
    else
        source <(curl -s "$STORAGE_REPO/mount_disk_host_bk.sh")
       MOUNT_POINT=$(mount_disk_host_bk)
        [[ -z "$MOUNT_POINT" ]] && msg_error "$(translate "No disk mounted.")" && return 1
        echo "$MOUNT_POINT"
        return 0
    fi
}



# === Host Backup Main Menu ===
host_backup_menu() {
    while true; do
        local CHOICE
        CHOICE=$(dialog --backtitle "vmenu" \
            --title "$(translate 'Host Backup')" \
            --menu "\n$(translate 'Select backup option:')" 22 70 12 \
            ""         "$(translate '--- FULL BACKUP ---')" \
            1 "$(translate 'Full backup to Virtuliservmenu Backup Server (PBS)')" \
            2 "$(translate 'Full backup with BorgBackup')" \
            3 "$(translate 'Full backup to local .tar.gz')" \
            ""         "$(translate '--- CUSTOM BACKUP ---')" \
            4 "$(translate 'Custom backup to PBS')" \
            5 "$(translate 'Custom backup with BorgBackup')" \
            6 "$(translate 'Custom backup to local .tar.gz')" \
            0 "$(translate 'Return')" \
            3>&1 1>&2 2>&3) || return 0

        case "$CHOICE" in
            1) backup_full_pbs_root ;;
            2) backup_with_borg "/boot/efi /etc/pve /etc/network /var/lib/pve-cluster /root /etc/ssh /home /usr/local/bin /etc/cron.d /etc/systemd/system /var/lib/vz" ;;
            3) backup_to_local_tar "/boot/efi /etc/pve /etc/network /var/lib/pve-cluster /root /etc/ssh /home /usr/local/bin /etc/cron.d /etc/systemd/system /var/lib/vz" ;;
            4) custom_backup_menu backup_to_pbs ;;
            5) custom_backup_menu backup_with_borg ;;
            6) custom_backup_menu backup_to_local_tar ;;
            0) break ;;
        esac
    done
}



# === Menu checklist for custom backup ===
custom_backup_menu() {
    declare -A BACKUP_PATHS=(
        [etc-pve]="/etc/pve"
        [etc-network]="/etc/network"
        [var-lib-pve-cluster]="/var/lib/pve-cluster"
        [root-dir]="/root"
        [etc-ssh]="/etc/ssh"
        [home]="/home"
        [local-bin]="/usr/local/bin"
        [cron]="/etc/cron.d"
        [custom-systemd]="/etc/systemd/system"
        [var-lib-vz]="/var/lib/vz"
    )
    local CHECKLIST_OPTIONS=()
    for KEY in "${!BACKUP_PATHS[@]}"; do
        DIR="${BACKUP_PATHS[$KEY]}"
        CHECKLIST_OPTIONS+=("$KEY" "$DIR" "off")
    done

    SELECTED_KEYS=$(dialog --separate-output --checklist \
        "$(translate 'Select directories to backup:')" 22 70 12 \
        "${CHECKLIST_OPTIONS[@]}" \
        3>&1 1>&2 2>&3) || return 1

    local BACKUP_DIRS=()
    for KEY in $SELECTED_KEYS; do
        BACKUP_DIRS+=("${BACKUP_PATHS[$KEY]}")
    done


#    "$1" "${BACKUP_DIRS[*]}"
     "$1" "${BACKUP_DIRS[@]}"


}











configure_pbs_repository() {
local PBS_REPO_FILE="/usr/local/share/proxmenux/pbs-repo.conf"
local PBS_PASS_FILE="/usr/local/share/proxmenux/pbs-pass.txt"
local PBS_TOKEN_FILE="/usr/local/share/proxmenux/pbs-token.txt"
local PBS_MANUAL_CONFIGS="/usr/local/share/proxmenux/pbs-manual-configs.txt"

[[ ! -f "$PBS_MANUAL_CONFIGS" ]] && touch "$PBS_MANUAL_CONFIGS"

local PBS_CONFIGS=()
local PBS_SOURCES=()
local PBS_USERNAMES=()

if [[ -f "/etc/pve/storage.cfg" ]]; then
    local current_pbs="" server="" datastore="" username=""
    
    while IFS= read -r line; do
        if [[ $line =~ ^pbs:\ (.+)$ ]]; then
            if [[ -n "$current_pbs" && -n "$server" && -n "$datastore" && -n "$username" ]]; then
                PBS_CONFIGS+=("$current_pbs|$username@$server:$datastore")
                PBS_SOURCES+=("proxmox|$current_pbs")
                PBS_USERNAMES+=("$username")
            fi
            current_pbs="${BASH_REMATCH[1]}"
            server="" datastore="" username=""
        elif [[ -n "$current_pbs" ]]; then
            if [[ $line =~ ^[[:space:]]*server[[:space:]]+(.+)$ ]]; then
                server="${BASH_REMATCH[1]}"
            elif [[ $line =~ ^[[:space:]]*datastore[[:space:]]+(.+)$ ]]; then
                datastore="${BASH_REMATCH[1]}"
            elif [[ $line =~ ^[[:space:]]*username[[:space:]]+(.+)$ ]]; then
                username="${BASH_REMATCH[1]}"
            elif [[ $line =~ ^[a-zA-Z]+: ]]; then
                if [[ -n "$server" && -n "$datastore" && -n "$username" ]]; then
                    PBS_CONFIGS+=("$current_pbs|$username@$server:$datastore")
                    PBS_SOURCES+=("proxmox|$current_pbs")
                    PBS_USERNAMES+=("$username")
                fi
                current_pbs=""
            fi
        fi
    done < "/etc/pve/storage.cfg"
    
    if [[ -n "$current_pbs" && -n "$server" && -n "$datastore" && -n "$username" ]]; then
        PBS_CONFIGS+=("$current_pbs|$username@$server:$datastore")
        PBS_SOURCES+=("proxmox|$current_pbs")
        PBS_USERNAMES+=("$username")
    fi
fi

if [[ -f "$PBS_MANUAL_CONFIGS" ]]; then
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            PBS_CONFIGS+=("$line")
            local name="${line%%|*}"
            PBS_SOURCES+=("manual|$name")
            PBS_USERNAMES+=("")
        fi
    done < "$PBS_MANUAL_CONFIGS"
fi

local menu_options=()
local i=1

for j in "${!PBS_CONFIGS[@]}"; do
    local config="${PBS_CONFIGS[$j]}"
    local source="${PBS_SOURCES[$j]}"
    local name="${config%%|*}"
    local repo="${config##*|}"
    local source_type="${source%%|*}"

    if [[ "$source_type" == "proxmox" ]]; then
        menu_options+=("$i" " $name ($repo) [Virtuliservmenu]")
    else
        menu_options+=("$i" " $name ($repo) [Manual]")
    fi
    ((i++))
done

menu_options+=("" "")
menu_options+=("$i" "\Z4\Zb $(translate 'Configure new PBS')\Zn")
local choice
choice=$(dialog --colors --backtitle "vmenu" --title "PBS Server Selection" \
--menu "$(translate 'Select PBS server for this backup:')" 22 70 12 "${menu_options[@]}" 3>&1 1>&2 2>&3) || return 1

if [[ $choice -eq $i ]]; then
    configure_pbs_manually || return 1
else
    local selected_config="${PBS_CONFIGS[$((choice-1))]}"
    local selected_source="${PBS_SOURCES[$((choice-1))]}"
    local selected_username="${PBS_USERNAMES[$((choice-1))]}"
    local pbs_name="${selected_config%%|*}"
    local source_type="${selected_source%%|*}"
    PBS_REPO="${selected_config##*|}"
    
    {
        mkdir -p "$(dirname "$PBS_REPO_FILE")"
        echo "$PBS_REPO" > "$PBS_REPO_FILE"
    } >/dev/null 2>&1
    
    local password_found=false
    if [[ "$source_type" == "proxmox" ]]; then
        local password_file="/etc/pve/priv/storage/${pbs_name}.pw"
        
        if [[ -f "$password_file" ]]; then
            local auth_content
            auth_content=$(<"$password_file")
            

            [[ -f "$PBS_PASS_FILE" ]] && rm "$PBS_PASS_FILE"
            [[ -f "$PBS_TOKEN_FILE" ]] && rm "$PBS_TOKEN_FILE"
            

            if [[ "$selected_username" == *"@pbs!"* ]]; then

                echo "$auth_content" > "$PBS_PASS_FILE"
                chmod 600 "$PBS_PASS_FILE"
                password_found=true
                dialog --backtitle "vmenu" --title "PBS Selected" --msgbox "$(translate 'Using Virtuliservmenu PBS:') $pbs_name

$(translate 'Repository:') $PBS_REPO
$(translate 'Authentication:') PBS Cloud Token
$(translate 'Token ID:') $selected_username" 15 80
            elif [[ "$auth_content" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
                local full_token="${selected_username}:${auth_content}"
                echo "$full_token" > "$PBS_TOKEN_FILE"
                chmod 600 "$PBS_TOKEN_FILE"
                password_found=true
                dialog --backtitle "vmenu" --title "PBS Selected" --msgbox "$(translate 'Using Virtuliservmenu PBS:') $pbs_name

$(translate 'Repository:') $PBS_REPO
$(translate 'Authentication:') API Token
$(translate 'Token ID:') $selected_username" 15 80
            elif [[ "$auth_content" == *":"* ]]; then
                echo "$auth_content" > "$PBS_TOKEN_FILE"
                chmod 600 "$PBS_TOKEN_FILE"
                password_found=true
                dialog --backtitle "vmenu" --title "PBS Selected" --msgbox "$(translate 'Using Virtuliservmenu PBS:') $pbs_name

$(translate 'Repository:') $PBS_REPO
$(translate 'Authentication:') API Token (Complete)" 12 80
            else
                echo "$auth_content" > "$PBS_PASS_FILE"
                chmod 600 "$PBS_PASS_FILE"
                password_found=true
                dialog --backtitle "vmenu" --title "PBS Selected" --msgbox "$(translate 'Using Virtuliservmenu PBS:') $pbs_name

$(translate 'Repository:') $PBS_REPO
$(translate 'Authentication:') Password" 12 80
            fi
        fi
    else
        local manual_pass_file="/usr/local/share/proxmenux/pbs-pass-${pbs_name}.txt"
        if [[ -f "$manual_pass_file" ]]; then
            [[ -f "$PBS_TOKEN_FILE" ]] && rm "$PBS_TOKEN_FILE"
            
            {
                cp "$manual_pass_file" "$PBS_PASS_FILE"
                chmod 600 "$PBS_PASS_FILE"
            } >/dev/null 2>&1
            password_found=true
            dialog --backtitle "vmenu" --title "PBS Selected" --msgbox "$(translate 'Using manual PBS:') $pbs_name

$(translate 'Repository:') $PBS_REPO
$(translate 'Password:') $(translate 'Previously saved')" 12 80
        fi
    fi
    
    if ! $password_found; then
        dialog --backtitle "vmenu" --title "Password Required" --msgbox "$(translate 'Password not found for:') $pbs_name
$(translate 'Please enter the password.')" 10 60
        get_pbs_password "$pbs_name" || return 1
    fi
    
    clear
fi
}










# ========== PBS BACKUP ==========
backup_full_pbs_root() {
    local HOSTNAME PBS_REPO PBS_KEY_FILE PBS_PASS_FILE PBS_TOKEN_FILE PBS_ENCRYPTION_PASS_FILE ENCRYPT_OPT=""
    HOSTNAME=$(hostname)
    

    local PBS_REPO_FILE="/usr/local/share/proxmenux/pbs-repo.conf"
    PBS_KEY_FILE="/usr/local/share/proxmenux/pbs-key.conf"
    PBS_PASS_FILE="/usr/local/share/proxmenux/pbs-pass.txt"
    PBS_TOKEN_FILE="/usr/local/share/proxmenux/pbs-token.txt"
    PBS_ENCRYPTION_PASS_FILE="/usr/local/share/proxmenux/pbs-encryption-pass.txt"
    LOGFILE="/tmp/pbs-backup-${HOSTNAME}.log"


    configure_pbs_repository || return 1

    if [[ ! -f "$PBS_REPO_FILE" ]]; then
        msg_error "$(translate "Failed to configure PBS connection")"
        sleep 3
        return 1
    fi
    PBS_REPO=$(<"$PBS_REPO_FILE")


    unset PBS_PASSWORD PBS_API_TOKEN PBS_API_TOKEN_ID PBS_API_TOKEN_SECRET PBS_FINGERPRINT


    local AUTH_TYPE="password"  
    local PBS_AUTH_VALUE=""
    
    if [[ "$PBS_REPO" == *"@pbs!"* ]]; then

        AUTH_TYPE="pbs_cloud"
        [[ -f "$PBS_PASS_FILE" ]] && PBS_AUTH_VALUE=$(<"$PBS_PASS_FILE")
    elif [[ -f "$PBS_TOKEN_FILE" ]]; then

        AUTH_TYPE="token"
        PBS_AUTH_VALUE=$(<"$PBS_TOKEN_FILE")
    elif [[ -f "$PBS_PASS_FILE" ]]; then

        AUTH_TYPE="password"
        PBS_AUTH_VALUE=$(<"$PBS_PASS_FILE")
    else
        msg_error "$(translate "No PBS authentication found!")"
        sleep 3
        return 1
    fi

  
    dialog --backtitle "vmenu" --title "Encryption" --yesno "$(translate 'Do you want to encrypt the backup?')" 8 60
    if [[ $? -eq 0 ]]; then

        if [[ ! -f "$PBS_ENCRYPTION_PASS_FILE" ]]; then
            while true; do
                PBS_KEY_PASS=$(dialog --backtitle "vmenu" --title "Encryption Password" --insecure --passwordbox "$(translate 'Enter encryption password (different from PBS login):')" 12 70 "" 3>&1 1>&2 2>&3) || return 1
                PBS_KEY_PASS2=$(dialog --backtitle "vmenu" --title "Encryption Password" --insecure --passwordbox "$(translate 'Confirm encryption password:')" 10 60 "" 3>&1 1>&2 2>&3) || return 1
                
                if [[ "$PBS_KEY_PASS" == "$PBS_KEY_PASS2" ]]; then
                    break
                else
                    dialog --backtitle "vmenu" --title "Error" --msgbox "$(translate 'Passwords do not match! Please try again.')" 8 50
                fi
            done


            {
                echo "$PBS_KEY_PASS" > "$PBS_ENCRYPTION_PASS_FILE"
                chmod 600 "$PBS_ENCRYPTION_PASS_FILE"
            } >/dev/null 2>&1
            
            dialog --backtitle "vmenu" --title "Success" --msgbox "$(translate 'Encryption password saved successfully!')" 8 50
        fi
        

        if [[ ! -f "$PBS_KEY_FILE" ]]; then
            PBS_ENCRYPTION_PASS=$(<"$PBS_ENCRYPTION_PASS_FILE")
            
            dialog --backtitle "vmenu" --title "Encryption" --infobox "$(translate 'Creating encryption key...')" 5 50
            
            expect -c "
            set timeout 30
            spawn proxmox-backup-client key create \"$PBS_KEY_FILE\"
            expect {
                \"Encryption Key Password:\" {
                    send \"$PBS_ENCRYPTION_PASS\r\"
                    exp_continue
                }
                \"Verify Password:\" {
                    send \"$PBS_ENCRYPTION_PASS\r\"
                    exp_continue
                }
                eof
            }
            " >/dev/null 2>&1

            if [[ ! -f "$PBS_KEY_FILE" ]]; then
                dialog --backtitle "vmenu" --title "Error" --msgbox "$(translate 'Error creating encryption key.')" 8 40
                return 1
            fi
            
            dialog --backtitle "vmenu" --title "Important" --msgbox "$(translate 'IMPORTANT: Save the key file. Without it you will not be able to restore your backups!')\n\n$(translate 'Key file location:') $PBS_KEY_FILE" 12 70
        fi
        ENCRYPT_OPT="--keyfile $PBS_KEY_FILE"
    else
        ENCRYPT_OPT=""
    fi


    clear
    show_proxmenux_logo
    echo -e
    msg_info2 "$(translate "Starting backup to PBS")"
    echo -e
    echo -e "${BL}$(translate "PBS Repository:")${WHITE} $PBS_REPO${RESET}"
    echo -e "${BL}$(translate "Backup ID:")${WHITE} $HOSTNAME${RESET}"
    echo -e "${BL}$(translate "Included:")${WHITE} /boot/efi /etc/pve (all root)${RESET}"
    echo -e "${BL}$(translate "Encryption:")${WHITE} $([[ -n "$ENCRYPT_OPT" ]] && echo "Enabled" || echo "Disabled")${RESET}"
    

    case "$AUTH_TYPE" in
        "pbs_cloud") echo -e "${BL}$(translate "Authentication:")${WHITE} PBS Cloud Token${RESET}" ;;
        "token") echo -e "${BL}$(translate "Authentication:")${WHITE} API Token${RESET}" ;;
        "password") echo -e "${BL}$(translate "Authentication:")${WHITE} Password${RESET}" ;;
    esac
    
    echo -e "${BL}$(translate "Log file:")${WHITE} $LOGFILE${RESET}"
    echo -e "${BOLD}${NEON_PURPLE_BLUE}-------------------------------${RESET}"
    echo ""


    local backup_cmd="proxmox-backup-client backup --include-dev /boot/efi --include-dev /etc/pve root-${HOSTNAME}.pxar:/ --repository \"$PBS_REPO\" $ENCRYPT_OPT --backup-type host --backup-id \"$HOSTNAME\" --backup-time \"$(date +%s)\""
    local backup_result=0
    
    case "$AUTH_TYPE" in
        "pbs_cloud")

            if [[ -n "$ENCRYPT_OPT" ]]; then
                PBS_ENCRYPTION_PASS=$(<"$PBS_ENCRYPTION_PASS_FILE")
                echo "$(translate "Starting encrypted full backup with PBS Cloud...")"
                echo ""
                
                env -i PBS_PASSWORD="$PBS_AUTH_VALUE" expect -c "
                set timeout 3600
                log_file $LOGFILE
                spawn $backup_cmd
                expect {
                    \"Encryption Key Password:\" {
                        send \"$PBS_ENCRYPTION_PASS\r\"
                        exp_continue
                    }
                    eof
                }
                " | tee -a "$LOGFILE"
                backup_result=${PIPESTATUS[0]}
            else

                echo "$(translate "Starting unencrypted full backup with PBS Cloud...")"
                echo ""
                env -i PBS_PASSWORD="$PBS_AUTH_VALUE" bash -c "$backup_cmd" | tee -a "$LOGFILE"
                backup_result=${PIPESTATUS[0]}
            fi
            ;;
            
        "token")

            if [[ -n "$ENCRYPT_OPT" ]]; then
                PBS_ENCRYPTION_PASS=$(<"$PBS_ENCRYPTION_PASS_FILE")
                echo "$(translate "Starting encrypted full backup with API Token...")"
                echo ""
                
                env -i PBS_API_TOKEN="$PBS_AUTH_VALUE" expect -c "
                set timeout 3600
                log_file $LOGFILE
                spawn $backup_cmd
                expect {
                    \"Encryption Key Password:\" {
                        send \"$PBS_ENCRYPTION_PASS\r\"
                        exp_continue
                    }
                    eof
                }
                " | tee -a "$LOGFILE"
                backup_result=${PIPESTATUS[0]}
            else
                echo "$(translate "Starting unencrypted full backup with API Token...")"
                echo ""
                env -i PBS_API_TOKEN="$PBS_AUTH_VALUE" bash -c "$backup_cmd" | tee -a "$LOGFILE"
                backup_result=${PIPESTATUS[0]}
            fi
            ;;
            
        "password")

            if [[ -n "$ENCRYPT_OPT" ]]; then
                PBS_ENCRYPTION_PASS=$(<"$PBS_ENCRYPTION_PASS_FILE")
                echo "$(translate "Starting encrypted full backup with password...")"
                echo ""
                
                env -i expect -c "
                set timeout 3600
                log_file $LOGFILE
                spawn $backup_cmd
                expect {
                    -re \"Password for .*:\" {
                        send \"$PBS_AUTH_VALUE\r\"
                        exp_continue
                    }
                    \"Encryption Key Password:\" {
                        send \"$PBS_ENCRYPTION_PASS\r\"
                        exp_continue
                    }
                    -re \"Are you sure you want to continue connecting.*\" {
                        send \"y\r\"
                        exp_continue
                    }
                    eof
                }
                " | tee -a "$LOGFILE"
                backup_result=${PIPESTATUS[0]}
            else
            
                echo "$(translate "Starting unencrypted full backup with password...")"
                echo ""
                
                env -i expect -c "
                set timeout 3600
                log_file $LOGFILE
                spawn $backup_cmd
                expect {
                    -re \"Password for .*:\" {
                        send \"$PBS_AUTH_VALUE\r\"
                        exp_continue
                    }
                    -re \"Are you sure you want to continue connecting.*\" {
                        send \"y\r\"
                        exp_continue
                    }
                    eof
                }
                " | tee -a "$LOGFILE"
                backup_result=${PIPESTATUS[0]}
            fi
            ;;
    esac

    echo -e "${BOLD}${NEON_PURPLE_BLUE}===============================${RESET}\n"
    if [[ $backup_result -eq 0 ]]; then
        msg_ok "$(translate "Full backup process completed successfully")"
    else
        msg_error "$(translate "Backup process finished with errors")"
    fi
    
    echo ""
    msg_success "$(translate "Press Enter to return to the main menu...")"
    read -r
}














backup_to_pbs() {
    local HOSTNAME TIMESTAMP SNAPSHOT
    HOSTNAME=$(hostname)
    TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
    SNAPSHOT="${HOSTNAME}-${TIMESTAMP}"

    local PBS_REPO_FILE="/usr/local/share/proxmenux/pbs-repo.conf"
    local PBS_KEY_FILE="/usr/local/share/proxmenux/pbs-key.conf"
    local PBS_PASS_FILE="/usr/local/share/proxmenux/pbs-pass.txt"
    local PBS_TOKEN_FILE="/usr/local/share/proxmenux/pbs-token.txt"
    local PBS_ENCRYPTION_PASS_FILE="/usr/local/share/proxmenux/pbs-encryption-pass.txt"
    local PBS_REPO ENCRYPT_OPT USE_ENCRYPTION
    local PBS_KEY_PASS PBS_REPO_PASS

    configure_pbs_repository || return 1
    PBS_REPO=$(<"$PBS_REPO_FILE")


    unset PBS_PASSWORD PBS_API_TOKEN PBS_API_TOKEN_ID PBS_API_TOKEN_SECRET PBS_FINGERPRINT

    USE_ENCRYPTION=false
    dialog --backtitle "vmenu" --yesno "$(translate 'Do you want to encrypt the backup?')" 8 60
    [[ $? -eq 0 ]] && USE_ENCRYPTION=true

    if $USE_ENCRYPTION && ! command -v expect >/dev/null 2>&1; then
        apt-get update -qq >/dev/null 2>&1
        apt-get install -y expect >/dev/null 2>&1
    fi

    if [[ "$#" -lt 1 ]]; then
        clear
        show_proxmenux_logo
        msg_error "$(translate "No directories specified for backup.")"
        sleep 2 
        return 1
    fi

    local TOTAL="$#"
    local COUNT=1


    local AUTH_TYPE="password"  
    local PBS_AUTH_VALUE=""
    
    if [[ "$PBS_REPO" == *"@pbs!"* ]]; then

        AUTH_TYPE="pbs_cloud"
        [[ -f "$PBS_PASS_FILE" ]] && PBS_AUTH_VALUE=$(<"$PBS_PASS_FILE")
    elif [[ -f "$PBS_TOKEN_FILE" ]]; then

        AUTH_TYPE="token"
        PBS_AUTH_VALUE=$(<"$PBS_TOKEN_FILE")
    elif [[ -f "$PBS_PASS_FILE" ]]; then

        AUTH_TYPE="password"
        PBS_AUTH_VALUE=$(<"$PBS_PASS_FILE")
    else
        msg_error "$(translate "No PBS authentication found!")"
        return 1
    fi

    for dir in "$@"; do
        local SAFE_NAME SAFE_ID PXAR_NAME
        SAFE_NAME=$(basename "$dir" | tr '.-/' '_')
        PXAR_NAME="root-custom-${SAFE_NAME}-${SNAPSHOT}.pxar"
        SAFE_ID="custom-${HOSTNAME}-${SAFE_NAME}"

        msg_info2 "$(translate "[$COUNT/$TOTAL] Backing up") $dir $(translate "as") $PXAR_NAME"

        ENCRYPT_OPT=""

        if $USE_ENCRYPTION; then
            if [[ -f "$PBS_KEY_FILE" ]]; then
                ENCRYPT_OPT="--keyfile $PBS_KEY_FILE"
            else
                while true; do
                    PBS_KEY_PASS=$(dialog --backtitle "vmenu" --insecure --passwordbox "$(translate 'Enter encryption password (different from PBS login):')" 10 60 "" 3>&1 1>&2 2>&3) || return 1
                    PBS_KEY_PASS2=$(dialog --backtitle "vmenu" --insecure --passwordbox "$(translate 'Confirm encryption password:')" 10 60 "" 3>&1 1>&2 2>&3) || return 1
                    
                    if [[ "$PBS_KEY_PASS" == "$PBS_KEY_PASS2" ]]; then
                        break
                    else
                        dialog --backtitle "vmenu" --msgbox "$(translate 'Passwords do not match! Please try again.')" 8 50
                    fi
                done

                {
                    echo "$PBS_KEY_PASS" > "$PBS_ENCRYPTION_PASS_FILE"
                    chmod 600 "$PBS_ENCRYPTION_PASS_FILE"
                } >/dev/null 2>&1

                expect -c "
                set timeout 30
                spawn proxmox-backup-client key create \"$PBS_KEY_FILE\"
                expect {
                    \"Encryption Key Password:\" {
                        send \"$PBS_KEY_PASS\r\"
                        exp_continue
                    }
                    \"Verify Password:\" {
                        send \"$PBS_KEY_PASS\r\"
                        exp_continue
                    }
                    eof
                }
                " >/dev/null 2>&1

                if [[ ! -f "$PBS_KEY_FILE" ]]; then
                    dialog --backtitle "vmenu" --msgbox "$(translate 'Error creating encryption key.')" 8 40
                    return 1
                fi
                ENCRYPT_OPT="--keyfile $PBS_KEY_FILE"
                dialog --backtitle "vmenu" --msgbox "$(translate 'Encryption key generated. Save it in a safe place!')" 10 60
            fi
        fi

        clear
        show_proxmenux_logo
        echo -e
        msg_info2 "$(translate "Starting backup to PBS")"
        TOTAL_SIZE=$(du -cb "$@" | awk '/total$/ {print $1}')
        TOTAL_SIZE_GB=$(awk "BEGIN {printf \"%.2f\", $TOTAL_SIZE/1024/1024/1024}")
        echo -e
        echo -e "${BL}$(translate "PBS Repository:")${WHITE} $PBS_REPO${RESET}"
        echo -e "${BL}$(translate "Backup ID:")${WHITE} $HOSTNAME${RESET}"
        echo -e "${BL}$(translate "Encryption:")${WHITE} $([[ -n "$ENCRYPT_OPT" ]] && echo "Enabled" || echo "Disabled")${RESET}"
        
        case "$AUTH_TYPE" in
            "pbs_cloud") echo -e "${BL}$(translate "Authentication:")${WHITE} PBS Cloud Token${RESET}" ;;
            "token") echo -e "${BL}$(translate "Authentication:")${WHITE} API Token${RESET}" ;;
            "password") echo -e "${BL}$(translate "Authentication:")${WHITE} Password${RESET}" ;;
        esac
        
        echo -e "${BL}$(translate "Included directories:")${WHITE} $*${RESET}"
        echo -e "${BL}$(translate "Total size:")${WHITE} ${TOTAL_SIZE_GB} GB${RESET}"
        echo -e "${BOLD}${NEON_PURPLE_BLUE}-------------------------------${RESET}"


        local backup_cmd="proxmox-backup-client backup \"${PXAR_NAME}:$dir\" --repository \"$PBS_REPO\" $ENCRYPT_OPT --backup-type host --backup-id \"$SAFE_ID\" --backup-time \"$(date +%s)\""
        
        case "$AUTH_TYPE" in
            "pbs_cloud")

                if $USE_ENCRYPTION && [[ -f "$PBS_ENCRYPTION_PASS_FILE" ]]; then
                    PBS_KEY_PASS=$(<"$PBS_ENCRYPTION_PASS_FILE")
                    env -i PBS_PASSWORD="$PBS_AUTH_VALUE" expect -c "
                    set timeout 300
                    spawn $backup_cmd
                    expect {
                        \"Encryption Key Password:\" {
                            send \"$PBS_KEY_PASS\r\"
                            exp_continue
                        }
                        eof
                    }
                    "
                else
                    env -i PBS_PASSWORD="$PBS_AUTH_VALUE" bash -c "$backup_cmd"
                fi
                ;;
                
            "token")

                if $USE_ENCRYPTION && [[ -f "$PBS_ENCRYPTION_PASS_FILE" ]]; then
                    PBS_KEY_PASS=$(<"$PBS_ENCRYPTION_PASS_FILE")
                    env -i PBS_API_TOKEN="$PBS_AUTH_VALUE" expect -c "
                    set timeout 300
                    spawn $backup_cmd
                    expect {
                        \"Encryption Key Password:\" {
                            send \"$PBS_KEY_PASS\r\"
                            exp_continue
                        }
                        eof
                    }
                    "
                else
                    env -i PBS_API_TOKEN="$PBS_AUTH_VALUE" bash -c "$backup_cmd"
                fi
                ;;
                
            "password")

                if $USE_ENCRYPTION && [[ -f "$PBS_ENCRYPTION_PASS_FILE" ]]; then
                    PBS_KEY_PASS=$(<"$PBS_ENCRYPTION_PASS_FILE")
                    env -i expect -c "
                    set timeout 300
                    spawn $backup_cmd
                    expect {
                        -re \"Password for .*:\" {
                            send \"$PBS_AUTH_VALUE\r\"
                            exp_continue
                        }
                        \"Encryption Key Password:\" {
                            send \"$PBS_KEY_PASS\r\"
                            exp_continue
                        }
                        -re \"Are you sure you want to continue connecting.*\" {
                            send \"y\r\"
                            exp_continue
                        }
                        eof
                    }
                    "
                else
                    env -i expect -c "
                    set timeout 300
                    spawn $backup_cmd
                    expect {
                        -re \"Password for .*:\" {
                            send \"$PBS_AUTH_VALUE\r\"
                            exp_continue
                        }
                        -re \"Are you sure you want to continue connecting.*\" {
                            send \"y\r\"
                            exp_continue
                        }
                        eof
                    }
                    "
                fi
                ;;
        esac

        COUNT=$((COUNT+1))
    done

    echo -e "${BOLD}${NEON_PURPLE_BLUE}===============================${RESET}\n"
    msg_ok "$(translate "Backup process finished.")"
    echo ""
    msg_success "$(translate "Press Enter to return to the main menu...")"
    read -r
}
# ===============================







# ========== BORGBACKUP ==========
backup_with_borg() {
#    local SRC="$1"
    local BORG_APPIMAGE="/usr/local/share/proxmenux/borg"
    local LOGFILE="/tmp/borg-backup.log"
    local DEST
    local TYPE
    local ENCRYPT_OPT=""
    local BORG_KEY

    if [[ ! -x "$BORG_APPIMAGE" ]]; then
        clear
        show_proxmenux_logo
        msg_info "$(translate "BorgBackup not found. Downloading AppImage...")"
        mkdir -p /usr/local/share/proxmenux
        wget -qO "$BORG_APPIMAGE" "https://github.com/borgbackup/borg/releases/download/1.2.8/borg-linux64"
        chmod +x "$BORG_APPIMAGE"
        msg_ok "$(translate "BorgBackup downloaded and ready.")"
    fi


    TYPE=$(dialog --backtitle "vmenu" --menu "$(translate 'Select Borg backup destination:')" 15 60 3 \
        "local"   "$(translate 'Local directory')" \
        "usb"     "$(translate 'Internal/External dedicated disk')" \
        "remote"  "$(translate 'Remote server')" \
        3>&1 1>&2 2>&3) || return 1

    if [[ "$TYPE" == "local" ]]; then
        DEST=$(dialog --backtitle "vmenu" --inputbox "$(translate 'Enter local directory for backup:')" 10 60 "/backup/borgbackup" 3>&1 1>&2 2>&3) || return 1
        mkdir -p "$DEST"
    elif [[ "$TYPE" == "usb" ]]; then

    while true; do
        BASE_DEST=$(get_external_backup_mount_point)
        if [[ -z "$BASE_DEST" ]]; then
            dialog --backtitle "vmenu" --yesno "$(translate 'No external disk detected or mounted. Would you like to retry?')" 8 60
            [[ $? -eq 0 ]] && continue
            return 1
        fi

        DEST="$BASE_DEST/borgbackup"
        mkdir -p "$DEST"

        DISK_DEV=$(df "$BASE_DEST" | awk 'NR==2{print $1}')
        PKNAME=$(lsblk -no PKNAME "$DISK_DEV" 2>/dev/null)
        [[ -z "$PKNAME" ]] && PKNAME=$(basename "$DISK_DEV" | sed 's/[0-9]*$//')
        if [[ -n "$PKNAME" && -b /dev/$PKNAME ]]; then
            DISK_MODEL=$(lsblk -no MODEL "/dev/$PKNAME")
        else
            DISK_MODEL="(unknown)"
        fi
        FREE_SPACE=$(df -h "$BASE_DEST" | awk 'NR==2{print $4}')

            dialog --backtitle "vmenu" \
                --title "$(translate "Dedicated Backup Disk")" \
                --yesno "\n$(translate "Mount point:") $DEST\n\n\
        $(translate "Disk model:") $DISK_MODEL\n\
        $(translate "Available space:") $FREE_SPACE\n\n\
        $(translate "Use this disk for backup?")" 12 70

        if [[ $? -eq 0 ]]; then
            break
        else
            return 1
        fi
    done


    elif [[ "$TYPE" == "remote" ]]; then
        REMOTE_USER=$(dialog --backtitle "vmenu" --inputbox "$(translate 'Enter SSH user for remote:')" 10 60 "root" 3>&1 1>&2 2>&3) || return 1
        REMOTE_HOST=$(dialog --backtitle "vmenu" --inputbox "$(translate 'Enter SSH host:')" 10 60 "" 3>&1 1>&2 2>&3) || return 1
        REMOTE_PATH=$(dialog --backtitle "vmenu" --inputbox "$(translate 'Enter remote path:')" 10 60 "/backup/borgbackup" 3>&1 1>&2 2>&3) || return 1
        DEST="ssh://$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"
    fi


    dialog --backtitle "vmenu" --yesno "$(translate 'Do you want to encrypt the backup?')" 8 60
    if [[ $? -eq 0 ]]; then
        BORG_KEY=$(dialog --backtitle "vmenu" --inputbox "$(translate 'Enter Borg encryption passphrase (will be saved):')" 10 60 "" 3>&1 1>&2 2>&3) || return 1
        ENCRYPT_OPT="--encryption=repokey"
        export BORG_PASSPHRASE="$BORG_KEY"
    else
        ENCRYPT_OPT="--encryption=none"
    fi

    if [[ "$TYPE" == "local" || "$TYPE" == "usb" ]]; then
        if [[ ! -f "$DEST/config" ]]; then
            "$BORG_APPIMAGE" init $ENCRYPT_OPT "$DEST"
            if [[ $? -ne 0 ]]; then
                clear
                show_proxmenux_logo
                msg_error "$(translate "Failed to initialize Borg repo at") $DEST"
                sleep 5
                return 1
            fi
        fi
    fi


    dialog --backtitle "vmenu" --msgbox "$(translate 'Borg backup will start now. This may take a while.')" 8 40

    clear
    show_proxmenux_logo
    msg_info2 "$(translate "Starting backup with BorgBackup...")"
    echo -e

    TOTAL_SIZE=$(du -cb "$@" | awk '/total$/ {print $1}')
    TOTAL_SIZE_GB=$(awk "BEGIN {printf \"%.2f\", $TOTAL_SIZE/1024/1024/1024}")

    echo -e "${BL}$(translate "Included directories:")${WHITE} $*${RESET}"
    echo -e "${BL}$(translate "Total size:")${WHITE} ${TOTAL_SIZE_GB} GB${RESET}"


    # 6. Lanzar el backup y guardar log
#    "$BORG_APPIMAGE" create --progress "$DEST"::"root-$(hostname)-$(date +%Y%m%d_%H%M)" $SRC 2>&1 | tee "$LOGFILE"

    "$BORG_APPIMAGE" create --progress "$DEST"::"root-$(hostname)-$(date +%Y%m%d_%H%M)" "$@" 2>&1 | tee "$LOGFILE"

    echo -e "${BOLD}${NEON_PURPLE_BLUE}===============================${RESET}\n"
    msg_ok "$(translate "Backup process finished.")"
    echo
    msg_success "$(translate "Press Enter to return to the main menu...")"
    read -r
}
# ===============================




# ========== LOCAL TAR ==========
backup_to_local_tar() {
#    local SRC="$1"
    local TYPE
    local DEST
    local LOGFILE="/tmp/tar-backup.log"


if ! command -v pv &>/dev/null; then
    apt-get update -qq && apt-get install -y pv >/dev/null 2>&1
fi



    TYPE=$(dialog --backtitle "vmenu"  --menu "$(translate 'Select backup destination:')" 15 60 2 \
        "local" "$(translate 'Local directory')" \
        "usb"   "$(translate 'Internal/External dedicated disk')" \
        3>&1 1>&2 2>&3) || return 1

    if [[ "$TYPE" == "local" ]]; then
        DEST=$(dialog --backtitle "vmenu" --inputbox "$(translate 'Enter directory for backup:')" 10 60 "/backup" 3>&1 1>&2 2>&3) || return 1

        mkdir -p "$DEST"


else


while true; do
    DEST=$(get_external_backup_mount_point)
    if [[ -z "$DEST" ]]; then
        dialog --backtitle "vmenu" --yesno "No external disk detected or mounted. Would you like to retry?" 8 60
        [[ $? -eq 0 ]] && continue
        return 1
    fi

    DISK_DEV=$(df "$DEST" | awk 'NR==2{print $1}')
    PKNAME=$(lsblk -no PKNAME "$DISK_DEV" 2>/dev/null)
    [[ -z "$PKNAME" ]] && PKNAME=$(basename "$DISK_DEV" | sed 's/[0-9]*$//')
    if [[ -n "$PKNAME" && -b /dev/$PKNAME ]]; then
        DISK_MODEL=$(lsblk -no MODEL "/dev/$PKNAME")
    else
        DISK_MODEL="(unknown)"
    fi
    FREE_SPACE=$(df -h "$DEST" | awk 'NR==2{print $4}')



    dialog --backtitle "vmenu" \
    --title "$(translate "Dedicated Backup Disk")" \
    --yesno "\n$(translate "Mount point:") $DEST\n\n\
    $(translate "Disk model:") $DISK_MODEL\n\
    $(translate "Available space:") $FREE_SPACE\n\n\
    $(translate "Use this disk for backup?")" 12 70


    if [[ $? -eq 0 ]]; then
        mkdir -p "$DEST"
        break
    else
        return 1
    fi
done



fi


TAR_INPUT=""
TOTAL_SIZE=0
for src in $SRC; do
    sz=$(du -sb "$src" 2>/dev/null | awk '{print $1}')
    TOTAL_SIZE=$((TOTAL_SIZE + sz))
    TAR_INPUT="$TAR_INPUT $src"
done

local FILENAME="root-$(hostname)-$(date +%Y%m%d_%H%M).tar.gz"
clear
show_proxmenux_logo
msg_info2 "$(translate "Starting backup with tar...")"
echo -e


TOTAL_SIZE=$(du -cb "$@" | awk '/total$/ {print $1}')
TOTAL_SIZE_GB=$(awk "BEGIN {printf \"%.2f\", $TOTAL_SIZE/1024/1024/1024}")

echo -e "${BL}$(translate "Included directories:")${WHITE} $*${RESET}"
echo -e "${BL}$(translate "Total size:")${WHITE} ${TOTAL_SIZE_GB} GB${RESET}"

tar -cf - "$@" 2> >(grep -v "Removing leading \`/'" >&2) \
| pv -s "$TOTAL_SIZE" \
| gzip > "$DEST/$FILENAME"


echo -ne "\033[1A\r\033[K"

echo -e "${BOLD}${NEON_PURPLE_BLUE}===============================${RESET}\n"
msg_ok "$(translate "Backup process finished. Review log above or in /tmp/tar-backup.log")"
echo
msg_success "$(translate "Press Enter to return to the main menu...")"
read -r

}
# ===============================


host_backup_menu