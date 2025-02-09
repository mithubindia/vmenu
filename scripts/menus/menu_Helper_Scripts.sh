#!/bin/bash

# ==========================================================
# ProxMenu - A menu-driven script for Proxmox VE management
# ==========================================================
# Author      : MacRimi
# Copyright   : (c) 2024 MacRimi
# License     : MIT (https://raw.githubusercontent.com/MacRimi/ProxMenux/main/LICENSE)
# Version     : 1.0
# Last Updated: 09/02/2025
# ==========================================================
# Description:
# This script provides a simple and efficient way to access and execute essential Proxmox VE scripts
# from the Community Scripts project (https://community-scripts.github.io/ProxmoxVE/).
#
# It serves as a convenient tool to run key automation scripts that simplify system management,
# continuing the great work and legacy of tteck in making Proxmox VE more accessible.
#
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



# Define an array with script names, URLs, categories, and descriptions
scripts=(
    "$(translate "Proxmox VE LXC IP-Tag")|$(translate "Containers")|$BASE_URL/add-lxc-iptag.sh|$(translate "Description:\n\nThis script automatically adds IP address as tags to LXC containers using a Systemd service. The service also updates the tags if a LXC IP address is changed.\n\nConfiguration: nano /opt/lxc-iptag/iptag.conf. iptag.service must be restarted after change.\n\n\nThe Proxmox Node must contain ipcalc and net-tools. apt-get install -y ipcalc net-tools")"
    "$(translate "Add Netbird to LXC")|$(translate "Networking")|$BASE_URL/add-netbird-lxc.sh|$(translate "Description:\n\nNetBird combines a configuration-free peer-to-peer private network and a centralized access control system in a single platform, making it easy to create secure private networks for your organization or home.\n\nAfter the script finishes, reboot the LXC then run netbird up in the LXC console\n\n\n\nThe script only works in Debian/Ubuntu, not in Alpine!")"
    "$(translate "Add Tailscale to LXC")|$(translate "Networking")|$BASE_URL/add-tailscale-lxc.sh|$(translate "Description:\n\nTailscale is a software-defined networking solution that enables secure communication between devices over the internet. It creates a virtual private network (VPN) that enables devices to communicate with each other as if they were on the same local network.\n\nTailscale works even when the devices are separated by firewalls or subnets, and provides secure and encrypted communication between devices. With Tailscale, users can connect devices, servers, computers, and cloud instances to create a secure network, making it easier to manage and control access to resources. Tailscale is designed to be easy to set up and use, providing a streamlined solution for secure communication between devices over the internet.\n\n\n\nAfter the script finishes, reboot the LXC then run tailscale up in the LXC console.")"
    "$(translate "Proxmox VE LXC Cleaner")|$(translate "Maintenance")|$BASE_URL/clean-lxcs.sh|$(translate "Description:\n\nThis script provides options to delete logs and cache, and repopulate apt lists for Ubuntu and Debian systems.")"
    "$(translate "Proxmox VE Host Backup")|$(translate "System")|$BASE_URL/host-backup.sh|$(translate "Description:\n\nThis script serves as a versatile backup utility, enabling users to specify both the backup path and the directory they want to work in. This flexibility empowers users to select the specific files and directories they wish to back up, making it compatible with a wide range of hosts, not limited to Proxmox.\n\n\n\nA backup is rendered ineffective when it remains stored on the host")"
    "$(translate "Add hardware Acceleration LXC")|$(translate "Containers")|$BASE_URL/hw-acceleration.sh|$(translate "Enables hardware acceleration IGPU for LXC containers.")"
    "$(translate "Proxmox Clean Orphaned LVM")|$(translate "Maintenance")|$BASE_URL/clean-orphaned-lvm.sh|$(translate "Description:\n\nThis script helps Proxmox users identify and remove orphaned LVM volumes that are no longer associated with any VM or LXC container. It scans all LVM volumes, detects unused ones, and provides an interactive prompt to delete them safely.\n\n\n\nSystem-critical volumes like root, swap, and data are excluded to prevent accidental deletion.")"
    "$(translate "Install Crowdsec")|$(translate "Security")|$BASE_URL/crowdsec.sh|$(translate "Description:\n\nCrowdSec is a free and open-source intrusion prevention system (IPS) designed to provide network security against malicious traffic. It is a collaborative IPS that analyzes behaviors and responses to attacks by sharing signals across a community of users.\n\nCrowdSec leverages the collective intelligence of its users to detect and respond to security threats in real-time. With CrowdSec, network administrators can set up protection against a wide range of threats, including malicious traffic, bots, and denial-of-service (DoS) attacks.\n\n\n\nThe software is designed to be easy to use and integrate with existing security systems, making it a valuable tool for enhancing the security of any network.")"
    "$(translate "Proxmox VE LXC Filesystem Trim")|$(translate "Maintenance")|$BASE_URL/fstrim.sh|$(translate "Description:\n\nThis maintains SSD performance by managing unused blocks. Thin-provisioned storage systems also require management to prevent unnecessary storage use. VMs automate fstrim, while LXC containers need manual or automated fstrim processes for optimal performance.\n\n\n\nThis is designed to work with SSDs on ext4 filesystems only.")"
    "$(translate "Install Glances")|$(translate "Monitoring")|$BASE_URL/glances.sh|$(translate "Description:\n\nGlances is an open-source system cross-platform monitoring tool.\n\n\n\nIt allows real-time monitoring of various aspects of your system such as CPU, memory, disk, network usage etc.")"
    "$(translate "Proxmox VE Kernel Clean")|$(translate "Maintenance")|$BASE_URL/kernel-clean.sh|$(translate "Description:\n\nCleaning unused kernel images is beneficial for reducing the length of the GRUB menu and freeing up disk space.\n\n\n\nBy removing old, unused kernels, the system is able to conserve disk space and streamline the boot process.")"
    "$(translate "Proxmox VE Kernel Pin")|$(translate "System")|$BASE_URL/kernel-pin.sh|$(translate "Description:\n\nKernel Pin is an essential tool for effortlessly managing kernel pinning and unpinning.")"
    "$(translate "Container LXC Deletion")|$(translate "Containers")|$BASE_URL/lxc-delete.sh|$(translate "Description:\n\nThis script helps manage and delete LXC containers on a Proxmox VE server. It lists all available containers, allowing the user to select one or more for deletion through an interactive menu.\n\nRunning containers are automatically stopped before deletion, and the user is asked to confirm each action.\n\n\n\nThe script ensures a controlled and efficient container management process.")"
    "$(translate "Proxmox VE Processor Microcode")|$(translate "System")|$BASE_URL/microcode.sh|$(translate "Description:\n\nProcessor Microcode is a layer of low-level software that runs on the processor and provides patches or updates to its firmware. Microcode updates can fix hardware bugs, improve performance, and enhance security features of the processor.\n\nIt's important to note that the availability of firmware update mechanisms, such as Intel's Management Engine (ME) or AMD's Platform Security Processor (PSP), may vary depending on the processor and its specific implementation. Therefore, it's recommended to consult the documentation for your processor to confirm whether firmware updates can be applied through the operating system.\n\n\n\nAfter a reboot, you can check whether any microcode updates are currently in effect by running the following command:\n\njournalctl -k | grep -E "microcode" | head -n 1")"
    "$(translate "Proxmox VE Netdata")|$(translate "Monitoring")|$BASE_URL/netdata.sh|$(translate "Description:\n\nNetdata is an open-source, real-time performance monitoring tool designed to provide insights into the performance and health of systems and applications.\n\nIt is often used by system administrators, DevOps professionals, and developers to monitor and troubleshoot issues on servers and other devices.")"
    "$(translate "Install Olivetin")|$(translate "Applications")|$BASE_URL/olivetin.sh|$(translate "Description:\n\nOliveTin provides a secure and straightforward way to execute pre-determined shell commands through a web-based interface.\n\n\n\nConfiguration Path: /etc/OliveTin/config.yaml")"
    "$(translate "Proxmox VE Post Install")|$(translate "System")|$BASE_URL/post-pve-install.sh|$(translate "Description:\n\nThis script provides options for managing Proxmox VE repositories, including disabling the Enterprise Repo, adding or correcting PVE sources, enabling the No-Subscription Repo, adding the test Repo, disabling the subscription nag, updating Proxmox VE, and rebooting the system.\n\nExecute within the Proxmox shell.\n\n\n\nIt is recommended to answer “yes” (y) to all options presented during the process.")"
    "$(translate "Proxmox VE CPU Scaling Governor")|$(translate "System")|$BASE_URL/scaling-governor.sh|$(translate "Description:\n\nThe CPU scaling governor determines how the CPU frequency is adjusted based on the workload, with the goal of either conserving power or improving performance.\n\nBy scaling the frequency up or down, the operating system can optimize the CPU usage and conserve energy when possible. Generic Scaling Governors.")"
    "$(translate "Proxmox VE Cron LXC Updater")|$(translate "Maintenance")|$BASE_URL/cron-update-lxcs.sh|$(translate "Description:\n\nThis script will add/remove a crontab schedule that updates all LXCs every Sunday at midnight.\n\nTo exclude LXCs from updating, edit the crontab using crontab -e and add CTID as shown in the example below:\n\n0 0 * * 0 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash -c \$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/misc/update-lxcs-cron.sh) -s 103 111 >>/var/log/update-lxcs-cron.log 2>/dev/null")"
    "$(translate "Proxmox VE LXC Updater")|$(translate "Maintenance")|$BASE_URL/update-lxcs.sh|$(translate "Description:\n\nThis script has been created to simplify and speed up the process of updating all LXC containers across various Linux distributions, such as Ubuntu, Debian, Devuan, Alpine Linux, CentOS-Rocky-Alma, Fedora, and ArchLinux.\n\nIt's designed to automatically skip templates and specific containers during the update, enhancing its convenience and usability.")"
)

