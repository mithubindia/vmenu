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
# This script provides an interactive command reference menu
# for Proxmox VE via dialog-based UI.
# - Categorized and translated lists of common and advanced commands.
# - Covers system, network, storage, VM/CT, updates, GPU passthrough,
#   ZFS, backup/restore, and essential CLI tools.
# - Allows users to view or execute commands directly from the menu.
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
# ===============================================================

# Colores
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
NC="\033[0m"

if ! command -v dialog &>/dev/null; then
    apt update -qq >/dev/null 2>&1
    apt install -y dialog >/dev/null 2>&1
fi


# ===============================================================
# 01 Useful System Commands
# ===============================================================
show_system_commands() {
    clear
    echo -e "${YELLOW}$(translate 'Useful System Commands')${NC}"
    echo "----------------------------------------"
    echo -e " 1) ${GREEN}pveversion${NC}                 - $(translate 'Show Proxmox version')"
    echo -e " 2) ${GREEN}pveversion -v${NC}              - $(translate 'Detailed Proxmox version info')"
    echo -e " 3) ${GREEN}systemctl status pveproxy${NC}  - $(translate 'Check Proxmox Web UI status')"
    echo -e " 4) ${GREEN}systemctl restart pveproxy${NC} - $(translate 'Restart Web UI proxy')"
    echo -e " 5) ${GREEN}journalctl -xe${NC}             - $(translate 'System errors and logs')"
    echo -e " 6) ${GREEN}uptime${NC}                     - $(translate 'System uptime')"
    echo -e " 0) $(translate 'Back to previous menu')"
    echo
    echo -en "${TAB}${BOLD}${YW}${HOLD}$(translate 'Enter number or paste a command: ') ${CL}"
    read -r user_input

    case "$user_input" in
        1) cmd="pveversion" ;;
        2) cmd="pveversion -v" ;;
        3) cmd="systemctl status pveproxy" ;;
        4) cmd="systemctl restart pveproxy" ;;
        5) cmd="journalctl -xe" ;;
        6) cmd="uptime" ;;
        7) cmd="htop" ;;
        0) return ;;
        *) cmd="$user_input" ;;
    esac

    echo -e "
${GREEN}> $cmd${NC}
"
    bash -c "$cmd"
    echo
    msg_success "$(translate 'Press ENTER to return to the menu...')"
    read -r tmp
}

# ===============================================================
# 02 VM and CT Management Commands
# ===============================================================
show_vm_ct_commands() {
    clear
    echo -e "${YELLOW}$(translate 'VM and CT Management Commands')${NC}"
    echo "---------------------------------------------------"
    echo -e " 1) ${GREEN}qm list${NC}                  - $(translate 'List all virtual machines')"
    echo -e " 2) ${GREEN}pct list${NC}                 - $(translate 'List all LXC containers')"
    echo -e " 3) ${GREEN}qm start <vmid>${NC}          - $(translate 'Start a virtual machine. Replace <vmid> with the correct ID')"
    echo -e " 4) ${GREEN}pct start <ctid>${NC}         - $(translate 'Start a container. Replace <ctid> with the correct ID')"
    echo -e " 5) ${GREEN}qm stop <vmid>${NC}           - $(translate 'Force stop a virtual machine. Replace <vmid> with the correct ID')"
    echo -e " 6) ${GREEN}pct stop <ctid>${NC}          - $(translate 'Force stop a container. Replace <ctid> with the correct ID')"
    echo -e " 7) ${GREEN}qm config <vmid>${NC}         - $(translate 'Show VM configuration. Replace <vmid> with the correct ID')"
    echo -e " 8) ${GREEN}pct config <ctid>${NC}        - $(translate 'Show container configuration. Replace <ctid> with the correct ID')"
    echo -e " 9) ${GREEN}qm destroy <vmid>${NC}        - $(translate 'Delete a VM (irreversible). Replace <vmid> with the correct ID')"
    echo -e " 10) ${GREEN}pct destroy <ctid>${NC}      - $(translate 'Delete a CT (irreversible). Replace <vmid> with the correct ID')"
    echo -e " 0) $(translate 'Back to previous menu')"
    echo
    echo -en "${TAB}${BOLD}${YW}${HOLD}$(translate 'Enter number or paste a command: ') ${CL}"
    read -r user_input

    case "$user_input" in
        1) cmd="qm list" ;;
        2) cmd="pct list" ;;
        3) cmd="qm start <vmid>" ;;
        4) cmd="pct start <ctid>" ;;
        5) cmd="qm stop <vmid>" ;;
        6) cmd="pct stop <ctid>" ;;
        7) cmd="qm config <vmid>" ;;
        8) cmd="pct config <ctid>" ;;
        9) cmd="qm destroy <vmid>" ;;
        10) cmd="pct destroy <ctid>" ;;
        0) return ;;
        *) cmd="$user_input" ;;
    esac

    echo -e "
