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
# This script provides a simple and efficient way to access and execute essential Proxmox VE scripts
# from the Community Scripts project (https://community-scripts.github.io/ProxmoxVE/).
#
# It serves as a convenient tool to run key automation scripts that simplify system management,
# continuing the great work and legacy of tteck in making Proxmox VE more accessible.
# A streamlined solution for executing must-have tools in Proxmox VE.
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

# Base URL community-scripts
BASE_URL="https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc"
BASE_URL2="https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main"

download_script() {
    local url="$1"
    local fallback_pve="${url/misc/tools\/pve}"
    local fallback_addon="${url/misc/tools\/addon}"
    local fallback_copydata="${url/misc/tools\/copy-data}"

    if curl --silent --head --fail "$url" >/dev/null; then
        bash <(curl -s "$url")
    elif curl --silent --head --fail "$fallback_pve" >/dev/null; then
        bash <(curl -s "$fallback_pve")
    elif curl --silent --head --fail "$fallback_addon" >/dev/null; then
        bash <(curl -s "$fallback_addon")
    elif curl --silent --head --fail "$fallback_copydata" >/dev/null; then
        bash <(curl -s "$fallback_copydata")
    else
        msg_error "$(translate 'Error: Failed to download the script.')\033[0m"
        msg_error "\n$(translate 'Tried URLs:')\n- $url\n- $fallback_pve\n- $fallback_addons\n- $fallback_copydata\n"

        msg_success "$(translate "Press Enter to return to menu...")"
        read -r
    fi
}




