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


# Configuration
UTILS_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main/scripts/utils.sh"
BASE_DIR="/usr/local/share/proxmenux"
CACHE_FILE="$BASE_DIR/cache.json"
VENV_PATH="/opt/googletrans-env"  
LANGUAGE=$(jq -r '.language // "en"' "$BASE_DIR/config.json" 2>/dev/null)



# Try to load utils.sh from GitHub
if ! source <(curl -sSf "$UTILS_URL"); then
    echo "$(translate 'Error: Could not load utils.sh from') $UTILS_URL"
    exit 1
fi

# Path where disk images are stored
IMAGES_DIR="/var/lib/vz/template/images/"

# Check if there are any images in the directory
IMAGES=$(ls -A "$IMAGES_DIR" | grep -E "\.(img|qcow2|vmdk)$")
if [ -z "$IMAGES" ]; then
    msg_error "$(translate 'No images available for import in') $IMAGES_DIR"
    echo -e "${YW}$(translate 'Supported formats: .img, .qcow2, .vmdk')${CL}"
    echo -e "${YW}$(translate 'Please add some images and try again.')${CL}"
    exit 0
fi



# Initial setup
if ! [ -d "$IMAGES_DIR" ]; then
    msg_info "$(translate 'Creating images directory')"
    mkdir -p "$IMAGES_DIR"
    msg_ok "$(translate 'Images directory created')"
fi

# Display initial message
whiptail --title "$(translate 'Import Disk Image')" --msgbox "$(translate 'Make sure the disk images you want to import are located in:')\n\n$IMAGES_DIR\n\n$(translate 'Supported formats: .img, .qcow2, .vmdk.')" 12 60



# 1. Select VM
msg_info "$(translate 'Getting VM list')"
VM_LIST=$(qm list | awk 'NR>1 {print $1" "$2}')
if [ -z "$VM_LIST" ]; then
    msg_error "$(translate 'No VMs available in the system')"
    exit 1
fi
msg_ok "$(translate 'VM list obtained')"

VMID=$(whiptail --title "$(translate 'Select VM')" --menu "$(translate 'Select the VM where you want to import the disk image:')" 15 60 8 $VM_LIST 3>&1 1>&2 2>&3)

if [ -z "$VMID" ]; then
    msg_error "$(translate 'No VM selected')"
    exit 1
fi



# 2. Select storage volume
msg_info "$(translate 'Getting storage volumes')"
STORAGE_LIST=$(pvesm status -content images | awk 'NR>1 {print $1}')
if [ -z "$STORAGE_LIST" ]; then
    msg_error "$(translate 'No storage volumes available')"
    exit 1
fi
msg_ok "$(translate 'Storage volumes obtained')"

# Create an array of storage options for whiptail
STORAGE_OPTIONS=()
while read -r storage; do
    STORAGE_OPTIONS+=("$storage" "")
done <<< "$STORAGE_LIST"

STORAGE=$(whiptail --title "$(translate 'Select Storage')" --menu "$(translate 'Select the storage volume for disk import:')" 15 60 8 "${STORAGE_OPTIONS[@]}" 3>&1 1>&2 2>&3)

if [ -z "$STORAGE" ]; then
    msg_error "$(translate 'No storage selected')"
    exit 1
fi



# 3. Select disk images
msg_info "$(translate 'Scanning disk images')"
if [ -z "$IMAGES" ]; then
    msg_error "$(translate 'No compatible disk images found in') $IMAGES_DIR"
    exit 0
fi
msg_ok "$(translate 'Disk images found')"

IMAGE_OPTIONS=()
while read -r img; do
    IMAGE_OPTIONS+=("$img" "" "OFF")
done <<< "$IMAGES"

SELECTED_IMAGES=$(whiptail --title "$(translate 'Select Disk Images')" --checklist "$(translate 'Select the disk images to import:')" 20 60 10 "${IMAGE_OPTIONS[@]}" 3>&1 1>&2 2>&3)

if [ -z "$SELECTED_IMAGES" ]; then
    msg_error "$(translate 'No images selected')"
    exit 1
fi

