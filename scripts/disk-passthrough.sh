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
# This script allows users to assign physical disks for passthrough to existing
# Proxmox virtual machines (VMs) through an interactive menu.
# - Detects the system disk and excludes it from selection.
# - Lists all available VMs for the user to choose from.
# - Identifies and displays unassigned physical disks.
# - Allows the user to select multiple disks and attach them to a VM.
# - Supports interface types: SATA, SCSI, VirtIO, and IDE.
# - Ensures that disks are not already assigned to active VMs.
# - Warns about disk sharing between multiple VMs to avoid data corruption.
# - Configures the selected disks for the VM and verifies the assignment.
#
# The goal of this script is to simplify the process of assigning
# physical disks to Proxmox VMs, reducing manual configurations
# and preventing potential errors.
# ==========================================================


# Configuration ============================================
UTILS_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main/scripts/utils.sh"
BASE_DIR="/usr/local/share/proxmenux"
CACHE_FILE="$BASE_DIR/cache.json"
CONFIG_FILE="$BASE_DIR/config.json"
VENV_PATH="/opt/googletrans-env"

if ! source <(curl -sSf "$UTILS_URL"); then
    echo "$(translate 'Error: Could not load utils.sh from') $UTILS_URL"
    exit 1
fi

load_language
initialize_cache
# ==========================================================



# Function to identify the physical disk where Proxmox is installed
get_physical_disk() {
    local lv_path=$1
    local pv_name
    pv_name=$(pvs --noheadings -o pv_name 2>/dev/null | grep -v "/dev/mapper" | head -n1 | tr -d ' ') || true
    if [ -z "$pv_name" ]; then
        echo "$(translate "Could not determine the physical disk. Is LVM installed?")" >&2
        return 1
    fi
    echo "$pv_name" | sed 's/[0-9]*$//'
}

# Function to get detailed disk information
get_disk_info() {
    local disk=$1
    lsblk -ndo NAME,MODEL,SIZE "$disk" | awk '{print $1 " " $2 " " $3}'
}