# Array with script names, URLs, categories, and descriptions
scripts=(
    "Proxmox VE LXC IP-Tag|Containers|$BASE_URL/add-lxc-iptag.sh|Description:\n\nThis script automatically adds IP address as tags to LXC containers using a Systemd service.\n\nThe service also updates the tags if a LXC IP address is changed. Configuration: nano /opt/lxc-iptag/iptag.conf. iptag.service must be restarted after change.\n\n\The Proxmox Node must contain ipcalc and net-tools. apt-get install -y ipcalc net-tools"
    "Add Netbird to LXC|Networking|$BASE_URL/add-netbird-lxc.sh|Description:\n\nNetBird combines a configuration-free peer-to-peer private network and a centralized access control system in a single platform, making it easy to create secure private networks for your organization or home.\n\nAfter the script finishes, reboot the LXC then run netbird up in the LXC console.\n\n\The script only works in Debian/Ubuntu, not in Alpine!"
    "Add Tailscale to LXC|Networking|$BASE_URL/add-tailscale-lxc.sh|Description:\n\nTailscale is a software-defined networking solution that enables secure communication between devices over the internet.\n\nIt creates a virtual private network (VPN) that enables devices to communicate with each other as if they were on the same local network.\n\n\After the script finishes, reboot the LXC then run tailscale up in the LXC console."
    "Proxmox VE LXC Cleaner|Maintenance|$BASE_URL/clean-lxcs.sh|Description:\n\nThis script provides options to delete logs and cache, and repopulate apt lists for Ubuntu and Debian systems."
    "Proxmox VE Host Backup|Security|$BASE_URL/host-backup.sh|Description:\n\nThis script serves as a versatile backup utility, enabling users to specify both the backup path and the directory they want to work in.\n\nThis flexibility empowers users to select the specific files and directories they wish to back up, making it compatible with a wide range of hosts, not limited to Proxmox.\n\nA backup is rendered ineffective when it remains stored on the host"
    "Add hardware Acceleration LXC|Containers|$BASE_URL/hw-acceleration.sh|Description:\n\nEnables hardware acceleration IGPU for LXC containers."
    "Proxmox Clean Orphaned LVM|Maintenance|$BASE_URL/clean-orphaned-lvm.sh|Description:\n\nThis script helps Proxmox users identify and remove orphaned LVM volumes that are no longer associated with any VM or LXC container.\n\nIt scans all LVM volumes, detects unused ones, and provides an interactive prompt to delete them safely.\n\nSystem-critical volumes like root, swap, and data are excluded to prevent accidental deletion."
    "Install Crowdsec|Security|$BASE_URL/crowdsec.sh|Description:\n\nCrowdSec is a free and open-source intrusion prevention system (IPS) designed to provide network security against malicious traffic.\n\nIt is a collaborative IPS that analyzes behaviors and responses to attacks by sharing signals across a community of users."
    "Proxmox VE LXC Filesystem Trim|Maintenance|$BASE_URL/fstrim.sh|Description:\n\nThis maintains SSD performance by managing unused blocks.\n\nThin-provisioned storage systems also require management to prevent unnecessary storage use.\n\nVMs automate fstrim, while LXC containers need manual or automated fstrim processes for optimal performance.\n\nThis is designed to work with SSDs on ext4 filesystems only."
    "Install Glances|Monitoring|$BASE_URL/glances.sh|Description:\n\nGlances is an open-source system cross-platform monitoring tool.\n\nIt allows real-time monitoring of various aspects of your system such as CPU, memory, disk, network usage etc."
    "Proxmox VE Kernel Clean|Maintenance|$BASE_URL/kernel-clean.sh|Description:\n\nCleaning unused kernel images is beneficial for reducing the length of the GRUB menu and freeing up disk space.\n\nBy removing old, unused kernels, the system is able to conserve disk space and streamline the boot process."
    "Proxmox VE Kernel Pin|System|$BASE_URL/kernel-pin.sh|Description:\n\nKernel Pin is an essential tool for effortlessly managing kernel pinning and unpinning."
    "Container LXC Deletion|Containers|$BASE_URL/lxc-delete.sh|Description:\n\nThis script helps manage and delete LXC containers on a Proxmox VE server.\n\nIt lists all available containers, allowing the user to select one or more for deletion through an interactive menu.\n\nRunning containers are automatically stopped before deletion, and the user is asked to confirm each action.\n\nThe script ensures a controlled and efficient container management process."
    "Proxmox VE Processor Microcode|System|$BASE_URL/microcode.sh|Description:\n\nProcessor Microcode is a layer of low-level software that runs on the processor and provides patches or updates to its firmware.\n\nMicrocode updates can fix hardware bugs, improve performance, and enhance security features of the processor."
    "Proxmox VE Netdata|Monitoring|$BASE_URL/netdata.sh|Description:\n\nNetdata is an open-source, real-time performance monitoring tool designed to provide insights into the performance and health of systems and applications.\n\nIt is often used by system administrators, DevOps professionals, and developers to monitor and troubleshoot issues on servers and other devices."
    "Install Olivetin|Applications|$BASE_URL/olivetin.sh|Description:\n\nOliveTin provides a secure and straightforward way to execute pre-determined shell commands through a web-based interface.\n\nConfiguration Path: /etc/OliveTin/config.yaml"
    "Proxmox VE Post Install|System|$BASE_URL/post-pve-install.sh|Description:\n\nThis script provides options for managing Proxmox VE repositories, including disabling the Enterprise Repo, adding or correcting PVE sources, enabling the No-Subscription Repo, adding the test Repo, disabling the subscription nag, updating Proxmox VE, and rebooting the system.\n\nExecute within the Proxmox shell.\n\n\It is recommended to answer yes (y) to all options presented during the process."
    "Proxmox VE CPU Scaling Governor|System|$BASE_URL/scaling-governor.sh|Description:\n\nThe CPU scaling governor determines how the CPU frequency is adjusted based on the workload, with the goal of either conserving power or improving performance.\n\nBy scaling the frequency up or down, the operating system can optimize the CPU usage and conserve energy when possible. Generic Scaling Governors."
    #"Proxmox VE Cron LXC Updater|Maintenance|$BASE_URL/cron-update-lxcs.sh|Description:\n\nThis script will add/remove a crontab schedule that updates all LXCs every Sunday at midnight. To exclude LXCs from updating, edit the crontab using crontab -e and add CTID as shown in the example below:\n\n0 0 * * 0 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash -c \$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/misc/update-lxcs-cron.sh) -s 103 111 >>/var/log/update-lxcs-cron.log 2>/dev/null"
    "Proxmox VE LXC Updater|Maintenance|$BASE_URL/update-lxcs.sh|Description:\n\nThis script has been created to simplify and speed up the process of updating all LXC containers across various Linux distributions, such as Ubuntu, Debian, Devuan, Alpine Linux, CentOS-Rocky-Alma, Fedora, and ArchLinux.\n\nDesigned to automatically skip templates and specific containers during the update, enhancing its convenience and usability."
    "Proxmox Backup Server|Security|$BASE_URL2/ct/proxmox-backup-server.sh|Description:\n\nProxmox Backup Server is an enterprise backup solution, for backing up and restoring VMs, containers, and physical hosts. By supporting incremental, fully deduplicated backups, Proxmox Backup Server significantly reduces network load and saves valuable storage space.\n\n\nSet a root password if using autologin. This will be the PBS password. passwd root"


)