# 4. Import each selected image
for IMAGE in $SELECTED_IMAGES; do

    # Remove quotes from selected image
    IMAGE=$(echo "$IMAGE" | tr -d '"')

    # 5. Select interface type for each image
    INTERFACE=$(whiptail --title "$(translate 'Interface Type')" --menu "$(translate 'Select the interface type for the image:') $IMAGE" 15 40 4 \
    "sata" "SATA" \
    "scsi" "SCSI" \
    "virtio" "VirtIO" \
    "ide" "IDE" 3>&1 1>&2 2>&3)

    if [ -z "$INTERFACE" ]; then
        msg_error "$(translate 'No interface type selected for') $IMAGE"
        continue
    fi

    FULL_PATH="$IMAGES_DIR/$IMAGE"

    # Show initial message
    msg_info "$(translate 'Importing image:')"

    # Temporary file to capture the imported disk
    TEMP_DISK_FILE=$(mktemp)


    # Execute the command and process its output in real-time
    qm importdisk "$VMID" "$FULL_PATH" "$STORAGE" 2>&1 | while read -r line; do
        if [[ "$line" =~ transferred ]]; then

            # Extract the progress percentage
            PERCENT=$(echo "$line" | grep -oP "\(\d+\.\d+%\)" | tr -d '()%')

            # Show progress with custom format without translation
            echo -ne "\r${TAB}${YW}-$(translate 'Importing image:') $IMAGE-${CL} ${PERCENT}%"

        elif [[ "$line" =~ successfully\ imported\ disk ]]; then

            # Extract the imported disk name and save it to the temporary file
            echo "$line" | grep -oP "(?<=successfully imported disk ').*(?=')" > "$TEMP_DISK_FILE"
        fi
    done
    echo -ne "\n" 


    IMPORT_STATUS=${PIPESTATUS[0]} # Capture the exit status of the main command

    if [ $IMPORT_STATUS -eq 0 ]; then
        msg_ok "$(translate 'Image imported successfully')"

        # Read the imported disk from the temporary file
        IMPORTED_DISK=$(cat "$TEMP_DISK_FILE")
        rm -f "$TEMP_DISK_FILE" # Delete the temporary file

        if [ -n "$IMPORTED_DISK" ]; then
        
            # Find the next available disk slot
            EXISTING_DISKS=$(qm config "$VMID" | grep -oP "${INTERFACE}\d+" | sort -n)
            if [ -z "$EXISTING_DISKS" ]; then
            
                # If there are no existing disks, start from 0
                NEXT_SLOT=0
            else
                # If there are existing disks, take the last one and add 1
                LAST_SLOT=$(echo "$EXISTING_DISKS" | tail -n1 | sed "s/${INTERFACE}//")
                NEXT_SLOT=$((LAST_SLOT + 1))
            fi
            

            # Ask if SSD emulation is desired (only for non-VirtIO interfaces)
            if [ "$INTERFACE" != "virtio" ]; then
                if (whiptail --title "$(translate 'SSD Emulation')" --yesno "$(translate 'Do you want to use SSD emulation for this disk?')" 10 60); then
                    SSD_OPTION=",ssd=1"
                else
                    SSD_OPTION=""
                fi
            else
                SSD_OPTION=""
            fi
            

            msg_info "$(translate 'Configuring disk')"

            # Configure the disk in the VM
            if qm set "$VMID" --${INTERFACE}${NEXT_SLOT} "$IMPORTED_DISK${SSD_OPTION}" &>/dev/null; then
                msg_ok "$(translate 'Image') $IMAGE $(translate 'configured as') ${INTERFACE}${NEXT_SLOT}"

                # Ask if the disk should be bootable
                if (whiptail --title "$(translate 'Make Bootable')" --yesno "$(translate 'Do you want to make this disk bootable?')" 10 60); then
                    msg_info "$(translate 'Configuring disk as bootable')"
                    
                    if qm set "$VMID" --boot c --bootdisk ${INTERFACE}${NEXT_SLOT} &>/dev/null; then
                        msg_ok "$(translate 'Disk configured as bootable')"
                    else
                        msg_error "$(translate 'Could not configure the disk as bootable')"
                    fi
                fi
            else
                msg_error "$(translate 'Could not configure disk') ${INTERFACE}${NEXT_SLOT} $(translate 'for VM') $VMID"
            fi
        else
            msg_error "$(translate 'Could not find the imported disk')"
        fi
    else
        msg_error "$(translate 'Could not import') $IMAGE"
    fi
done

msg_ok "$(translate 'All selected images have been processed')"
sleep 2