# Detect the root partition and associated physical disk
root_device=$(findmnt -n -o SOURCE / 2>/dev/null) || { echo "$(translate "Could not determine the root device.")" >&2; exit 1; }
if [[ $root_device == /dev/mapper/* ]]; then
    physical_disk=$(get_physical_disk "$root_device")
else
    physical_disk=$(echo "$root_device" | sed 's/[0-9]*$//')
fi

if [ -z "$physical_disk" ]; then
    echo "$(translate "Could not determine the physical disk.")" >&2
    exit 1
fi

msg_ok "$(translate "System physical disk identified"): $physical_disk. $(translate "This disk will not be shown.")"

# Display list of available VMs
VM_LIST=$(qm list | awk 'NR>1 {print $1, $2}')
if [ -z "$VM_LIST" ]; then
    whiptail --title "$(translate "Error")" --msgbox "$(translate "No VMs available in the system.")" 8 40
    exit 1
fi

# Select VM
VMID=$(whiptail --title "$(translate "Select VM")" --menu "$(translate "Select the VM to which you want to add disks:")" 15 60 8 $VM_LIST 3>&1 1>&2 2>&3)

if [ -z "$VMID" ]; then
    whiptail --title "$(translate "Error")" --msgbox "$(translate "No VM was selected.")" 8 40
    exit 1
fi

VMID=$(echo "$VMID" | tr -d '"')

# Verify that VMID is a number
if ! [[ "$VMID" =~ ^[0-9]+$ ]]; then
    whiptail --title "$(translate "Error")" --msgbox "$(translate "The selected VM ID is not valid.")" 8 40
    exit 1
fi

clear
msg_ok "$(translate "VM selected successfully.")"

# Check if the VM is powered on
VM_STATUS=$(qm status "$VMID" | awk '{print $2}')
if [ "$VM_STATUS" == "running" ]; then
    whiptail --title "$(translate "Warning")" --msgbox "$(translate "The VM is powered on. Turn it off before adding disks.")" 12 60
    exit 1
fi

msg_info2 "$(translate "Detecting available disks...")"

# Detect free disks, excluding the system disk and those already assigned to the selected VM
FREE_DISKS=()
while read -r LINE; do
    DISK=$(echo "$LINE" | awk '{print $1}')
    if [[ "/dev/$DISK" != "$physical_disk" ]] && ! qm config "$VMID" | grep -q "/dev/$DISK"; then
        DESCRIPTION=$(echo "$LINE" | awk '{$1=""; print $0}' | xargs)
        FREE_DISKS+=("/dev/$DISK" "$DESCRIPTION" "OFF")
    fi
done < <(lsblk -d -n -e 7,11 -o NAME,MODEL,SIZE)

msg_ok "$(translate "Available disks detected.")"

if [ "${#FREE_DISKS[@]}" -eq 0 ]; then
    whiptail --title "$(translate "Error")" --msgbox "$(translate "No disks available for this VM.")" 8 40
    clear
    exit 1
fi

# Calculate maximum content length
MAX_WIDTH=$(printf "%s\n" "${FREE_DISKS[@]}" | awk '{print length}' | sort -nr | head -n1)
TOTAL_WIDTH=$((MAX_WIDTH + 20)) # Add additional margin

# Set a reasonable minimum width
if [ $TOTAL_WIDTH -lt 70 ]; then
    TOTAL_WIDTH=70
fi

# Display menu to select free disks with dynamically calculated width
SELECTED=$(whiptail --title "$(translate "Select Disks")" --checklist \
    "$(translate "Select the disks you want to add:")" 20 $TOTAL_WIDTH 10 "${FREE_DISKS[@]}" 3>&1 1>&2 2>&3)

# Check if disks were selected
if [ -z "$SELECTED" ]; then
    whiptail --title "$(translate "Error")" --msgbox "$(translate "No disks were selected.")" 10 $TOTAL_WIDTH
    clear
    exit 1
fi

msg_ok "$(translate "Disks selected successfully.")"

# Select interface type once for all disks
INTERFACE=$(whiptail --title "$(translate "Interface Type")" --menu "$(translate "Select the interface type for all disks:")" 15 40 4 \
    "sata" "$(translate "Add as SATA")" \
    "scsi" "$(translate "Add as SCSI")" \
    "virtio" "$(translate "Add as VirtIO")" \
    "ide" "$(translate "Add as IDE")" 3>&1 1>&2 2>&3)

if [ -z "$INTERFACE" ]; then
    whiptail --title "$(translate "Error")" --msgbox "$(translate "No interface type was selected for the disks.")" 8 40
    clear
    exit 1
fi

msg_ok "$(translate "Interface type selected: $INTERFACE")"

# Verify selected disks
DISKS_ADDED=0
ERROR_MESSAGES=""
SUCCESS_MESSAGES=""

msg_info2 "$(translate "Processing selected disks...")"

for DISK in $SELECTED; do
    DISK=$(echo "$DISK" | tr -d '"')
    DISK_INFO=$(get_disk_info "$DISK")

    # Check if the disk is already assigned to another VM
    ASSIGNED_TO=""
    while read -r VM_ID VM_NAME; do
        if [[ "$VM_ID" =~ ^[0-9]+$ ]] && qm config "$VM_ID" | grep -q "$DISK"; then
            ASSIGNED_TO+="$VM_ID $VM_NAME\n"
        fi
    done < <(qm list | awk 'NR>1 {print $1, $2}')

    CONTINUE=true
    if [ -n "$ASSIGNED_TO" ]; then
        RUNNING_VMS=""
        while read -r VM_ID VM_NAME; do
            if [[ "$VM_ID" =~ ^[0-9]+$ ]] && [ "$(qm status "$VM_ID" | awk '{print $2}')" == "running" ]; then
                RUNNING_VMS+="$VM_ID $VM_NAME\n"
            fi
        done < <(echo -e "$ASSIGNED_TO")

        if [ -n "$RUNNING_VMS" ]; then
            ERROR_MESSAGES+="$(translate "The disk") $DISK_INFO $(translate "is in use by the following running VM(s):")\\n$RUNNING_VMS\\n\\n"
            CONTINUE=false
        fi
    fi

    if $CONTINUE; then
        INDEX=0
        while qm config "$VMID" | grep -q "${INTERFACE}${INDEX}"; do
            ((INDEX++))
        done

        # Perform the assignment
        RESULT=$(qm set "$VMID" -${INTERFACE}${INDEX} "$DISK" 2>&1)

        if [ $? -eq 0 ]; then
            MESSAGE="$(translate "The disk") $DISK_INFO $(translate "has been successfully added to VM") $VMID."
            if [ -n "$ASSIGNED_TO" ]; then
                MESSAGE+="\n$(translate "WARNING: This disk is also assigned to the following VM(s):")\n$ASSIGNED_TO"
                MESSAGE+="$(translate "Make sure not to power on VMs that share this disk simultaneously to avoid data corruption.")\n"
            fi
            SUCCESS_MESSAGES+="$MESSAGE\\n\\n"
            ((DISKS_ADDED++))
        else
            ERROR_MESSAGES+="$(translate "Could not add disk") $DISK_INFO $(translate "to VM") $VMID.\\n$(translate "Error:") $RESULT\\n\\n"
        fi
    fi
done

msg_ok "$(translate "Disk processing completed.")"

# Display success messages
if [ -n "$SUCCESS_MESSAGES" ]; then


MSG_LINES=$(echo "$SUCCESS_MESSAGES" | wc -l)



 whiptail --title "$(translate "Successful Operations")" --scrolltext --msgbox "$SUCCESS_MESSAGES" 20 70



fi

# Display error or warning messages if any
if [ -n "$ERROR_MESSAGES" ]; then
    whiptail --title "$(translate "Warnings and Errors")" --scrolltext --msgbox "$ERROR_MESSAGES" 20 70
fi

# Operation completed message
if [ $DISKS_ADDED -gt 0 ]; then
    whiptail --title "$(translate "Operation Completed")" --msgbox "$(translate "$DISKS_ADDED disk(s) were successfully added to VM") $VMID." 8 60
else
    whiptail --title "$(translate "Information")" --msgbox "$(translate "No disks were added to VM") $VMID." 8 60
fi

clear
exit 0
