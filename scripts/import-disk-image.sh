#!/bin/bash

# Source utility functions from local installation
source "/usr/local/share/proxmenux/utils.sh"

# Path where disk images are stored
IMAGES_DIR="/var/lib/vz/template/images/"

# Check if there are any images in the directory
IMAGES=$(ls -A "$IMAGES_DIR" | grep -E "\.(img|qcow2|vmdk)$")
if [ -z "$IMAGES" ]; then
    whiptail --title "$(translate 'No Images Available')" --msgbox "$(translate 'No disk images available for import in') $IMAGES_DIR\n\n$(translate 'Supported formats: .img, .qcow2, .vmdk')\n\n$(translate 'Please add some images and try again.')" 12 60
    exit 0
fi

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

# 2. Select storage volume
msg_info "$(translate 'Getting storage volumes...')"
STORAGE_LIST=$(pvesm status -content images | awk 'NR>1 {print $1}')
if [ -z "$STORAGE_LIST" ]; then
    msg_error "$(translate 'No storage volumes available')"
    exit 1
fi
msg_ok "$(translate 'Storage volumes retrieved')"

# Create an array of storage options for whiptail
STORAGE_OPTIONS=()
for storage in $STORAGE_LIST; do
    STORAGE_OPTIONS+=("$storage" "$storage")
done

STORAGE=$(whiptail --title "$(translate 'Select Storage')" --menu "$(translate 'Select the storage volume for disk import:')" 15 60 8 "${STORAGE_OPTIONS[@]}" 3>&1 1>&2 2>&3)

if [ -z "$STORAGE" ]; then
    msg_error "$(translate 'No storage selected')"
    exit 1
fi

# 3. Select disk images
msg_info "$(translate 'Scanning for disk images...')"
if [ -z "$IMAGES" ]; then
    msg_error "$(translate 'No compatible disk images found in') $IMAGES_DIR"
    exit 0
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

# 4. Import each selected image
for IMAGE in $SELECTED_IMAGES; do
    # Remove quotes from selected image
    IMAGE=$(echo "$IMAGE" | tr -d '"')

    # 5. Select disk format for each image
    FORMAT=$(whiptail --title "$(translate 'Disk Format')" --menu "$(translate 'Select disk format for image:') $IMAGE" 15 40 4 \
    "raw" "$(translate 'Raw format')" \
    "qcow2" "$(translate 'QCOW2 format')" \
    "vmdk" "$(translate 'VMDK format')" 3>&1 1>&2 2>&3)

    if [ -z "$FORMAT" ]; then
        msg_error "$(translate 'No disk format selected for') $IMAGE"
        continue
    fi

    # 6. Select interface type for each image
    INTERFACE=$(whiptail --title "$(translate 'Interface Type')" --menu "$(translate 'Select interface type for image:') $IMAGE" 15 40 4 \
    "scsi" "$(translate 'SCSI')" \
    "sata" "$(translate 'SATA')" \
    "virtio" "$(translate 'VirtIO')" \
    "ide" "$(translate 'IDE')" 3>&1 1>&2 2>&3)

    if [ -z "$INTERFACE" ]; then
        msg_error "$(translate 'No interface type selected for') $IMAGE"
        continue
    fi

    FULL_PATH="$IMAGES_DIR/$IMAGE"

    msg_info "$(translate 'Importing image:') $IMAGE $(translate 'as') ${FORMAT}..."

    (
        if qm importdisk "$VMID" "$FULL_PATH" "$STORAGE" --format "$FORMAT"; then
            # Find the next available disk slot
            NEXT_SLOT=$(qm config "$VMID" | grep -oP "${INTERFACE}\d+" | sort -n | tail -n1 | sed "s/${INTERFACE}//")
            NEXT_SLOT=$((NEXT_SLOT + 1))

            IMPORTED_DISK=$(qm config "$VMID" | grep -oP "${STORAGE}:[^\s]+")

            if [ -n "$IMPORTED_DISK" ]; then
                if qm set "$VMID" --${INTERFACE}${NEXT_SLOT} "$IMPORTED_DISK"; then
                    msg_ok "$(translate 'Successfully imported') $IMAGE $(translate 'as') ${INTERFACE}${NEXT_SLOT}"
                else
                    msg_error "$(translate 'Failed to configure disk') ${INTERFACE}${NEXT_SLOT} $(translate 'for VM') $VMID"
                fi
            else
                msg_error "$(translate 'Failed to find imported disk')"
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

