#!/bin/bash

# ==========================================================
# ProxMenu CT - A menu-driven script for Proxmox CT management
# ==========================================================
# Based on ProxMenu by MacRimi
# Modified for Proxmox Containers
# ==========================================================
# Description:
# This script allows users to assign physical disks to existing
# Proxmox containers (CTs) through an interactive menu.
# - Detects the system disk and excludes it from selection.
# - Lists all available CTs for the user to choose from.
# - Identifies and displays unassigned physical disks.
# - Allows the user to select multiple disks and attach them to a CT.
# - Configures the selected disks for the CT and verifies the assignment.
# ==========================================================


# Configuration ============================================
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



get_disk_info() {
    local disk=$1
    MODEL=$(lsblk -dn -o MODEL "$disk" | xargs)
    SIZE=$(lsblk -dn -o SIZE "$disk" | xargs)
    echo "$MODEL" "$SIZE"
}



CT_LIST=$(pct list | awk 'NR>1 {print $1, $3}')
if [ -z "$CT_LIST" ]; then
    whiptail --title "$(translate "Error")" --msgbox "$(translate "No CTs available in the system.")" 8 40
    exit 1
fi


CTID=$(whiptail --title "$(translate "Select CT")" --menu "$(translate "Select the CT to which you want to add disks:")" 15 60 8 $CT_LIST 3>&1 1>&2 2>&3)

if [ -z "$CTID" ]; then
    whiptail --title "$(translate "Error")" --msgbox "$(translate "No CT was selected.")" 8 40
    exit 1
fi

CTID=$(echo "$CTID" | tr -d '"')

msg_ok "$(translate "CT selected successfully.")"

CT_STATUS=$(pct status "$CTID" | awk '{print $2}')
if [ "$CT_STATUS" == "running" ]; then
    whiptail --title "$(translate "Warning")" --msgbox "$(translate "The CT is powered on. Turn it off before adding disks.")" 12 60
    exit 1
fi

##########################################

msg_info "$(translate "Detecting available disks...")"

USED_DISKS=$(lsblk -n -o PKNAME,TYPE | grep 'lvm' | awk '{print "/dev/" $1}')
MOUNTED_DISKS=$(lsblk -ln -o NAME,MOUNTPOINT | awk '$2!="" {print "/dev/" $1}')

ZFS_DISKS=""
ZFS_RAW=$(zpool list -v -H 2>/dev/null | awk '{print $1}' | grep -v '^NAME$' | grep -v '^-' | grep -v '^mirror')