${GREEN}> $cmd${NC}
"
    bash -c "$cmd"
    echo
    msg_success "$(translate 'Press ENTER to return to the menu...')"
    read -r tmp
}


# ===============================================================
# 03 Storage and Disks Commands
# ===============================================================
show_storage_commands() {
    clear
    echo -e "${YELLOW}$(translate 'Storage and Disks Commands')${NC}"
    echo "--------------------------------------------------"
    echo -e " 1) ${GREEN}lsblk${NC}                    - $(translate 'List block devices and partitions')"
    echo -e " 2) ${GREEN}fdisk -l${NC}                 - $(translate 'List disks with detailed info')"
    echo -e " 3) ${GREEN}df -h${NC}                    - $(translate 'Show disk usage by mount point')"
    echo -e " 4) ${GREEN}pvdisplay${NC}                - $(translate 'Display physical volumes (LVM)')"
    echo -e " 5) ${GREEN}vgdisplay${NC}                - $(translate 'Display volume groups (LVM)')"
    echo -e " 6) ${GREEN}lvdisplay${NC}                - $(translate 'Display logical volumes (LVM)')"
    echo -e " 7) ${GREEN}cat /etc/pve/storage.cfg${NC} - $(translate 'Show Proxmox storage configuration')"
    echo -e " 0) $(translate 'Back to previous menu')"
    echo
    echo -en "${TAB}${BOLD}${YW}${HOLD}$(translate 'Enter number or paste a command: ') ${CL}"
    read -r user_input

    case "$user_input" in
        1) cmd="lsblk" ;;
        2) cmd="fdisk -l" ;;
        3) cmd="df -h" ;;
        4) cmd="pvdisplay" ;;
        5) cmd="vgdisplay" ;;
        6) cmd="lvdisplay" ;;
        7) cmd="cat /etc/pve/storage.cfg" ;;
        0) return ;;
        *) cmd="$user_input" ;;
    esac

    echo -e "
${GREEN}> $cmd${NC}
"
    bash -c "$cmd"
    echo
    msg_success "$(translate 'Press ENTER to return to the menu...')"
    read -r tmp
}


# ===============================================================
# 04 Network Commands
# ===============================================================
show_network_commands() {
    clear
    echo -e "${YELLOW}$(translate 'Network Commands')${NC}"
    echo "------------------------------------------"
    echo -e " 1) ${GREEN}ip a${NC}                        - $(translate 'Show network interfaces and IPs')"
    echo -e " 2) ${GREEN}ip r${NC}                        - $(translate 'Show routing table')"
    echo -e " 3) ${GREEN}ping <host>${NC}                 - $(translate 'Check connectivity with another host')"
    echo -e " 4) ${GREEN}brctl show${NC}                  - $(translate 'Show configured network bridges')"
    echo -e " 5) ${GREEN}ifreload -a${NC}                 - $(translate 'Reload network configuration (ifupdown2)')"
    echo -e " 6) ${GREEN}cat /etc/network/interfaces${NC} - $(translate 'Show raw network configuration')"
    echo -e " 0) $(translate 'Back to previous menu')"
    echo
    echo -en "${TAB}${BOLD}${YW}${HOLD}$(translate 'Enter number or paste a command: ') ${CL}"
    read -r user_input

    case "$user_input" in
        1) cmd="ip a" ;;
        2) cmd="ip r" ;;
        3) cmd="ping <host>" ;;
        4) cmd="brctl show" ;;
        5) cmd="ifreload -a" ;;
        6) cmd="cat /etc/network/interfaces" ;;
        0) return ;;
        *) cmd="$user_input" ;;
    esac

    echo -e "
${GREEN}> $cmd${NC}
"
    bash -c "$cmd"
    echo
    msg_success "$(translate 'Press ENTER to return to the menu...')"
    read -r tmp
}


# ===============================================================
# 05 Updates and Packages Commands
# ===============================================================
show_update_commands() {
    clear
    echo -e "${YELLOW}$(translate 'Updates and Packages Commands')${NC}"
    echo "----------------------------------------------------"
    echo -e " 1) ${GREEN}apt update && apt upgrade -y${NC}     - $(translate 'Update and upgrade all system packages')"
    echo -e " 2) ${GREEN}apt dist-upgrade -y${NC}              - $(translate 'Full system upgrade, including dependencies')"
    echo -e " 3) ${GREEN}pveupdate${NC}                        - $(translate 'Update Proxmox package lists')"
    echo -e " 4) ${GREEN}pveupgrade${NC}                       - $(translate 'Show available Proxmox upgrades')"
    echo -e " 5) ${GREEN}apt autoremove --purge${NC}           - $(translate 'Remove unused packages and their config')"
    echo -e " 0) $(translate 'Back to previous menu')"
    echo
    echo -en "${TAB}${BOLD}${YW}${HOLD}$(translate 'Enter number or paste a command: ') ${CL}"
    read -r user_input

    case "$user_input" in
        1) cmd="apt update && apt upgrade -y" ;;
        2) cmd="apt dist-upgrade -y" ;;
        3) cmd="pveupdate" ;;
        4) cmd="pveupgrade" ;;
        5) cmd="apt autoremove --purge" ;;
        0) return ;;
        *) cmd="$user_input" ;;
    esac

    echo -e "