show_menu() {
    declare -A category_order
    category_order["System"]=1
    category_order["Maintenance"]=2
    category_order["Containers"]=3
    category_order["Applications"]=4
    category_order["Monitoring"]=5
    category_order["Networking"]=6
    category_order["Security"]=7

    custom_sort() {
        while IFS='|' read -r name category url description; do
            category=$(echo "$category" | xargs)
            order=${category_order[$category]:-999}
            printf "%d|%s|%s|%s|%s\n" "$order" "$name" "$category" "$url" "$description"
        done | sort -n | cut -d'|' -f2-
    }

    while true; do
        IFS=$'\n' sorted_scripts=($(printf "%s\n" "${scripts[@]}" | custom_sort))
        unset IFS

        HEADER=$(printf " %-57s %-20s" "$(translate "Name")" "$(translate "Category")")

        menu_items=()
        for script in "${sorted_scripts[@]}"; do
            IFS='|' read -r name category url description <<< "$script"
            translated_category=$(translate "$category")
            padded_name=$(printf "%-57s" "$name")
            menu_items+=("$padded_name" "$translated_category")
        done

        menu_items+=("$(translate "Return to Main Menu")" "")
        
        cleanup
        
        script_selection=$(whiptail --title "$(translate "Essential Proxmox VE Helper-Scripts")" \
                                    --menu "\n$HEADER\n\n$(translate "Select a script to execute")" 25 78 16 \
                                    "${menu_items[@]}" 3>&1 1>&2 2>&3)

        if [ -n "$script_selection" ]; then
            script_selection=$(echo "$script_selection" | xargs)
            if [ "$script_selection" = "$(translate "Return to Main Menu")" ]; then


                whiptail --title "Proxmox VE Helper-Scripts" \
                         --msgbox "$(translate "Visit the website to discover more scripts, stay updated with the latest updates, and support the project:\n\nhttps://community-scripts.github.io/ProxmoxVE")" 15 70


                exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh")
            fi

            for script in "${sorted_scripts[@]}"; do
                IFS='|' read -r name category url description <<< "$script"
                if [ "$name" = "$script_selection" ]; then
                    selected_url="$url"
                    selected_description=$(translate "$description")
                    break
                fi
            done

            if [ -n "$selected_url" ]; then
                if whiptail --title "$(translate "Script Information")" \
                            --yes-button "$(translate "Accept")" \
                            --no-button "$(translate "Cancel")" \
                            --yesno "$selected_description" 20 78; then
                    msg_info2 "$(translate "Executing script:") $script_selection"
                    sleep 2
                    download_script "$selected_url"
                    msg_ok "$(translate "Script completed.")"
                    msg_success "$(translate "Press Enter to return to the main menu...")"
                    read -r
                else
                    msg_info2 "$(translate "Script execution cancelled.")"
                    sleep 2
                fi
            else
                echo "$(translate "Error: Could not find the selected script URL.")"
                read -rp "$(translate "Press Enter to continue...")"
            fi
        else
            exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh")
        fi
    done
}


if [[ "$LANGUAGE" != "en" ]]; then
    msg_lang "$(translate "Generating automatic translations...")"
fi
show_menu
