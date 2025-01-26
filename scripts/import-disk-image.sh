#!/bin/bash

# ProxMenu - A menu-driven script for Proxmox VE administration
# Copyright (c) 2024 ProxMenu
# Author: MacRimi
# License: MIT
# https://raw.githubusercontent.com/MacRimi/ProxMenux/main/LICENSE

# Source utility functions
source "/usr/local/share/proxmenux/utils.sh"

# Path where disk images are stored
IMAGES_DIR="/var/lib/vz/template/images/"

# Check dependencies
check_dependencies qm whiptail jq

# Initial setup
if ! [ -d "$IMAGES_DIR" ]; then
    msg_info "$(translate 'Creating images directory...')"
    mkdir -p "$IMAGES_DIR"
    msg_ok "$(translate 'Images directory created')"
fi

# Display initial message
whiptail --title "$(translate 'Import Disk Image')" --msgbox "$(translate 'Please ensure that the disk images you want to import are located in:')\n\n$IMAGES_DIR\n\n$(translate 'Supported formats: .img, .qcow2, .vmdk.')" 12 60

# 1. Select VM
msg_info "$(translate 'Getting VM list...')"
VM_LIST=$(qm list | awk 'NR>1 {print $1, $2}')
if [ -z "$VM_LIST" ]; then
    msg_error "$(translate 'No VMs available in the system')"
    exit 1
fi
msg_ok "$(translate 'VM list retrieved')"

VMID=$(whiptail --title "$(translate 'Select VM')" --menu "$(translate 'Select the VM where you want to import the disk image:')" 15 60 8 $VM_LIST 3>&1 1>&2 2>&3)

if [ -z "$VMID" ]; then
    msg_error "$(translate 'No VM selected')"
    exit 1
fi

# 2. Select disk images
msg_info "$(translate 'Scanning for disk images...')"
IMAGES=$(ls "$IMAGES_DIR" | grep -E "\.(img|qcow2|vmdk)$")
if [ -z "$IMAGES" ]; then
    msg_error "$(translate 'No compatible disk images found in') $IMAGES_DIR"
    exit 1
fi
msg_ok "$(translate 'Disk images found')"

IMAGE_LIST=""
for img in $IMAGES; do
    IMAGE_LIST="$IMAGE_LIST $img OFF"
done

SELECTED_IMAGES=$(whiptail --title "$(translate 'Select Disk Images')" --checklist "$(translate 'Select the disk images to import:')" 20 60 10 $IMAGE_LIST 3>&1 1>&2 2>&3)

if [ -z "$SELECTED_IMAGES" ]; then
    msg_error "$(translate 'No images selected')"
    exit 1
fi

# 3. Import each selected image
for IMAGE in $SELECTED_IMAGES; do
    # Remove quotes from selected image
    IMAGE=$(echo "$IMAGE" | tr -d '"')

    # 4. Select disk type for each image
    INTERFACE=$(whiptail --title "$(translate 'Interface Type')" --menu "$(translate 'Select disk type for image:') $IMAGE" 15 40 4 \
        "sata" "$(translate 'Add as SATA')" \
        "scsi" "$(translate 'Add as SCSI')" \
        "virtio" "$(translate 'Add as VirtIO')" \
        "ide" "$(translate 'Add as IDE')" 3>&1 1>&2 2>&3)

    if [ -z "$INTERFACE" ]; then
        msg_error "$(translate 'No disk type selected for') $IMAGE"
        continue
    fi

    FULL_PATH="$IMAGES_DIR/$IMAGE"

    # 5. Add image with automatic index
    INDEX=0

    # Find available index
    while qm config "$VMID" | grep -q "${INTERFACE}${INDEX}"; do
        ((INDEX++))
    done

    msg_info "$(translate 'Importing image:') $IMAGE $(translate 'as') ${INTERFACE}${INDEX}..."
    
    (
        if qm importdisk "$VMID" "$FULL_PATH" "local-lvm" --format "$INTERFACE"; then
            if qm set "$VMID" -${INTERFACE}${INDEX} "$FULL_PATH"; then
                msg_ok "$(translate 'Successfully imported') $IMAGE $(translate 'as') ${INTERFACE}${INDEX}"
            else
                msg_error "$(translate 'Failed to configure disk') ${INTERFACE}${INDEX} $(translate 'for VM') $VMID"
            fi
        else
            msg_error "$(translate 'Failed to import') $IMAGE"
        fi
    ) &

    spinner
    wait
done

msg_ok "$(translate 'All selected images have been processed')"
exit 0