${GREEN}> $cmd${NC}
"
    bash -c "$cmd"
    echo
    msg_success "$(translate 'Press ENTER to return to the menu...')"
    read -r tmp
}


# ===============================================================
# 06 GPU Passthrough Commands
# ===============================================================
show_gpu_commands() {
    clear
    echo -e "${YELLOW}$(translate 'GPU Passthrough Commands')${NC}"
    echo "------------------------------------------------"
    echo -e " 1) ${GREEN}lspci -nn | grep -i nvidia${NC}       - $(translate 'List NVIDIA PCI devices')"
    echo -e " 2) ${GREEN}lspci -nn | grep -i vga${NC}          - $(translate 'List all VGA compatible devices')"
    echo -e " 3) ${GREEN}dmesg | grep -i vfio${NC}             - $(translate 'Check VFIO module messages')"
    echo -e " 4) ${GREEN}cat /etc/modprobe.d/vfio.conf${NC}    - $(translate 'Review VFIO passthrough configuration')"
    echo -e " 5) ${GREEN}update-initramfs -u${NC}              - $(translate 'Apply initramfs changes (VFIO)')"
    echo -e " 6) ${GREEN}cat /etc/default/grub${NC}            - $(translate 'Review GRUB options for IOMMU')"
    echo -e " 7) ${GREEN}update-grub${NC}                      - $(translate 'Apply GRUB changes')"
    echo -e " 0) $(translate 'Back to previous menu')"
    echo
    echo -en "${TAB}${BOLD}${YW}${HOLD}$(translate 'Enter number or paste a command: ') ${CL}"
    read -r user_input

    case "$user_input" in
        1) cmd="lspci -nn | grep -i nvidia" ;;
        2) cmd="lspci -nn | grep -i vga" ;;
        3) cmd="dmesg | grep -i vfio" ;;
        4) cmd="cat /etc/modprobe.d/vfio.conf" ;;
        5) cmd="update-initramfs -u" ;;
        6) cmd="cat /etc/default/grub" ;;
        7) cmd="update-grub" ;;
        0) return ;;
        *) cmd="$user_input" ;;
    esac

    echo -e "
${GREEN}> $cmd${NC}
"
    bash -c "$cmd"
    echo
    msg_success "$(translate 'Press ENTER to return to the menu...')"
    read -r tmp
}


# ===============================================================
# 07 ZFS Management Commands
# ===============================================================
show_zfs_commands() {
    clear
    echo -e "${YELLOW}$(translate 'ZFS Management Commands')${NC}"
    echo "------------------------------------------------"
    echo -e " 1) ${GREEN}zpool status${NC}                  - $(translate 'Show ZFS pool status')"
    echo -e " 2) ${GREEN}zpool list${NC}                    - $(translate 'List all ZFS pools')"
    echo -e " 3) ${GREEN}zfs list${NC}                      - $(translate 'List ZFS datasets and snapshots')"
    echo -e " 4) ${GREEN}zpool scrub <pool>${NC}            - $(translate 'Start scrub for a ZFS pool')"
    echo -e " 5) ${GREEN}zfs create <pool>/dataset${NC}     - $(translate 'Create a new dataset in a ZFS pool')"
    echo -e " 6) ${GREEN}zfs destroy <pool>/dataset${NC}    - $(translate 'Destroy a ZFS dataset (irreversible)')"
    echo -e " 0) $(translate 'Back to previous menu')"
    echo
    echo -en "${TAB}${BOLD}${YW}${HOLD}$(translate 'Enter number or paste a command: ') ${CL}"
    read -r user_input

    case "$user_input" in
        1) cmd="zpool status" ;;
        2) cmd="zpool list" ;;
        3) cmd="zfs list" ;;
        4) cmd="zpool scrub <pool>" ;;
        5) cmd="zfs create <pool>/dataset" ;;
        6) cmd="zfs destroy <pool>/dataset" ;;
        0) return ;;
        *) cmd="$user_input" ;;
    esac

    echo -e "\n${GREEN}> $cmd${NC}\n"
    bash -c "$cmd"
    echo
    msg_success "$(translate 'Press ENTER to return to the menu...')"
    read -r tmp
}