for entry in $ZFS_RAW; do
    path=""
    if [[ "$entry" == wwn-* || "$entry" == ata-* ]]; then
        if [ -e "/dev/disk/by-id/$entry" ]; then
            path=$(readlink -f "/dev/disk/by-id/$entry")
        fi
    elif [[ "$entry" == /dev/* ]]; then
        path="$entry"
    fi

    if [ -n "$path" ]; then
        base_disk=$(lsblk -no PKNAME "$path" 2>/dev/null)
        if [ -n "$base_disk" ]; then
            ZFS_DISKS+="/dev/$base_disk"$'\n'
        fi
    fi
done


ZFS_DISKS=$(echo "$ZFS_DISKS" | sort -u)

is_disk_in_use() {
    local disk="$1"

    while read -r part fstype; do
        case "$fstype" in
            zfs_member|linux_raid_member)
                return 0 ;;
        esac

        if echo "$MOUNTED_DISKS" | grep -q "/dev/$part"; then
            return 0
        fi
    done < <(lsblk -ln -o NAME,FSTYPE "$disk" | tail -n +2)

    if echo "$USED_DISKS" | grep -q "$disk" || echo "$ZFS_DISKS" | grep -q "$disk"; then
        return 0
    fi

    return 1
}

FREE_DISKS=()

LVM_DEVICES=$(pvs --noheadings -o pv_name | xargs -n1 readlink -f | sort -u)
RAID_ACTIVE=$(grep -Po 'md\d+\s*:\s*active\s+raid[0-9]+' /proc/mdstat | awk '{print $1}' | sort -u)

while read -r DISK; do
    [[ "$DISK" =~ /dev/zd ]] && continue

    INFO=($(get_disk_info "$DISK"))
    MODEL="${INFO[@]::${#INFO[@]}-1}"
    SIZE="${INFO[-1]}"
    LABEL=""
    SHOW_DISK=true

    IS_MOUNTED=false
    IS_RAID=false
    IS_ZFS=false
    IS_LVM=false

    while read -r part fstype; do
        [[ "$fstype" == "zfs_member" ]] && IS_ZFS=true
        [[ "$fstype" == "linux_raid_member" ]] && IS_RAID=true
        [[ "$fstype" == "LVM2_member" ]] && IS_LVM=true
        if grep -q "/dev/$part" <<< "$MOUNTED_DISKS"; then
            IS_MOUNTED=true
        fi
    done < <(lsblk -ln -o NAME,FSTYPE "$DISK" | tail -n +2)

    REAL_PATH=$(readlink -f "$DISK")
    if echo "$LVM_DEVICES" | grep -qFx "$REAL_PATH"; then
        IS_MOUNTED=true
    fi

    if $IS_RAID && grep -q "$DISK" <<< "$(cat /proc/mdstat)"; then
        if grep -q "active raid" /proc/mdstat; then
            SHOW_DISK=false
        fi
    fi

    if $IS_ZFS; then
        SHOW_DISK=false
    fi

    if $IS_MOUNTED; then
        SHOW_DISK=false
    fi

    if pct config "$CTID" | grep -q "$DISK"; then
        SHOW_DISK=false
    fi

    if $SHOW_DISK; then
        [[ "$IS_RAID" == true ]] && LABEL+=" ⚠ with partitions"
        [[ "$IS_LVM" == true ]] && LABEL+=" ⚠ LVM"
        [[ "$IS_ZFS" == true ]] && LABEL+=" ⚠ ZFS"

        DESCRIPTION=$(printf "%-30s %10s%s" "$MODEL" "$SIZE" "$LABEL")
        FREE_DISKS+=("$DISK" "$DESCRIPTION" "OFF")
    fi
done < <(lsblk -dn -e 7,11 -o PATH)

if [ "${#FREE_DISKS[@]}" -eq 0 ]; then
    cleanup
    whiptail --title "$(translate "Error")" --msgbox "$(translate "No disks available for this CT.")" 8 40
    clear
    exit 1
fi

msg_ok "$(translate "Available disks detected.")"

######################################################

MAX_WIDTH=$(printf "%s\n" "${FREE_DISKS[@]}" | awk '{print length}' | sort -nr | head -n1)
TOTAL_WIDTH=$((MAX_WIDTH + 20))

if [ $TOTAL_WIDTH -lt 70 ]; then
    TOTAL_WIDTH=70
fi

SELECTED=$(whiptail --title "$(translate "Select Disks")" --radiolist \
    "$(translate "Select the disks you want to add:")" 20 $TOTAL_WIDTH 10 "${FREE_DISKS[@]}" 3>&1 1>&2 2>&3)

if [ -z "$SELECTED" ]; then
    whiptail --title "$(translate "Error")" --msgbox "$(translate "No disks were selected.")" 10 $TOTAL_WIDTH
    clear
    exit 1
fi

msg_ok "$(translate "Disks selected successfully.")"

DISKS_ADDED=0
ERROR_MESSAGES=""
SUCCESS_MESSAGES=""

msg_info "$(translate "Processing selected disks...")"

for DISK in $SELECTED; do
    DISK=$(echo "$DISK" | tr -d '"')
    DISK_INFO=$(get_disk_info "$DISK")

    ASSIGNED_TO=""
    RUNNING_CTS=""

    while read -r CT_ID CT_NAME; do
        if [[ "$CT_ID" =~ ^[0-9]+$ ]] && pct config "$CT_ID" | grep -q "$DISK"; then
            ASSIGNED_TO+="$CT_ID $CT_NAME\n"
            CT_STATUS=$(pct status "$CT_ID" | awk '{print $2}')
            if [ "$CT_STATUS" == "running" ]; then
                RUNNING_CTS+="$CT_ID $CT_NAME\n"
            fi
        fi
    done < <(pct list | awk 'NR>1 {print $1, $3}')

    if [ -n "$RUNNING_CTS" ]; then
        ERROR_MESSAGES+="$(translate "The disk") $DISK_INFO $(translate "is in use by the following running CT(s):")\\n$RUNNING_CTS\\n\\n"
        continue
    fi

    if [ -n "$ASSIGNED_TO" ]; then
        cleanup
        whiptail --title "$(translate "Disk Already Assigned")" --yesno "$(translate "The disk") $DISK_INFO $(translate "is already assigned to the following CT(s):")\\n$ASSIGNED_TO\\n\\n$(translate "Do you want to continue anyway?")" 15 70
        if [ $? -ne 0 ]; then
            sleep 1
            exec "$0"
        fi
    fi
    
    cleanup

    MOUNT_POINT=$(whiptail --title "$(translate "Mount Point")" --inputbox "$(translate "Enter the mount point for the disk (e.g., /mnt/disk_passthrough):")" 10 60 "/mnt/disk_passthrough" 3>&1 1>&2 2>&3)

    if [ -z "$MOUNT_POINT" ]; then
        whiptail --title "$(translate "Error")" --msgbox "$(translate "No mount point was specified.")" 8 40
        continue
    fi

    msg_ok "$(translate "Mount point specified: $MOUNT_POINT")"


    whiptail --title "$(translate "Format Required")" --msgbox "$(translate "To use the disk with a mount point, it needs to be formatted.")" 8 70

    FORMAT_TYPE=$(whiptail --title "$(translate "Select Format Type")" --menu "$(translate "Select the filesystem type for") $DISK_INFO:" 15 60 6 \
        "ext4" "$(translate "Extended Filesystem 4 (recommended)")" \
        "xfs" "$(translate "XFS Filesystem")" \
        "btrfs" "$(translate "Btrfs Filesystem")" 3>&1 1>&2 2>&3)
    
    if [ -z "$FORMAT_TYPE" ]; then
        whiptail --title "$(translate "Format Cancelled")" --msgbox "$(translate "Format operation cancelled. The disk will not be added.")" 8 60
        continue
    fi
    
    whiptail --title "$(translate "WARNING")" --yesno "$(translate "WARNING: This operation will FORMAT the disk") $DISK_INFO $(translate "with") $FORMAT_TYPE.\\n\\n$(translate "ALL DATA ON THIS DISK WILL BE PERMANENTLY LOST!")\\n\\n$(translate "Are you sure you want to continue?")" 15 70
    if [ $? -ne 0 ]; then
        whiptail --title "$(translate "Format Cancelled")" --msgbox "$(translate "Format operation cancelled. The disk will not be added.")" 8 60
        continue
    fi



    if lsblk "$DISK" | grep -q "raid" || grep -q "${DISK##*/}" /proc/mdstat; then
        whiptail --title "$(translate "RAID Detected")" --msgbox "$(translate "The disk") $DISK_INFO $(translate "is part of a RAID array and cannot be added.")\\n\\n$(translate "To use this disk, you must first stop the RAID array with:")\\n\\nmdadm --stop /dev/mdX\\nmdadm --zero-superblock $DISK\\n\\n$(translate "After removing the RAID metadata, run this script again to add the disk.")" 15 70
        
        continue
    fi

    MOUNTED_PARTITIONS=$(lsblk -n -o NAME,MOUNTPOINT "$DISK" | awk '$2 != "" {print $1}')
    if [ -n "$MOUNTED_PARTITIONS" ]; then
        UNMOUNT_FAILED=false
        
        if mount | grep -q "$DISK "; then
            umount -f "$DISK" 2>/dev/null
            if [ $? -ne 0 ]; then
                umount -f -l "$DISK" 2>/dev/null
                if [ $? -ne 0 ]; then
                    UNMOUNT_FAILED=true
                fi
            fi
        fi
        
        for PART in $MOUNTED_PARTITIONS; do

            if [[ "$PART" == "${DISK##*/}"* ]]; then
                PART_PATH="/dev/$PART"
            else
                PART_PATH="/dev/$PART"
            fi
            
            umount -f "$PART_PATH" 2>/dev/null
            if [ $? -ne 0 ]; then
                umount -f -l "$PART_PATH" 2>/dev/null
                if [ $? -ne 0 ]; then
                    UNMOUNT_FAILED=true
                fi
            fi
        done
        
        if [ "$UNMOUNT_FAILED" = true ]; then
            whiptail --title "$(translate "Unmount Failed")" --msgbox "$(translate "Failed to unmount") $DISK $(translate "or its partitions. Cannot format.")\\n\\n$(translate "The disk may be in use by the system or other processes.")" 12 70
            continue
        fi
    fi



    echo -e "$(translate "Removing partition table to ensure clean formatting...")"
    dd if=/dev/zero of="$DISK" bs=512 count=1 conv=notrunc
    partprobe "$DISK"
    sleep 2 

    echo -e "$(translate "Formatting disk") $DISK_INFO $(translate "with") $FORMAT_TYPE..."
    
    case "$FORMAT_TYPE" in
        "ext4")
            mkfs.ext4 -F "$DISK" ;;
        "xfs")
            mkfs.xfs -f "$DISK" ;;
        "btrfs")
            mkfs.btrfs -f "$DISK" ;;
    esac

    if [ $? -ne 0 ]; then
        whiptail --title "$(translate "Format Failed")" --msgbox "$(translate "Failed to format disk") $DISK_INFO $(translate "with") $FORMAT_TYPE.\\n\\n$(translate "The disk may be in use by the system or have hardware issues.")" 12 70
        continue
    else
        msg_ok "$(translate "Disk") $DISK_INFO $(translate "successfully formatted with") $FORMAT_TYPE."

        partprobe "$DISK"
        sleep 2
    fi

    INDEX=0
    while pct config "$CTID" | grep -q "mp${INDEX}:"; do
        ((INDEX++))
    done