# Function to display the menu and execute the selected script
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
            printf "%d|%s|%s|%s|%s\n" "${category_order[$category]:-999}" "$name" "$category" "$url" "$description"
        done | sort -n | cut -d'|' -f2-
    }
    while true; do

        IFS=$'\n' sorted_scripts=($(printf "%s\n" "${scripts[@]}" | custom_sort))
        unset IFS

        HEADER=$(printf " %-57s %-20s" "$(translate "Name")" "$(translate "Category")")

        menu_items=()
        for script in "${sorted_scripts[@]}"; do
            IFS='|' read -r name category _ _ <<< "$script"
   
            padded_name="${name}                          "  
            menu_items+=("$padded_name" "$category")
        done


        menu_items+=("$(translate "Return to Main Menu")" "")

        script_selection=$(whiptail --title "$(translate "Essential Proxmox VE Helper-Scripts")" \
                                    --menu "\n$HEADER\n\n$(translate "Select a script to execute")" 25 78 16 \
                                    "${menu_items[@]}" 3>&1 1>&2 2>&3)


if [ -n "$script_selection" ]; then
    if [ "$script_selection" = "$(translate "Return to Main Menu")" ]; then
        whiptail --title "$(translate "Proxmox VE Helper-Scripts")" \
                 --msgbox "$(translate "Don't forget to visit:\n\nhttps://community-scripts.github.io/ProxmoxVE/\n\nfor more scripts and the latest updates.")" 15 70
        exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh")
    fi



            for script in "${sorted_scripts[@]}"; do
                IFS='|' read -r name category url description <<< "$script"
                if [ "$name" = "$script_selection" ]; then
                    selected_url="$url"
                    selected_description="$description"
                    break
                fi
            done

            if [ -n "$selected_url" ]; then

                if whiptail --title "$(translate "Script Information")" \
                            --yes-button "$(translate "Accept")" \
                            --no-button "$(translate "Cancel")" \
                            --yesno "$selected_description" 20 78; then

                    msg_info2 "$(translate "Executing script:") $script_selection..."
                    sleep 2
                    bash <(curl -s "$selected_url")

                    msg_ok "$(translate "Script completed.")"
                    msg_success "$(translate "Press Enter to return to the main menu...")"
                    read -p ""
                else
                    msg_info2 "$(translate "Script execution cancelled.")"
                    sleep 2
                fi
            else
                echo "$(translate "Error: Could not find the selected script URL.")"
                read -p "$(translate "Press Enter to continue...")"
            fi
        else
            break
        fi
    done
}

show_menu