# ===============================================================
# 08 Backup and Restore Commands
# ===============================================================
show_backup_commands() {
    clear
    echo -e "${YELLOW}$(translate 'Backup and Restore Commands')${NC}"
    echo "------------------------------------------------------"
    echo -e " 1) ${GREEN}vzdump <vmid>${NC}                           - $(translate 'Manual backup of a VM or CT')"
    echo -e " 2) ${GREEN}vzdump <vmid> --dumpdir /path${NC}           - $(translate 'Backup to a specific directory')"
    echo -e " 3) ${GREEN}vzdump --all${NC}                            - $(translate 'Backup all VMs and CTs')"
    echo -e " 4) ${GREEN}qmrestore /path/backup.vma.zst <vmid>${NC}   - $(translate 'Restore a VM from backup')"
    echo -e " 5) ${GREEN}pct restore <vmid> /path/backup.tar.zst${NC} - $(translate 'Restore a CT from backup')"
    echo -e " 0) $(translate 'Back to previous menu')"
    echo
    echo -en "${TAB}${BOLD}${YW}${HOLD}$(translate 'Enter number or paste a command: ') ${CL}"
    read -r user_input

    case "$user_input" in
        1) cmd="vzdump <vmid>" ;;
        2) cmd="vzdump <vmid> --dumpdir /path" ;;
        3) cmd="vzdump --all" ;;
        4) cmd="qmrestore /path/backup.vma.zst <vmid>" ;;
        5) cmd="pct restore <vmid> /path/backup.tar.zst" ;;
        0) return ;;
        *) cmd="$user_input" ;;
    esac

    echo -e "
${GREEN}> $cmd${NC}
"
    bash -c "$cmd"
    echo
    msg_success "$(translate 'Press ENTER to return to the menu...')"
    read -r tmp
}


# ===============================================================
# 09 Essential Tools Installation Commands
# ===============================================================
show_tools_commands() {
    clear
    echo -e "${YELLOW}$(translate 'Essential CLI Tools')${NC}"
    echo "--------------------------------------------"
    echo -e " 1) ${GREEN}htop${NC}      - $(translate 'Interactive process viewer')"
    echo -e " 2) ${GREEN}btop${NC}      - $(translate 'Modern resource monitor')"
    echo -e " 3) ${GREEN}iftop${NC}     - $(translate 'Real-time bandwidth usage')"
    echo -e " 4) ${GREEN}iotop${NC}     - $(translate 'Monitor disk I/O usage')"
    echo -e " 5) ${GREEN}tmux${NC}      - $(translate 'Terminal multiplexer')"
    echo -e " 6) ${GREEN}iperf3${NC}    - $(translate 'Network throughput test')"
    echo -e " 0) $(translate 'Back to previous menu')"
    echo
    echo -en "${TAB}${BOLD}${YW}${HOLD}$(translate 'Enter number or paste a command: ') ${CL}"
    read -r user_input

    case "$user_input" in
        1) cmd="htop" ;;
        2) cmd="btop" ;;
        3) cmd="iftop" ;;
        4) cmd="iotop" ;;
        5) cmd="tmux" ;;
        6) cmd="iperf3" ;;
        0) return ;;
        *) cmd="$user_input" ;;
    esac

    echo -e "
${GREEN}> $cmd${NC}
"
    bash -c "$cmd"
    echo
    msg_success "$(translate 'Press ENTER to return to the menu...')"
    read -r tmp
}


# ===============================================================
# Main Menu
# ===============================================================
while true; do
OPTION=$(dialog --stdout \
    --title "$(translate 'Help and Info')" \
    --menu "$(translate 'Select a category of useful commands:')" 20 70 12 \
    1 "$(translate 'Useful System Commands')" \
    2 "$(translate 'VM and CT Management Commands')" \
    3 "$(translate 'Storage and Disks Commands')" \
    4 "$(translate 'Network Commands')" \
    5 "$(translate 'Updates and Packages Commands')" \
    6 "$(translate 'GPU Passthrough Commands')" \
    7 "$(translate 'ZFS Management Commands')" \
    8 "$(translate 'Backup and Restore Commands')" \
    9 "$(translate 'Essential CLI Tools')" \
    0 "$(translate 'Exit')")
    case $OPTION in
        1)
            show_system_commands
            ;;
        2)
            show_vm_ct_commands
            ;;
        3)
            show_storage_commands
            ;;
        4)
            show_network_commands
            ;;
        5)
            show_update_commands
            ;;
        6)
            show_gpu_commands
            ;;
        7)
            show_zfs_commands
            ;;
        8)
            show_backup_commands
            ;;
        9)
            show_tools_commands
            ;;
        0)  clear
            break
            ;;
    
        *) 
            msg_info2 "$(translate 'Invalid option, please try again.')"
            read -r
            ;;
    esac
done