##############################################################################

    RESULT=$(pct set "$CTID" -mp${INDEX} "$DISK,mp=$MOUNT_POINT,backup=0" 2>&1)

##############################################################################

    if [ $? -eq 0 ]; then
        MESSAGE="$(translate "The disk") $DISK_INFO $(translate "has been successfully added to CT") $CTID $(translate "as a mount point at") $MOUNT_POINT."
        if [ -n "$ASSIGNED_TO" ]; then
            MESSAGE+="\\n\\n$(translate "WARNING: This disk is also assigned to the following CT(s):")\\n$ASSIGNED_TO"
            MESSAGE+="\\n$(translate "Make sure not to start CTs that share this disk at the same time to avoid data corruption.")"
        fi
        SUCCESS_MESSAGES+="$MESSAGE\\n\\n"
        ((DISKS_ADDED++))
    else
        ERROR_MESSAGES+="$(translate "Could not add disk") $DISK_INFO $(translate "to CT") $CTID.\\n$(translate "Error:") $RESULT\\n\\n"
    fi
done

msg_ok "$(translate "Disk processing completed.")"

if [ -n "$SUCCESS_MESSAGES" ]; then
    MSG_LINES=$(echo "$SUCCESS_MESSAGES" | wc -l)
    whiptail --title "$(translate "Successful Operations")" --msgbox "$SUCCESS_MESSAGES" 16 70
fi

if [ -n "$ERROR_MESSAGES" ]; then
    whiptail --title "$(translate "Warnings and Errors")" --msgbox "$ERROR_MESSAGES" 16 70
fi

exit 0