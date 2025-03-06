#!/bin/bash

# ==========================================================
# ProxMenux - Customizable script settings for Proxmox post-installation
# ==========================================================
# Author      : MacRimi
# Copyright   : (c) 2024 MacRimi
# License     : MIT (https://raw.githubusercontent.com/MacRimi/ProxMenux/main/LICENSE)
# Version     : 1.0
# Last Updated: 24/02/2025
# ==========================================================
# Description:
# This script automates post-installation configurations and optimizations
# for Proxmox Virtual Environment (VE). It allows for a variety of system
# customizations, including kernel optimizations, memory management, network 
# tweaks, and virtualization environment adjustments. The script facilitates
# easy installation of useful tools and security enhancements, including 
# fail2ban, ZFS auto-snapshot, and more.
#
# This script is based on the work of Adrian Jon Kriel from eXtremeSHOK.com,
# and it was originally published as a post-installation script for Proxmox under the 
# BSD License.
#
# Copyright (c) Adrian Jon Kriel :: admin@extremeshok.com
# Script updates can be found at: https://github.com/extremeshok/xshok-proxmox
#
# License: BSD (Berkeley Software Distribution)
#
# Key features:
# - Configures system memory and kernel settings for better performance.
# - Enables IOMMU and VFIO for PCI passthrough and virtualization optimizations.
# - Installs essential tools such as kernel headers, system utilities, and networking tools.
# - Optimizes journald, achievement, and other system services for better efficiency.
# - Enables guest agents for virtualization platforms such as KVM, VMware, and VirtualBox.
# - Updates the system, adds correct repositories, and optimizes system features such as memory, network settings, and more.
# - Provides a wide range of additional options for customization and optimization.
# - Offers interactive selection of features using an easy-to-use menu-driven interface.
# - And many more...
#
# ==========================================================


# Configuration
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

# VARIBLES
OS_CODENAME="$(grep "VERSION_CODENAME=" /etc/os-release | cut -d"=" -f 2 | xargs )"
RAM_SIZE_GB=$(( $(vmstat -s | grep -i "total memory" | xargs | cut -d" " -f 1) / 1024 / 1000))
NECESSARY_REBOOT=0
SCRIPT_TITLE="Customizable post-installation optimization script"

# ==========================================================




enable_kexec() {
    msg_info2 "$(translate "Configuring kexec for quick reboots...")"
    NECESSARY_REBOOT=1 
    # Set default answers for debconf
    echo "kexec-tools kexec-tools/load_kexec boolean false" | debconf-set-selections > /dev/null 2>&1

    msg_info "$(translate "Installing kexec-tools...")"
    # Install kexec-tools without showing output
    if ! dpkg -s kexec-tools >/dev/null 2>&1; then
        /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' install kexec-tools > /dev/null 2>&1
        msg_ok "$(translate "kexec-tools installed successfully")"
    else
        msg_ok "$(translate "kexec-tools installed successfully")"
    fi

    # Create systemd service file
    local service_file="/etc/systemd/system/kexec-pve.service"
    if [ ! -f "$service_file" ]; then
        cat <<'EOF' > "$service_file"
[Unit]
Description=Loading new kernel into memory
Documentation=man:kexec(8)
DefaultDependencies=no
Before=reboot.target
RequiresMountsFor=/boot
#Before=shutdown.target umount.target final.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/sbin/kexec -d -l /boot/pve/vmlinuz --initrd=/boot/pve/initrd.img --reuse-cmdline

[Install]
WantedBy=default.target
EOF
        msg_ok "$(translate "kexec-pve service file created")"
    else
        msg_ok "$(translate "kexec-pve service file created")"
    fi

    # Enable the service
    if ! systemctl is-enabled kexec-pve.service > /dev/null 2>&1; then
        systemctl enable kexec-pve.service > /dev/null 2>&1
        msg_ok "$(translate "kexec-pve service enabled")"
    else
        msg_ok "$(translate "kexec-pve service enabled")"
    fi
    
    if [ ! -f /root/.bash_profile ]; then
    touch /root/.bash_profile
    fi
    
    if ! grep -q "alias reboot-quick='systemctl kexec'" /root/.bash_profile; then
        echo "alias reboot-quick='systemctl kexec'" >> /root/.bash_profile
        msg_ok "$(translate "reboot-quick alias added")"
    else
        msg_ok "$(translate "reboot-quick alias added")"
    fi

    msg_success "$(translate "kexec configured successfully. Use the command: reboot-quick")"
}



# ==========================================================




apt_upgrade() {

    msg_info2 "$(translate "Configuring Proxmox repositories")"
    NECESSARY_REBOOT=1 
    # Disable enterprise proxmox repo
    if [ -f /etc/apt/sources.list.d/pve-enterprise.list ] && grep -q "^deb" /etc/apt/sources.list.d/pve-enterprise.list; then
        msg_info "$(translate "Disabling enterprise Proxmox repository...")"
        sed -i "s/^deb/#deb/g" /etc/apt/sources.list.d/pve-enterprise.list
        msg_ok "$(translate "Enterprise Proxmox repository disabled")"
    fi

    # Disable enterprise proxmox ceph repo
    if [ -f /etc/apt/sources.list.d/ceph.list ] && grep -q "^deb" /etc/apt/sources.list.d/ceph.list; then
        msg_info "$(translate "Disabling enterprise Proxmox Ceph repository...")"
        sed -i "s/^deb/#deb/g" /etc/apt/sources.list.d/ceph.list
        msg_ok "$(translate "Enterprise Proxmox Ceph repository disabled")"
    fi

    # Enable free public proxmox repo
    if [ ! -f /etc/apt/sources.list.d/pve-public-repo.list ] || ! grep -q "pve-no-subscription" /etc/apt/sources.list.d/pve-public-repo.list; then
        msg_info "$(translate "Enabling free public Proxmox repository...")"
        echo -e "deb http://download.proxmox.com/debian/pve ${OS_CODENAME} pve-no-subscription\\n" > /etc/apt/sources.list.d/pve-public-repo.list
        msg_ok "$(translate "Free public Proxmox repository enabled")"
    fi

#    # Enable Proxmox testing repository
#    if [ ! -f /etc/apt/sources.list.d/pve-testing-repo.list ] || ! grep -q "pvetest" /etc/apt/sources.list.d/pve-testing-repo.list; then
#        msg_info "$(translate "Enabling Proxmox testing repository...")"
#        echo -e "deb http://download.proxmox.com/debian/pve ${OS_CODENAME} pvetest\\n" > /etc/apt/sources.list.d/pve-testing-repo.list
#        msg_ok "$(translate "Proxmox testing repository enabled")"
#    fi

    # Configure main Debian repositories
    if ! grep -q "${OS_CODENAME}-security" /etc/apt/sources.list; then
        msg_info "$(translate "Configuring main Debian repositories...")"
        cat <<EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian ${OS_CODENAME} main contrib non-free non-free-firmware
deb http://deb.debian.org/debian ${OS_CODENAME}-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security ${OS_CODENAME}-security main contrib non-free non-free-firmware
EOF
        msg_ok "$(translate "Main Debian repositories configured")"
    fi

    # Disable non-free firmware warnings
    if [ ! -f /etc/apt/apt.conf.d/no-bookworm-firmware.conf ]; then
        msg_info "$(translate "Disabling non-free firmware warnings...")"
        echo 'APT::Get::Update::SourceListWarnings::NonFreeFirmware "false";' > /etc/apt/apt.conf.d/no-bookworm-firmware.conf
        msg_ok "$(translate "Non-free firmware warnings disabled")"
    fi

    # Update package lists
    msg_info "$(translate "Updating package lists...")"
    if apt-get update > /dev/null 2>&1; then
        msg_ok "$(translate "Package lists updated")"
    else
        msg_error "$(translate "Failed to update package lists")"
        return 1
    fi

    # Remove conflicting utilities
    msg_info "$(translate "Removing conflicting utilities...")"
    if /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' purge ntp openntpd systemd-timesyncd > /dev/null 2>&1; then
        msg_ok "$(translate "Conflicting utilities removed")"
    else
        msg_error "$(translate "Failed to remove conflicting utilities")"
    fi

    
    # update proxmox and install system utils
    msg_info "$(translate "Performing packages upgrade...")"
    apt-get install pv -y > /dev/null 2>&1
    total_packages=$(apt-get -s dist-upgrade | grep "^Inst" | wc -l)
    
    if [ "$total_packages" -eq 0 ]; then
        total_packages=1  
    fi
    msg_ok "$(translate "Packages upgrade successfull")"
    tput civis  
    tput sc     

    
    (
        /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' dist-upgrade 2>&1 | \
        while IFS= read -r line; do
            if [[ "$line" =~ ^(Setting up|Unpacking|Preparing to unpack|Processing triggers for) ]]; then
              
                package_name=$(echo "$line" | sed -E 's/.*(Setting up|Unpacking|Preparing to unpack|Processing triggers for) ([^ ]+).*/\2/')

                
                [ -z "$package_name" ] && package_name="$(translate "Unknown")"

               
                tput rc
                tput ed

               
                row=$(( $(tput lines) - 6 ))
                tput cup $row 0; echo "$(translate "Installing packages...")"
                tput cup $((row + 1)) 0; echo "──────────────────────────────────────────────"
                tput cup $((row + 2)) 0; echo "Package: $package_name"
                tput cup $((row + 3)) 0; echo "Progress: [                                                  ] 0%"
                tput cup $((row + 4)) 0; echo "──────────────────────────────────────────────"

               
                for i in $(seq 1 10); do
                    progress=$((i * 10))
                    tput cup $((row + 3)) 9 
                    printf "[%-50s] %3d%%" "$(printf "#%.0s" $(seq 1 $((progress/2))))" "$progress"
                    sleep 0.2  
                done
            fi
        done
    )

    if [ $? -eq 0 ]; then
        tput rc
        tput ed
        msg_ok "$(translate "System upgrade completed")"
    fi

   
    msg_info "$(translate "Updating PVE application manager, patience...")"
    total_steps=$(pveam update 2>&1 | grep -E "^(Downloading|Importing)" | wc -l)
    [ $total_steps -eq 0 ] && total_steps=1

    tput sc  

    (
        pveam update 2>&1 | while IFS= read -r line; do
            if [[ $line == "Downloading"* ]] || [[ $line == "Importing"* ]]; then
                
                file_name=$(echo "$line" | sed -E 's/.* (Downloading|Importing) ([^ ]+).*/\2/')

                
                [ -z "$file_name" ] && file_name="$(translate "Unknown")"

               
                tput rc
                tput ed

               
                row=$(( $(tput lines) - 6 ))
                tput cup $row 0; echo "$(translate "Updating PVE application manager...")"
                tput cup $((row + 1)) 0; echo "──────────────────────────────────────────────"
                tput cup $((row + 2)) 0; echo "Downloading: $file_name"
                tput cup $((row + 3)) 0; echo "Progress: [                                                  ] 0%"
                tput cup $((row + 4)) 0; echo "──────────────────────────────────────────────"

               
                for i in $(seq 1 10); do
                    progress=$((i * 10))
                    tput cup $((row + 3)) 9 
                    printf "[%-50s] %3d%%" "$(printf "#%.0s" $(seq 1 $((progress/2))))" "$progress"
                    sleep 0.2 
                done
            fi
        done
    )

    if [ $? -eq 0 ]; then
        tput rc
        tput ed
        msg_ok "$(translate "PVE application manager updated")"
    fi

    tput cnorm  


    # Install additional Proxmox packages
    msg_info "$(translate "Installing additional Proxmox packages...")"
    if /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' install zfsutils-linux proxmox-backup-restore-image chrony > /dev/null 2>&1; then
        msg_ok "$(translate "Additional Proxmox packages installed")"
    else
        msg_error "$(translate "Failed to install additional Proxmox packages")"
    fi

    msg_success "$(translate "Proxmox repository configuration completed")"

}




# ==========================================================





optimize_journald() {
    msg_info2 "$(translate "Limiting size and optimizing journald")"
    NECESSARY_REBOOT=1 
    local journald_conf="/etc/systemd/journald.conf"
    local config_changed=false

    msg_info "$(translate "Configuring journald...")"

    # Create a temporary configuration
    cat <<EOF > /tmp/journald.conf.new
[Journal]
# Store on disk
Storage=persistent
# Don't split Journald logs by user
SplitMode=none
# Disable rate limits
RateLimitInterval=0
RateLimitIntervalSec=0
RateLimitBurst=0
# Disable Journald forwarding to syslog
ForwardToSyslog=no
# Journald forwarding to wall /var/log/kern.log
ForwardToWall=yes
# Disable signing of the logs, save cpu resources
Seal=no
Compress=yes
# Fix the log size
SystemMaxUse=64M
RuntimeMaxUse=60M
# Optimize the logging and speed up tasks
MaxLevelStore=warning
MaxLevelSyslog=warning
MaxLevelKMsg=warning
MaxLevelConsole=notice
MaxLevelWall=crit
EOF

    # Compare the current configuration with the new one
    if ! cmp -s "$journald_conf" "/tmp/journald.conf.new"; then
        mv "/tmp/journald.conf.new" "$journald_conf"
        config_changed=true
    else
        rm "/tmp/journald.conf.new"
    fi

    if [ "$config_changed" = true ]; then
        systemctl restart systemd-journald.service > /dev/null 2>&1
        msg_ok "$(translate "Journald configuration updated and service restarted")"
    else
        msg_ok "$(translate "Journald configuration is already optimized")"
    fi

    # Clean and rotate logs
    journalctl --vacuum-size=64M --vacuum-time=1d > /dev/null 2>&1
    journalctl --rotate > /dev/null 2>&1

    msg_success "$(translate "Journald optimization completed")"
}





# ==========================================================





install_kernel_headers() {
    msg_info2 "$(translate "Installing kernel headers")"
    NECESSARY_REBOOT=1 

    # Get the current kernel version
    local kernel_version=$(uname -r)
    local headers_package="linux-headers-${kernel_version}"

    # Check if headers are already installed
    if dpkg -s "$headers_package" >/dev/null 2>&1; then
        msg_ok "$(translate "Kernel headers are already installed")"
    else
        msg_info "$(translate "Installing kernel headers...")"
        if /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' install "$headers_package" > /dev/null 2>&1; then
        msg_ok "$(translate "Kernel headers installed successfully")"
        else
        msg_error "$(translate "Failed to install kernel headers")"
            return 1
        fi
    fi

    msg_success "$(translate "Kernel headers installation process completed")"
}



# ==========================================================



configure_kernel_panic() {
    msg_info2 "$(translate "Configuring kernel panic behavior")"
    NECESSARY_REBOOT=1

    local config_file="/etc/sysctl.d/99-kernelpanic.conf"

    msg_info "$(translate "Updating kernel panic configuration...")"

    # Create or update the configuration file
    cat <<EOF > "$config_file"
# Enable restart on kernel panic, kernel oops and hardlockup
kernel.core_pattern = /var/crash/core.%t.%p
# Reboot on kernel panic after 10s
kernel.panic = 10
# Panic on kernel oops, kernel exploits generally create an oops
kernel.panic_on_oops = 1
# Panic on a hardlockup
kernel.hardlockup_panic = 1
EOF


    msg_ok "$(translate "Kernel panic configuration updated and applied")"
    msg_success "$(translate "Kernel panic behavior configuration completed")"
}




# ==========================================================




increase_system_limits() {
    msg_info2 "$(translate "Increasing various system limits...")"
    NECESSARY_REBOOT=1
    
    # Function to safely append or replace configuration
    append_or_replace() {
        local file="$1"
        local content="$2"
        local temp_file=$(mktemp)

        if [ -f "$file" ]; then
            grep -vF "# ProxMenux configuration" "$file" > "$temp_file"
        fi
        echo -e "# ProxMenux configuration\n$content" >> "$temp_file"
        mv "$temp_file" "$file"
    }

    # Increase max user watches
    msg_info "$(translate "Configuring max user watches...")"
    append_or_replace "/etc/sysctl.d/99-maxwatches.conf" "
fs.inotify.max_user_watches = 1048576
fs.inotify.max_user_instances = 1048576
fs.inotify.max_queued_events = 1048576"
    msg_ok "$(translate "Max user watches configured")"

    # Increase max FD limit / ulimit
    msg_info "$(translate "Configuring max FD limit / ulimit...")"
    append_or_replace "/etc/security/limits.d/99-limits.conf" "
* soft     nproc          1048576
* hard     nproc          1048576
* soft     nofile         1048576
* hard     nofile         1048576
root soft     nproc          unlimited
root hard     nproc          unlimited
root soft     nofile         unlimited
root hard     nofile         unlimited"
    msg_ok "$(translate "Max FD limit / ulimit configured")"

    # Increase kernel max Key limit
    msg_info "$(translate "Configuring kernel max Key limit...")"
    append_or_replace "/etc/sysctl.d/99-maxkeys.conf" "
kernel.keys.root_maxkeys=1000000
kernel.keys.maxkeys=1000000"
    msg_ok "$(translate "Kernel max Key limit configured")"

    # Set systemd ulimits
    msg_info "$(translate "Setting systemd ulimits...")"
    for file in /etc/systemd/system.conf /etc/systemd/user.conf; do
        if ! grep -q "^DefaultLimitNOFILE=" "$file"; then
            echo "DefaultLimitNOFILE=256000" >> "$file"
        fi
    done
    msg_ok "$(translate "Systemd ulimits set")"

    # Configure PAM limits
    msg_info "$(translate "Configuring PAM limits...")"
    for file in /etc/pam.d/common-session /etc/pam.d/runuser-l; do
        if ! grep -q "^session required pam_limits.so" "$file"; then
            echo 'session required pam_limits.so' >> "$file"
        fi
    done
    msg_ok "$(translate "PAM limits configured")"

    # Set ulimit for the shell user
    msg_info "$(translate "Setting ulimit for the shell user...")"
    if ! grep -q "ulimit -n 256000" /root/.profile; then
        echo "ulimit -n 256000" >> /root/.profile
    fi
    msg_ok "$(translate "Shell user ulimit set")"

    # Configure swappiness
    msg_info "$(translate "Configuring kernel swappiness...")"
    append_or_replace "/etc/sysctl.d/99-swap.conf" "
vm.swappiness = 10
vm.vfs_cache_pressure = 100"
    msg_ok "$(translate "Swappiness configuration created successfully")"

    # Increase Max FS open files
    msg_info "$(translate "Increasing maximum file system open files...")"
    append_or_replace "/etc/sysctl.d/99-fs.conf" "
fs.nr_open = 12000000
fs.file-max = 9223372036854775807
fs.aio-max-nr = 1048576"

    msg_ok "$(translate "Max FS open files configuration created successfully")"
    msg_success "$(translate "System limits increase completed.")"
}



# ==========================================================




skip_apt_languages() {
    msg_info2 "$(translate "Configuring APT to skip downloading additional languages")"

    local config_file="/etc/apt/apt.conf.d/99-disable-translations"
    local config_content="Acquire::Languages \"none\";"

    msg_info "$(translate "Setting APT language configuration...")"

    if [ -f "$config_file" ] && grep -q "$config_content" "$config_file"; then
        msg_ok "$(translate "APT language configuration updated")"
    else
        echo -e "$config_content\n" > "$config_file"
        msg_ok "$(translate "APT language configuration updated")"
    fi

    msg_success "$(translate "APT configured to skip downloading additional languages")"
}




# ==========================================================




configure_time_sync() {
    msg_info2 "$(translate "Configuring system time settings...")"

    # Set timezone
    #    msg_info "$(translate "Attempting to set timezone automatically based on IP address...")"

    # Get public IP address
    this_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
    if [ -z "$this_ip" ]; then
        msg_warn "$(translate "Failed to obtain public IP address")"
        timezone="UTC"
    else
        # Get timezone based on IP
        timezone=$(curl -s "https://ipapi.co/${this_ip}/timezone")
        if [ -z "$timezone" ]; then
            msg_warn "$(translate "Failed to determine timezone from IP address")"
            timezone="UTC"
        else
            msg_ok "$(translate "Found timezone $timezone for IP $this_ip")"
        fi
    fi

    # Set the timezone
    if timedatectl set-timezone "$timezone"; then
        msg_ok "$(translate "Timezone set to $timezone")"
    else
        msg_error "$(translate "Failed to set timezone to $timezone")"
    fi

    # Configure time synchronization
    msg_info "$(translate "Enabling automatic time synchronization...")"
    if timedatectl set-ntp true; then
        msg_ok "$(translate "Automatic time synchronization enabled")"
    else
        msg_error "$(translate "Failed to enable automatic time synchronization")"
    fi

    msg_success "$(translate "Time settings configuration completed")"
}




# ==========================================================





install_system_utils() {
    msg_info2 "$(translate "Installing common system utilities...")"


    packages=(
        axel dialog dos2unix grc htop btop iftop iotop
        iperf3 ipset iptraf-ng mlocate msr-tools net-tools
        sshpass tmux unzip zip libguestfs-tools
    )

    packages_to_install=()


    for package in "${packages[@]}"; do
        if ! dpkg -s "$package" >/dev/null 2>&1; then
            packages_to_install+=("$package")
        fi
    done

    if [ ${#packages_to_install[@]} -eq 0 ]; then
        msg_ok "$(translate "System utilities installed successfully")"
    else
        tput civis  
        tput sc      

        for package in "${packages_to_install[@]}"; do
           
            tput rc
            tput ed

          
            row=$(( $(tput lines) - 6 ))
            tput cup $row 0; echo "$(translate "Installing system utilities...")"
            tput cup $((row + 1)) 0; echo "──────────────────────────────────────────────"
            tput cup $((row + 2)) 0; echo "Package: $package"
            tput cup $((row + 3)) 0; echo "Progress: [                                                  ] 0%"
            tput cup $((row + 4)) 0; echo "──────────────────────────────────────────────"

           
            for i in $(seq 1 10); do
                progress=$((i * 10))
                tput cup $((row + 3)) 9  
                printf "[%-50s] %3d%%" "$(printf "#%.0s" $(seq 1 $((progress/2))))" "$progress"
                sleep 0.2  
            done

          
            /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' install "$package" > /dev/null 2>&1
        done

       
        tput rc
        tput ed
        tput cnorm  
        msg_ok "$(translate "System utilities installed successfully")"
    fi

    msg_success "$(translate "Common system utilities installation completed")"
}





# ==========================================================




configure_entropy() {
    msg_info2 "$(translate "Configuring entropy generation to prevent slowdowns...")"

    # Install haveged
    msg_info "$(translate "Installing haveged...")"
    /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' install haveged > /dev/null 2>&1
    msg_ok "$(translate "haveged installed successfully")"

    # Configure haveged
    msg_info "$(translate "Configuring haveged...")"
    cat <<EOF > /etc/default/haveged
#   -w sets low entropy watermark (in bits)
DAEMON_ARGS="-w 1024"
EOF

    # Reload systemd daemon
    systemctl daemon-reload > /dev/null 2>&1

    # Enable haveged service
    systemctl enable haveged > /dev/null 2>&1
    msg_ok "$(translate "haveged service enabled successfully")"

    msg_success "$(translate "Entropy generation configuration completed")"
}





# ==========================================================




apply_amd_fixes() {
    msg_info2 "$(translate "Detecting AMD CPU and applying fixes if necessary...")"
    NECESSARY_REBOOT=1

    local cpu_model=$(grep -i -m 1 "model name" /proc/cpuinfo)
    if echo "$cpu_model" | grep -qi "EPYC"; then
        msg_info "$(translate "AMD EPYC CPU detected")"
    elif echo "$cpu_model" | grep -qi "Ryzen"; then
        msg_info "$(translate "AMD Ryzen CPU detected")"
    else
        msg_ok "$(translate "No AMD CPU detected. Skipping AMD fixes.")"
        return
    fi

    msg_info "$(translate "Applying AMD-specific fixes...")"

    # Apply kernel fix for random crashing and instability
    local grub_file="/etc/default/grub"
    if ! grep -q "idle=nomwait" "$grub_file"; then
        msg_info "$(translate "Setting kernel parameter: idle=nomwait")"
        if sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="idle=nomwait /g' "$grub_file"; then
            msg_ok "$(translate "Kernel parameter set successfully")"
            if update-grub > /dev/null 2>&1; then
                msg_ok "$(translate "GRUB configuration updated")"
            else
                msg_warn "$(translate "Failed to update GRUB configuration")"
            fi
        else
            msg_warn "$(translate "Failed to set kernel parameter")"
        fi
    else
        msg_info "$(translate "Kernel parameter 'idle=nomwait' already set")"
    fi

    # Add MSR ignore to fix Windows guest on EPYC/Ryzen host
    local kvm_conf="/etc/modprobe.d/kvm.conf"
    msg_info "$(translate "Configuring KVM to ignore MSRs...")"
    if ! grep -q "options kvm ignore_msrs=Y" "$kvm_conf"; then
        echo "options kvm ignore_msrs=Y" >> "$kvm_conf"
        msg_ok "$(translate "KVM ignore_msrs option added")"
    else
        msg_info "$(translate "KVM ignore_msrs option already set")"
    fi
    if ! grep -q "options kvm report_ignored_msrs=N" "$kvm_conf"; then
        echo "options kvm report_ignored_msrs=N" >> "$kvm_conf"
        msg_ok "$(translate "KVM report_ignored_msrs option added")"
    else
        msg_info "$(translate "KVM report_ignored_msrs option already set")"
    fi

    # Install the latest Proxmox VE kernel
    msg_info "$(translate "Checking for Proxmox VE kernel updates...")"
    local current_kernel=$(uname -r | cut -d'-' -f1-2)
    local latest_kernel=$(apt-cache search pve-kernel | grep "^pve-kernel-${current_kernel}" | sort -V | tail -n1 | cut -d' ' -f1)
    
    if [ "$latest_kernel" != "pve-kernel-$current_kernel" ]; then
        msg_info "$(translate "Installing the latest Proxmox VE kernel...")"
        if /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' install "$latest_kernel" > /dev/null 2>&1; then
            msg_ok "$(translate "Latest Proxmox VE kernel installed successfully")"
        else
            msg_warn "$(translate "Failed to install the latest Proxmox VE kernel")"
        fi
    else
        msg_ok "$(translate "The latest Proxmox VE kernel is already installed")"
    fi

    msg_success "$(translate "AMD CPU fixes applied successfully")"
}





# ==========================================================




force_apt_ipv4() {
    msg_info2 "$(translate "Configuring APT to use IPv4...")"

    local config_file="/etc/apt/apt.conf.d/99-force-ipv4"
    local config_content="Acquire::ForceIPv4 \"true\";"

    if [ -f "$config_file" ] && grep -q "$config_content" "$config_file"; then
        msg_ok "$(translate "APT configured to use IPv4")"
    else
        msg_info "$(translate "Creating APT configuration to force IPv4...")"
        if echo -e "$config_content\n" > "$config_file"; then
        msg_ok "$(translate "APT configured to use IPv4")"
        fi
    fi

    msg_success "$(translate "APT IPv4 configuration completed")"
}





# ==========================================================





apply_network_optimizations() {
    msg_info2 "$(translate "Optimizing network settings...")"
    NECESSARY_REBOOT=1

    local sysctl_conf="/etc/sysctl.d/99-network.conf"
    local interfaces_file="/etc/network/interfaces"

    msg_info "$(translate "Applying network optimizations...")"

    # Update sysctl configuration
    cat <<EOF > "$sysctl_conf"
net.core.netdev_max_backlog=8192
net.core.optmem_max=8192
net.core.rmem_max=16777216
net.core.somaxconn=8151
net.core.wmem_max=16777216
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.log_martians = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.log_martians = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.ip_local_port_range=1024 65535
net.ipv4.tcp_base_mss = 1024
net.ipv4.tcp_challenge_ack_limit = 999999999
net.ipv4.tcp_fin_timeout=10
net.ipv4.tcp_keepalive_intvl=30
net.ipv4.tcp_keepalive_probes=3
net.ipv4.tcp_keepalive_time=240
net.ipv4.tcp_limit_output_bytes=65536
net.ipv4.tcp_max_syn_backlog=8192
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_rfc1337=1
net.ipv4.tcp_rmem=8192 87380 16777216
net.ipv4.tcp_sack=1
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_syn_retries=3
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_tw_reuse = 0
net.ipv4.tcp_wmem=8192 65536 16777216
net.netfilter.nf_conntrack_generic_timeout = 60
net.netfilter.nf_conntrack_helper=0
net.netfilter.nf_conntrack_max = 524288
net.netfilter.nf_conntrack_tcp_timeout_established = 28800
net.unix.max_dgram_qlen = 4096
EOF

    sysctl --system > /dev/null 2>&1

    # Ensure /etc/network/interfaces includes the interfaces.d directory
    if ! grep -q 'source /etc/network/interfaces.d/*' "$interfaces_file"; then
        echo "source /etc/network/interfaces.d/*" >> "$interfaces_file"
    fi

    msg_ok "$(translate "Network optimizations applied")"
    msg_success "$(translate "Network optimization completed")"
}





# ==========================================================





install_openvswitch() {
    msg_info2 "$(translate "Installing OpenVSwitch for virtual internal network...")"
    


    # Install OpenVSwitch
    msg_info "$(translate "Installing OpenVSwitch packages...")"
    (
        /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' install openvswitch-switch openvswitch-common 2>&1 | \
        while IFS= read -r line; do
            if [[ $line == *"Installing"* ]] || [[ $line == *"Unpacking"* ]]; then
                printf "\r%-$(($(tput cols)-1))s\r" " "  # Clear current line
                printf "\r%s" "$line"
            fi
        done
    )

    if [ $? -eq 0 ]; then
        printf "\r%-$(($(tput cols)-1))s\r" " "  # Clear final line
        msg_ok "$(translate "OpenVSwitch installed successfully")"
    else
        printf "\r%-$(($(tput cols)-1))s\r" " "  # Clear final line
        msg_warn "$(translate "Failed to install OpenVSwitch")"
    fi

    # Verify installation
    if command -v ovs-vsctl >/dev/null 2>&1; then
        msg_success "$(translate "OpenVSwitch is ready to use")"
    else
        msg_warn "$(translate "OpenVSwitch installation could not be verified")"
    fi

}





# ==========================================================




enable_tcp_fast_open() {
    msg_info2 "$(translate "Configuring TCP optimizations...")"

    local bbr_conf="/etc/sysctl.d/99-kernel-bbr.conf"
    local tfo_conf="/etc/sysctl.d/99-tcp-fastopen.conf"
    local reboot_needed=0

    # Enable Google TCP BBR congestion control
    msg_info "$(translate "Enabling Google TCP BBR congestion control...")"
    if [ ! -f "$bbr_conf" ] || ! grep -q "net.ipv4.tcp_congestion_control = bbr" "$bbr_conf"; then
        cat <<EOF > "$bbr_conf"
# TCP BBR congestion control
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF
        msg_ok "$(translate "TCP BBR configuration created successfully")"
        reboot_needed=1
    else
        msg_ok "$(translate "TCP BBR configuration created successfully")"
    fi

    # Enable TCP Fast Open
    msg_info "$(translate "Enabling TCP Fast Open...")"
    if [ ! -f "$tfo_conf" ] || ! grep -q "net.ipv4.tcp_fastopen = 3" "$tfo_conf"; then
        cat <<EOF > "$tfo_conf"
# TCP Fast Open (TFO)
net.ipv4.tcp_fastopen = 3
EOF
        msg_ok "$(translate "TCP Fast Open configuration created successfully")"
    else
        msg_ok "$(translate "TCP Fast Open configuration created successfully")"
    fi

    # Apply changes
    sysctl --system > /dev/null 2>&1

    if [ "$reboot_needed" -eq 1 ]; then
        NECESSARY_REBOOT=1
    fi

    msg_success "$(translate "TCP optimizations configuration completed")"
}




# ==========================================================




install_ceph() {
    msg_info2 "$(translate "Installing Ceph support...")"

    # Check if Ceph is already installed
    if pveceph status &>/dev/null; then
        msg_ok "$(translate "Ceph is already installed")"
        msg_success "$(translate "Ceph installation check completed")"
        return 0
    fi

    # Add Ceph repository using HTTPS
    msg_info "$(translate "Adding Ceph repository...")"
    if echo "deb https://download.proxmox.com/debian/ceph-squid ${OS_CODENAME} no-subscription" > /etc/apt/sources.list.d/ceph-squid.list; then
        msg_ok "$(translate "Ceph repository added successfully")"
    else
        msg_warn "$(translate "Failed to add Ceph repository")"
        # Continue execution despite the error
    fi

    # Update package lists
    msg_info "$(translate "Updating package lists...")"
    if apt-get update > /dev/null 2>&1; then
        msg_ok "$(translate "Package lists updated successfully")"
    else
        msg_warn "$(translate "Failed to update package lists")"
        # Continue execution despite the error
    fi

    # Install Ceph with progress display
    msg_info "$(translate "Installing Ceph packages...")"
    (
        pveceph install 2>&1 | \
        while IFS= read -r line; do
            if [[ $line == *"Installing"* ]] || [[ $line == *"Unpacking"* ]]; then
                printf "\r%-$(($(tput cols)-1))s\r" " "
                printf "\r%s" "$line"
            fi
        done
        # Clear the last line of output
        printf "\r%-$(($(tput cols)-1))s\r" " "
    )

    # Verify Ceph installation
    if pveceph status &>/dev/null; then
        msg_ok "$(translate "Ceph packages installed and verified successfully")"
        msg_success "$(translate "Ceph installation completed")"
    else
        msg_warn "$(translate "Ceph installation could not be verified")"
        msg_success "$(translate "Ceph installation process finished")"
    fi
}




# ==========================================================





optimize_zfs_arc() {
    msg_info2 "$(translate "Optimizing ZFS ARC size according to available memory...")"

    # Check if ZFS is installed
    if ! command -v zfs > /dev/null; then
        msg_warn "$(translate "ZFS not detected. Skipping ZFS ARC optimization.")"
        return 0
    fi

    # Ensure RAM_SIZE_GB is set
    if [ -z "$RAM_SIZE_GB" ]; then
        RAM_SIZE_GB=$(free -g | awk '/^Mem:/{print $2}')
        if [ -z "$RAM_SIZE_GB" ] || [ "$RAM_SIZE_GB" -eq 0 ]; then
            msg_warn "$(translate "Failed to detect RAM size. Using default value of 16GB for ZFS ARC optimization.")"
            RAM_SIZE_GB=16  # Default to 16GB if detection fails
        fi
    fi

    msg_ok "$(translate "Detected RAM size: ${RAM_SIZE_GB} GB")"

    # Calculate ZFS ARC sizes
    if [[ "$RAM_SIZE_GB" -le 16 ]]; then
        MY_ZFS_ARC_MIN=536870911  # 512MB
        MY_ZFS_ARC_MAX=536870912  # 512MB
    elif [[ "$RAM_SIZE_GB" -le 32 ]]; then
        MY_ZFS_ARC_MIN=1073741823  # 1GB
        MY_ZFS_ARC_MAX=1073741824  # 1GB
    else
        # Use 1/16 of RAM for min and 1/8 for max
        MY_ZFS_ARC_MIN=$((RAM_SIZE_GB * 1073741824 / 16))
        MY_ZFS_ARC_MAX=$((RAM_SIZE_GB * 1073741824 / 8))
    fi

    # Enforce the minimum values
    MY_ZFS_ARC_MIN=$((MY_ZFS_ARC_MIN > 536870911 ? MY_ZFS_ARC_MIN : 536870911))
    MY_ZFS_ARC_MAX=$((MY_ZFS_ARC_MAX > 536870912 ? MY_ZFS_ARC_MAX : 536870912))

    # Apply ZFS tuning parameters
    local zfs_conf="/etc/modprobe.d/99-zfsarc.conf"
    local config_changed=false

    if [ -f "$zfs_conf" ]; then
        msg_info "$(translate "Checking existing ZFS ARC configuration...")"
        if ! grep -q "zfs_arc_min=$MY_ZFS_ARC_MIN" "$zfs_conf" || \
           ! grep -q "zfs_arc_max=$MY_ZFS_ARC_MAX" "$zfs_conf"; then
            msg_ok "$(translate "Changes detected. Updating ZFS ARC configuration...")"
            cp "$zfs_conf" "${zfs_conf}.bak"
            config_changed=true
        else
            msg_ok "$(translate "ZFS ARC configuration is up to date")"
        fi
    else
        msg_info "$(translate "Creating new ZFS ARC configuration...")"
        config_changed=true
    fi

    if $config_changed; then
        cat <<EOF > "$zfs_conf"
# ZFS tuning
# Use 1/8 RAM for MAX cache, 1/16 RAM for MIN cache, or 512MB/1GB for systems with <= 32GB RAM
options zfs zfs_arc_min=$MY_ZFS_ARC_MIN
options zfs zfs_arc_max=$MY_ZFS_ARC_MAX

# Enable prefetch method
options zfs l2arc_noprefetch=0

# Set max write speed to L2ARC (500MB)
options zfs l2arc_write_max=524288000
options zfs zfs_txg_timeout=60
EOF

        if [ $? -eq 0 ]; then
            msg_ok "$(translate "ZFS ARC configuration file created/updated successfully")"
            NECESSARY_REBOOT=1
        else
            msg_error "$(translate "Failed to create/update ZFS ARC configuration file")"
        fi
    fi

    msg_success "$(translate "ZFS ARC optimization completed")"
}




# ==========================================================





install_zfs_auto_snapshot() {
    msg_info2 "$(translate "Installing and configuring ZFS auto-snapshot...")"

    # Check if zfs-auto-snapshot is already installed
    if command -v zfs-auto-snapshot >/dev/null 2>&1; then
        msg_ok "$(translate "zfs-auto-snapshot is already installed")"
    else
        # Install zfs-auto-snapshot
        msg_info "$(translate "Installing zfs-auto-snapshot package...")"
        if /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' install zfs-auto-snapshot > /dev/null 2>&1; then
            msg_ok "$(translate "zfs-auto-snapshot installed successfully")"
        else
            msg_error "$(translate "Failed to install zfs-auto-snapshot")"
            return 1
        fi
    fi

    # Configure snapshot schedules
    config_zfs_auto_snapshot

    msg_success "$(translate "ZFS auto-snapshot installation and configuration completed")"
}

config_zfs_auto_snapshot() {
    msg_info "$(translate "Configuring snapshot schedules...")"

    # Update 15-minute snapshots
    update_snapshot_schedule "/etc/cron.d/zfs-auto-snapshot" "frequent" "4" "*/15"

    # Update other snapshot schedules
    update_snapshot_schedule "/etc/cron.hourly/zfs-auto-snapshot" "hourly" "1"
    update_snapshot_schedule "/etc/cron.daily/zfs-auto-snapshot" "daily" "1"
    update_snapshot_schedule "/etc/cron.weekly/zfs-auto-snapshot" "weekly" "1"
    update_snapshot_schedule "/etc/cron.monthly/zfs-auto-snapshot" "monthly" "1"
}

update_snapshot_schedule() {
    local config_file="$1"
    local schedule_type="$2"
    local keep_value="$3"
    local frequency="$4"

    if [ -f "$config_file" ]; then
        if ! grep -q ".*--keep=$keep_value" "$config_file"; then
            if [ -n "$frequency" ]; then
                sed -i "s|^\*/[0-9]*.*--keep=[0-9]*|$frequency * * * * root /usr/sbin/zfs-auto-snapshot --quiet --syslog --label=$schedule_type --keep=$keep_value|" "$config_file"
            else
                sed -i "s|--keep=[0-9]*|--keep=$keep_value|g" "$config_file"
            fi
            msg_ok "$(translate "Updated $schedule_type snapshot schedule")"
        else
            msg_ok "$(translate "$schedule_type snapshot schedule already configured")"
        fi
    fi
}




# ==========================================================





disable_rpc() {
    msg_info2 "$(translate "Disabling portmapper/rpcbind for security...")"

    msg_info "$(translate "Disabling and stopping rpcbind service...")"

    # Disable and stop rpcbind
    systemctl disable rpcbind > /dev/null 2>&1
    systemctl stop rpcbind > /dev/null 2>&1

    msg_ok "$(translate "rpcbind service has been disabled and stopped")"

    msg_success "$(translate "portmapper/rpcbind has been disabled and removed")"
}




# ==========================================================




configure_pigz() {
    msg_info2 "$(translate "Configuring pigz as a faster replacement for gzip...")"

    # Enable pigz in vzdump configuration
    msg_info "$(translate "Enabling pigz in vzdump configuration...")"
    if ! grep -q "^pigz: 1" /etc/vzdump.conf; then
        sed -i "s/#pigz:.*/pigz: 1/" /etc/vzdump.conf
        msg_ok "$(translate "pigz enabled in vzdump configuration")"
    else
        msg_ok "$(translate "pigz enabled in vzdump configuration")"
    fi

    # Install pigz
    if ! dpkg -s pigz >/dev/null 2>&1; then
        msg_info "$(translate "Installing pigz...")"
        if /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' install pigz > /dev/null 2>&1; then
            msg_ok "$(translate "pigz installed successfully")"
        else
            msg_error "$(translate "Failed to install pigz")"
            return 1
        fi
    else
        msg_ok "$(translate "pigz installed successfully")"
    fi

    # Create pigz wrapper script
    msg_info "$(translate "Creating pigz wrapper script...")"
    if [ ! -f /bin/pigzwrapper ] || ! cmp -s /bin/pigzwrapper - <<EOF
#!/bin/sh
PATH=/bin:\$PATH
GZIP="-1"
exec /usr/bin/pigz "\$@"
EOF
    then
        cat <<EOF > /bin/pigzwrapper
#!/bin/sh
PATH=/bin:\$PATH
GZIP="-1"
exec /usr/bin/pigz "\$@"
EOF
        chmod +x /bin/pigzwrapper
        msg_ok "$(translate "pigz wrapper script created")"
    else
        msg_ok "$(translate "pigz wrapper script created")"
    fi

    # Replace gzip with pigz wrapper
    msg_info "$(translate "Replacing gzip with pigz wrapper...")"
    if [ ! -f /bin/gzip.original ]; then
        mv -f /bin/gzip /bin/gzip.original && \
        cp -f /bin/pigzwrapper /bin/gzip && \
        chmod +x /bin/gzip
        msg_ok "$(translate "gzip replaced with pigz wrapper successfully")"
    else
        msg_ok "$(translate "gzip replaced with pigz wrapper successfully")"
    fi

    msg_success "$(translate "pigz configuration completed")"
}





# ==========================================================





install_fail2ban() {
    msg_info2 "$(translate "Installing and configuring Fail2Ban to protect the web interface...")"


#    if dpkg -l | grep -qw fail2ban; then
#        msg_info "$(translate "Removing existing Fail2Ban installation...")"
#        apt-get remove --purge -y fail2ban >/dev/null 2>&1
#        rm -rf /etc/fail2ban /var/lib/fail2ban /var/run/fail2ban
#        msg_ok "$(translate "Fail2Ban removed successfully")"
#    else
#        msg_ok "$(translate "Fail2Ban was not installed")"
#    fi

 
    msg_info "$(translate "Installing Fail2Ban...")"
    apt-get update >/dev/null 2>&1 && apt-get install -y fail2ban >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        msg_ok "$(translate "Fail2Ban installed successfully")"
    else
        msg_error "$(translate "Failed to install Fail2Ban")"
        return 1
    fi

   
    mkdir -p /etc/fail2ban/jail.d /etc/fail2ban/filter.d

   
    msg_info "$(translate "Configuring Proxmox filter...")"
    cat > /etc/fail2ban/filter.d/proxmox.conf << EOF
[Definition]
failregex = pvedaemon\[.*authentication failure; rhost=<HOST> user=.* msg=.*
ignoreregex =
EOF
    msg_ok "$(translate "Proxmox filter configured")"

  
    msg_info "$(translate "Configuring Proxmox jail...")"
    cat > /etc/fail2ban/jail.d/proxmox.conf << EOF
[proxmox]
enabled = true
port = https,http,8006,8007
filter = proxmox
logpath = /var/log/daemon.log
maxretry = 3
bantime = 3600
findtime = 600
EOF
    msg_ok "$(translate "Proxmox jail configured")"

  
    msg_info "$(translate "Configuring general Fail2Ban settings...")"
    cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
ignoreip = 127.0.0.1
bantime = 86400
maxretry = 2
findtime = 1800

[ssh-iptables]
enabled = true
filter = sshd
action = iptables[name=SSH, port=ssh, protocol=tcp]
logpath = /var/log/auth.log
maxretry = 2
findtime = 3600
bantime = 32400
EOF
    msg_ok "$(translate "General Fail2Ban settings configured")"

    
    msg_info "$(translate "Stopping Fail2Ban service...")"
    systemctl stop fail2ban >/dev/null 2>&1
    msg_ok "$(translate "Fail2Ban service stopped")"

   
    msg_info "$(translate "Ensuring authentication logs exist...")"
    touch /var/log/auth.log /var/log/daemon.log
    chown root:adm /var/log/auth.log /var/log/daemon.log
    chmod 640 /var/log/auth.log /var/log/daemon.log
    msg_ok "$(translate "Authentication logs verified")"

    
    if [[ ! -f /var/log/auth.log && -f /var/log/secure ]]; then
        msg_warn "$(translate "Using /var/log/secure instead of /var/log/auth.log")"
        sed -i 's|logpath = /var/log/auth.log|logpath = /var/log/secure|' /etc/fail2ban/jail.local
    fi

   
    msg_info "$(translate "Ensuring Fail2Ban runtime directory exists...")"
    mkdir -p /var/run/fail2ban
    chown root:root /var/run/fail2ban
    chmod 755 /var/run/fail2ban
    msg_ok "$(translate "Fail2Ban runtime directory verified")"

    
    msg_info "$(translate "Removing old Fail2Ban database (if exists)...")"
    rm -f /var/lib/fail2ban/fail2ban.sqlite3
    msg_ok "$(translate "Fail2Ban database reset")"

  
    msg_info "$(translate "Reloading systemd and restarting Fail2Ban...")"
    systemctl daemon-reload
    systemctl enable fail2ban >/dev/null 2>&1
    systemctl restart fail2ban >/dev/null 2>&1
    msg_ok "$(translate "Fail2Ban service restarted")"

    
    sleep 3

   
    msg_info "$(translate "Checking Fail2Ban service status...")"
    if systemctl is-active --quiet fail2ban; then
        msg_ok "$(translate "Fail2Ban is running correctly")"
    else
        msg_error "$(translate "Fail2Ban is NOT running! Checking logs...")"
        journalctl -u fail2ban --no-pager -n 20
       
    fi


    msg_info "$(translate "Checking Fail2Ban socket...")"
    if [ -S /var/run/fail2ban/fail2ban.sock ]; then
        msg_ok "$(translate "Fail2Ban socket exists!")"
    else
        msg_warn "$(translate "Warning: Fail2Ban socket does not exist!")"
    fi


    msg_info "$(translate "Testing fail2ban-client...")"
    if fail2ban-client ping >/dev/null 2>&1; then
        msg_ok "$(translate "fail2ban-client successfully communicated with the server")"
    else
        msg_error "$(translate "fail2ban-client could not communicate with the server")"
       
    fi


    msg_info "$(translate "Displaying Fail2Ban status...")"
    fail2ban-client status >/dev/null 2>&1
    msg_ok "$(translate "Fail2Ban status displayed")"

    msg_success "$(translate "Fail2Ban installation and configuration completed successfully!")"
    
}




# ==========================================================




install_lynis() {
    msg_info2 "$(translate "Installing Lynis security scan tool...")"

    # Install Lynis directly from Debian repositories
    msg_info "$(translate "Installing Lynis packages...")"
    (
        /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' install lynis 2>&1 | \
        while IFS= read -r line; do
            if [[ $line == *"Installing"* ]] || [[ $line == *"Unpacking"* ]]; then
                printf "\r%-$(($(tput cols)-1))s\r" " "  # Clear current line
                printf "\r%s" "$line"
            fi
        done
    )

    if [ $? -eq 0 ]; then
        printf "\r%-$(($(tput cols)-1))s\r" " "  # Clear final line
        msg_ok "$(translate "Lynis installed successfully")"
    else
        printf "\r%-$(($(tput cols)-1))s\r" " "  # Clear final line
        msg_warn "$(translate "Failed to install Lynis")"
    fi

    # Verify installation
    if command -v lynis >/dev/null 2>&1; then
        msg_success "$(translate "Lynis is ready to use")"
    else
        msg_warn "$(translate "Lynis installation could not be verified")"
    fi
}





# ==========================================================





install_guest_agent() {
    msg_info2 "$(translate "Detecting virtualization and installing  guest agent...")"
    NECESSARY_REBOOT=1

    local virt_env=""
    local guest_agent=""

    # Detect virtualization environment
    if [ "$(dmidecode -s system-manufacturer | xargs)" == "QEMU" ] || [ "$(systemd-detect-virt | xargs)" == "kvm" ]; then
        virt_env="QEMU/KVM"
        guest_agent="qemu-guest-agent"
    elif [ "$(systemd-detect-virt | xargs)" == "vmware" ]; then
        virt_env="VMware"
        guest_agent="open-vm-tools"
    elif [ "$(systemd-detect-virt | xargs)" == "oracle" ]; then
        virt_env="VirtualBox"
        guest_agent="virtualbox-guest-utils"
    else
        msg_ok "$(translate "Guest agent detection completed")"
        msg_success "$(translate "Guest agent installation process completed")"
        return
    fi

    # Install guest agent
    if [ -n "$guest_agent" ]; then
        msg_info "$(translate "Installing $guest_agent for $virt_env...")"
        if /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' install $guest_agent > /dev/null 2>&1; then
            msg_ok "$(translate "$guest_agent installed successfully")"
        else
            msg_error "$(translate "Failed to install $guest_agent")"
        fi
    fi

    msg_success "$(translate "Guest agent installation process completed")"
}




# ==========================================================





configure_ksmtuned() {
    msg_info2 "$(translate "Installing and configuring KSM (Kernel Samepage Merging) daemon...")"
    NECESSARY_REBOOT=1

    # Install ksm-control-daemon
    msg_info "$(translate "Installing ksm-control-daemon...")"
    if /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' install ksm-control-daemon > /dev/null 2>&1; then
        msg_ok "$(translate "ksm-control-daemon installed successfully")"
    fi

    # Determine RAM size and set KSM parameters
    if [[ RAM_SIZE_GB -le 16 ]]; then
        KSM_THRES_COEF=50
        KSM_SLEEP_MSEC=80
        msg_info "$(translate "RAM <= 16GB: Setting KSM to start at 50% full")"
    elif [[ RAM_SIZE_GB -le 32 ]]; then
        KSM_THRES_COEF=40
        KSM_SLEEP_MSEC=60
        msg_info "$(translate "RAM <= 32GB: Setting KSM to start at 60% full")"
    elif [[ RAM_SIZE_GB -le 64 ]]; then
        KSM_THRES_COEF=30
        KSM_SLEEP_MSEC=40
        msg_info "$(translate "RAM <= 64GB: Setting KSM to start at 70% full")"
    elif [[ RAM_SIZE_GB -le 128 ]]; then
        KSM_THRES_COEF=20
        KSM_SLEEP_MSEC=20
        msg_info "$(translate "RAM <= 128GB: Setting KSM to start at 80% full")"
    else
        KSM_THRES_COEF=10
        KSM_SLEEP_MSEC=10
        msg_info "$(translate "RAM > 128GB: Setting KSM to start at 90% full")"
    fi
    # Update ksmtuned configuration
    if sed -i -e "s/\# KSM_THRES_COEF=.*/KSM_THRES_COEF=${KSM_THRES_COEF}/g" /etc/ksmtuned.conf && \
       sed -i -e "s/\# KSM_SLEEP_MSEC=.*/KSM_SLEEP_MSEC=${KSM_SLEEP_MSEC}/g" /etc/ksmtuned.conf; then
        msg_ok "$(translate "ksmtuned configuration updated successfully")"
    fi

    # Enable ksmtuned service
    if systemctl enable ksmtuned > /dev/null 2>&1; then
        msg_ok "$(translate "ksmtuned service enabled successfully")"
    fi

    msg_success "$(translate "KSM configuration completed")"
}





# ==========================================================





enable_vfio_iommu() {
    msg_info2 "$(translate "Enabling IOMMU and configuring VFIO for PCI passthrough...")"
    NECESSARY_REBOOT=1

    # Detect if system uses ZFS
    local uses_zfs=false
    local cmdline_file="/etc/kernel/cmdline"
    if [[ -f "$cmdline_file" && $(grep -q "root=ZFS=" "$cmdline_file") ]]; then
        uses_zfs=true
    fi

    # Enable IOMMU
    local cpu_info=$(cat /proc/cpuinfo)
    local grub_file="/etc/default/grub"
    local iommu_param=""
    local additional_params="pcie_acs_override=downstream,multifunction nofb nomodeset video=vesafb:off,efifb:off"

    if [[ "$cpu_info" == *"GenuineIntel"* ]]; then
        msg_info "$(translate "Detected Intel CPU")"
        iommu_param="intel_iommu=on iommu=pt"
    elif [[ "$cpu_info" == *"AuthenticAMD"* ]]; then
        msg_info "$(translate "Detected AMD CPU")"
        iommu_param="amd_iommu=on iommu=pt"
    else
        msg_warning "$(translate "Unknown CPU type. IOMMU might not be properly enabled.")"
        return 1
    fi

    if [[ "$uses_zfs" == true ]]; then
        if grep -q "$iommu_param" "$cmdline_file" && grep -q "$additional_params" "$cmdline_file"; then
            msg_ok "$(translate "IOMMU and additional parameters already configured for ZFS")"
        else
            cp "$cmdline_file" "${cmdline_file}.bak"
            sed -i "/^.*root=ZFS=/ s|$| $iommu_param $additional_params|" "$cmdline_file"
            msg_ok "$(translate "IOMMU and additional parameters added for ZFS")"
        fi
    else
        if grep -q "$iommu_param" "$grub_file"; then
            msg_ok "$(translate "IOMMU enabled in GRUB configuration")"
        else
            cp "$grub_file" "${grub_file}.bak"
            sed -i "/GRUB_CMDLINE_LINUX_DEFAULT=/ s|\"$| $iommu_param\"|" "$grub_file"
            msg_ok "$(translate "IOMMU enabled in GRUB configuration")"
        fi
    fi

    # Configure VFIO modules (avoid duplicates)
    local modules_file="/etc/modules"
    msg_info "$(translate "Checking VFIO modules...")"
    local vfio_modules=("vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd")

    for module in "${vfio_modules[@]}"; do
        grep -q "^$module" "$modules_file" || echo "$module" >> "$modules_file"
    done
    msg_ok "$(translate "VFIO modules configured.)")"

    # Blacklist conflicting drivers (avoid duplicates)
    local blacklist_file="/etc/modprobe.d/blacklist.conf"
    msg_info "$(translate "Checking conflicting drivers blacklist...")"
    touch "$blacklist_file"
    local blacklist_drivers=("nouveau" "lbm-nouveau" "amdgpu" "radeon" "nvidia" "nvidiafb")

    for driver in "${blacklist_drivers[@]}"; do
        grep -q "^blacklist $driver" "$blacklist_file" || echo "blacklist $driver" >> "$blacklist_file"
    done

    if ! grep -q "options nouveau modeset=0" "$blacklist_file"; then
        echo "options nouveau modeset=0" >> "$blacklist_file"
    fi
    msg_ok "$(translate "Conflicting drivers blacklisted successfully.")"


  # Propagate the settings
    msg_info "$(translate "Updating initramfs, GRUB, and EFI boot, patience...")"
    if update-initramfs -u -k all > /dev/null 2>&1 && \
       update-grub > /dev/null 2>&1 && \
       pve-efiboot-tool refresh > /dev/null 2>&1; then
     msg_ok "$(translate "Initramfs, GRUB, and EFI boot updated successfully")"
    else
        msg_error "$(translate "Failed to update one or more components (initramfs, GRUB, or EFI boot)")"
    fi

    msg_success "$(translate "IOMMU and VFIO setup completed")"
}





# ==========================================================





customize_bashrc() {
   msg_info2 "$(translate "Customizing bashrc for root user...")"

    local bashrc="/root/.bashrc"
    local bash_profile="/root/.bash_profile"

    # Backup original .bashrc if it doesn't exist
    if [ ! -f "${bashrc}.bak" ]; then
        cp "$bashrc" "${bashrc}.bak"
    fi

    # Function to add a line if it doesn't exist
    add_line_if_not_exists() {
        local line="$1"
        local file="$2"
        grep -qF -- "$line" "$file" || echo "$line" >> "$file"
    }

    # Add custom configurations to .bashrc
    add_line_if_not_exists 'export HISTTIMEFORMAT="%d/%m/%y %T "' "$bashrc"
    add_line_if_not_exists 'export PS1='"'\u@\h:\W \$ '" "$bashrc"
    add_line_if_not_exists "alias l='ls -CF'" "$bashrc"
    add_line_if_not_exists "alias la='ls -A'" "$bashrc"
    add_line_if_not_exists "alias ll='ls -alF'" "$bashrc"
    add_line_if_not_exists "alias ls='ls --color=auto'" "$bashrc"
    add_line_if_not_exists "alias grep='grep --color=auto'" "$bashrc"
    add_line_if_not_exists "alias fgrep='fgrep --color=auto'" "$bashrc"
    add_line_if_not_exists "alias egrep='egrep --color=auto'" "$bashrc"
    add_line_if_not_exists "source /etc/profile.d/bash_completion.sh" "$bashrc"
    add_line_if_not_exists 'export PS1="\[\e[31m\][\[\e[m\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[38;5;153m\]\h\[\e[m\] \[\e[38;5;214m\]\W\[\e[m\]\[\e[31m\]]\[\e[m\]\\$ "' "$bashrc"

    msg_ok "$(translate "Custom configurations added to .bashrc")"

    # Ensure .bashrc is sourced in .bash_profile
    add_line_if_not_exists "source /root/.bashrc" "$bash_profile"
    msg_ok "$(translate ".bashrc sourced in .bash_profile")"

    msg_success "$(translate "Bashrc customization completed")"
}




# ==========================================================




setup_motd() {
    msg_info2 "$(translate "Configuring MOTD (Message of the Day) banner...")"

    local motd_file="/etc/motd"
    local custom_message="This system is optimised by: ProxMenux"
    local changes_made=false

    msg_info "$(translate "Checking MOTD configuration...")"

    # Check if the custom message already exists
    if grep -q "$custom_message" "$motd_file"; then
        msg_ok "$(translate "Custom message added to MOTD")"
    else
        # Create a backup of the original MOTD file
        if [ ! -f "${motd_file}.bak" ]; then
            cp "$motd_file" "${motd_file}.bak"
            msg_ok "$(translate "Backup of original MOTD created")"
        fi

        # Add the custom message at the beginning of the file
        echo -e "$custom_message\n\n$(cat $motd_file)" > "$motd_file"
        changes_made=true
        msg_ok "$(translate "Custom message added to MOTD")"
    fi

    sed -i '/^$/N;/^\n$/D' "$motd_file"

    if $changes_made; then
        msg_success "$(translate "MOTD configuration updated successfully")"
    else
        msg_success "$(translate "MOTD configuration updated successfully")"
    fi
}





# ==========================================================





optimize_logrotate() {
msg_info2 "$(translate "Optimizing logrotate configuration...")"

    local logrotate_conf="/etc/logrotate.conf"
    local backup_conf="${logrotate_conf}.bak"


    if grep -q "# ProxMenux optimized configuration" "$logrotate_conf"; then
        msg_ok "$(translate "Logrotate configuration already optimized.")"
    else
        cp "$logrotate_conf" "$backup_conf"
        
        msg_info "$(translate "Applying optimized logrotate configuration...")"
        cat <<EOF > "$logrotate_conf"
# ProxMenux optimized configuration
daily
su root adm
rotate 7
create
compress
size=10M
delaycompress
copytruncate

include /etc/logrotate.d
EOF

    systemctl restart logrotate > /dev/null 2>&1
    msg_ok "$(translate "Logrotate service restarted successfully")"
   fi
    msg_success "$(translate "Logrotate optimization completed")"
}





# ==========================================================





remove_subscription_banner() {
    msg_info2 "$(translate "Checking Proxmox subscription banner and nag status...")"

    local proxmox_js="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"
    local cron_file="/etc/cron.daily/xs-pve-nosub"
    local apt_conf_file="/etc/apt/apt.conf.d/xs-pve-no-nag"

    # Check if all modifications are already applied
    if grep -q "checked_command: function() {}" "$proxmox_js" && \
       [ -f "$cron_file" ] && \
       [ -f "$apt_conf_file" ] && \
       grep -q "NoMoreNagging" "$proxmox_js"; then
        msg_ok "$(translate "No changes needed")"
        msg_success "$(translate "Subscription banner and nag removal check completed")"
        return 0
    fi


    # Remove subscription banner
    if [ -f "$proxmox_js" ]; then
        if ! [ -f "$cron_file" ]; then
            cat <<'EOF' > "$cron_file"
#!/bin/sh
# Remove subscription banner
sed -i "s/data.status !== 'Active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
sed -i "s/checked_command: function(orig_cmd) {/checked_command: function() {} || function(orig_cmd) {/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
EOF
            chmod 755 "$cron_file"
            msg_ok "$(translate "Cron job for banner removal created")"
        else
            msg_info "$(translate "Cron job for banner removal already exists")"
        fi
        bash "$cron_file"
        msg_ok "$(translate "Banner removal script executed")"
    else
        msg_error "$(translate "proxmoxlib.js not found. Cannot remove banner.")"
    fi

    # Remove nag using APT hook
    if ! [ -f "$apt_conf_file" ]; then
        echo "DPkg::Post-Invoke { \"dpkg -V proxmox-widget-toolkit | grep -q '/proxmoxlib\.js$'; if [ \$? -eq 1 ]; then { echo 'Removing subscription nag from UI...'; sed -i '/data.status/{s/\!//;s/Active/NoMoreNagging/}' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js; }; fi\"; };" > "$apt_conf_file"
        msg_ok "$(translate "APT configuration for nag removal created")"
    else
        msg_ok "$(translate "APT configuration for nag removal created")"
    fi

    # Apply nag removal immediately and trigger APT hook

    if apt --reinstall install proxmox-widget-toolkit > /dev/null 2>&1; then
        msg_ok "$(translate "proxmox-widget-toolkit reinstalled, triggering nag removal")"
    else
        msg_error "$(translate "Failed to reinstall proxmox-widget-toolkit")"
    fi
    msg_success "$(translate "Subscription banner and nag removal process completed")"
}





# ==========================================================





optimize_memory_settings() {
    msg_info2 "$(translate "Optimizing memory settings...")"
    NECESSARY_REBOOT=1

    local sysctl_conf="/etc/sysctl.d/99-memory.conf"

    # Check if the configuration file already exists and has the correct content
    if [ -f "$sysctl_conf" ] && \
       grep -q "Memory Optimising" "$sysctl_conf" && \
       grep -q "vm.min_free_kbytes = 1048576" "$sysctl_conf" && \
       grep -q "vm.nr_hugepages = 2000" "$sysctl_conf" && \
       grep -q "vm.max_map_count = 1048576" "$sysctl_conf" && \
       grep -q "vm.overcommit_memory = 1" "$sysctl_conf"; then
        msg_ok "$(translate "Memory settings already optimized")"
    else
        msg_info "$(translate "Applying memory optimization settings...")"
        # Create or update the configuration file
        cat <<EOF > "$sysctl_conf"
# Memory Optimising
## Bugfix: reserve 1024MB memory for system
vm.min_free_kbytes = 1048576
vm.nr_hugepages = 2000
# (Redis/MongoDB)
vm.max_map_count = 1048576
vm.overcommit_memory = 1
EOF
        msg_ok "$(translate "Memory settings optimized successfully")"
    fi

    msg_success "$(translate "Memory optimization completed")"
}





# ==========================================================





optimize_vzdump() {
    msg_info2 "$(translate "Optimizing vzdump backup speed...")"

    local vzdump_conf="/etc/vzdump.conf"

    # Configure bandwidth limit
    msg_info "$(translate "Configuring bandwidth limit for vzdump...")"
    if ! grep -q "^bwlimit: 0" "$vzdump_conf"; then
        sed -i '/^#*bwlimit:/d' "$vzdump_conf"
        echo "bwlimit: 0" >> "$vzdump_conf"
    fi
    msg_ok "$(translate "Bandwidth limit configured")"

    # Configure I/O priority
    msg_info "$(translate "Configuring I/O priority for vzdump...")"
    if ! grep -q "^ionice: 5" "$vzdump_conf"; then
        sed -i '/^#*ionice:/d' "$vzdump_conf"
        echo "ionice: 5" >> "$vzdump_conf"
    fi
    msg_ok "$(translate "I/O priority configured")"

    msg_success "$(translate "vzdump backup speed optimization completed")"
}





# ==========================================================





install_ovh_rtm() {
    msg_info2 "$(translate "Detecting if this is an OVH server and installing OVH RTM if necessary...")"

    # Get the public IP and check if it belongs to OVH
    msg_info "$(translate "Checking if the server belongs to OVH...")"
    public_ip=$(curl -s ipinfo.io/ip)
    is_ovh=$(whois -h v4.whois.cymru.com " -t $public_ip" | tail -n 1 | cut -d'|' -f3 | grep -i "ovh")

    if [ -n "$is_ovh" ]; then
        msg_ok "$(translate "OVH server detected")"

        msg_info "$(translate "Installing OVH RTM (Real Time Monitoring)...")"
        if wget -qO - https://last-public-ovh-infra-yak.snap.mirrors.ovh.net/yak/archives/apply.sh | OVH_PUPPET_MANIFEST=distribyak/catalog/master/puppet/manifests/common/rtmv2.pp bash > /dev/null 2>&1; then
            msg_ok "$(translate "OVH RTM installed successfully")"
        else
            msg_error "$(translate "Failed to install OVH RTM")"
        fi
    fi
    msg_ok "$(translate "Server belongs to OVH")"
    msg_success "$(translate "OVH server detection and RTM installation process completed")"
}




# ==========================================================



enable_ha() {
    msg_info2 "$(translate "Enabling High Availability (HA) services...")"
    NECESSARY_REBOOT=1

    msg_info "$(translate "Enabling High Availability (HA) services...")"
    # Enable all necessary services
    systemctl enable -q --now pve-ha-lrm pve-ha-crm corosync &>/dev/null


    msg_ok "$(translate "High Availability services have been enabled successfully")"
    msg_success "$(translate "High Availability setup completed")"


}




# ==========================================================






configure_fastfetch() {
    msg_info2 "$(translate "Installing and configuring Fastfetch...")"

    # Define paths
    local fastfetch_bin="/usr/local/bin/fastfetch"
    local fastfetch_config_dir="$HOME/.config/fastfetch"
    local logos_dir="/usr/local/share/fastfetch/logos"
    local fastfetch_config="$fastfetch_config_dir/config.jsonc"

    # Ensure directories exist
    mkdir -p "$fastfetch_config_dir"
    mkdir -p "$logos_dir"

    
    if command -v fastfetch &> /dev/null; then
        apt-get remove --purge -y fastfetch > /dev/null 2>&1
        rm -f /usr/bin/fastfetch /usr/local/bin/fastfetch
    fi

    
    msg_info "$(translate "Downloading the latest Fastfetch release...")"
    local fastfetch_deb_url=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest |
        jq -r '.assets[] | select(.name | test("fastfetch-linux-amd64.deb")) | .browser_download_url')

    if [[ -z "$fastfetch_deb_url" ]]; then
        msg_error "$(translate "Failed to retrieve Fastfetch download URL.")"
        return 1
    fi

    
    wget -qO /tmp/fastfetch.deb "$fastfetch_deb_url"
    if dpkg -i /tmp/fastfetch.deb > /dev/null 2>&1; then
        apt-get install -f -y  > /dev/null 2>&1 
        msg_ok "$(translate "Fastfetch installed successfully")"
    else
        msg_error "$(translate "Failed to install Fastfetch.")"
        return 1
    fi

    
    rm -f /tmp/fastfetch.deb

    
    if ! command -v fastfetch &> /dev/null; then
        msg_error "$(translate "Fastfetch is not installed correctly.")"
        return 1
    fi

    
    if [ ! -f "$fastfetch_config" ]; then
        echo '{"$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json", "modules": []}' > "$fastfetch_config"
    fi

    fastfetch --gen-config-force > /dev/null 2>&1

    while true; do
        # Define logo options
        local logo_options=("ProxMenux" "Proxmox (default)" "Comunidad Helper-Scripts" "Home-Labs-Club" "Proxmology" "Custom")
        local choice

        choice=$(whiptail --title "$(translate "Fastfetch Logo Selection")" --menu "$(translate "Choose a logo for Fastfetch:")" 20 78 6 \
            "1" "${logo_options[0]}" \
            "2" "${logo_options[1]}" \
            "3" "${logo_options[2]}" \
            "4" "${logo_options[3]}" \
            "5" "${logo_options[4]}" \
            "6" "${logo_options[5]}" \
            3>&1 1>&2 2>&3)

        case $choice in
            1)
                msg_info "$(translate "Downloading ProxMenux logo...")"
                local proxmenux_logo_path="$logos_dir/ProxMenux.txt"
                if wget -qO "$proxmenux_logo_path" "https://raw.githubusercontent.com/MacRimi/ProxMenux/main/images/logos_txt/logo.txt"; then
                    jq --arg path "$proxmenux_logo_path" '. + {logo: $path}' "$fastfetch_config" > "${fastfetch_config}.tmp" && mv "${fastfetch_config}.tmp" "$fastfetch_config"
                    msg_ok "$(translate "ProxMenux logo applied")"
                else
                    msg_error "$(translate "Failed to download ProxMenux logo")"
                fi
                break
                ;;
            2)
                msg_info "$(translate "Using default Proxmox logo...")"
                jq 'del(.logo)' "$fastfetch_config" > "${fastfetch_config}.tmp" && mv "${fastfetch_config}.tmp" "$fastfetch_config"
                msg_ok "$(translate "Default Proxmox logo applied")"
                break
                ;;
            3)
                msg_info "$(translate "Downloading Helper-Scripts logo...")"
                local helper_scripts_logo_path="$logos_dir/Helper_Scripts.txt"
                if wget -qO "$helper_scripts_logo_path" "https://raw.githubusercontent.com/MacRimi/ProxMenux/main/images/logos_txt/Helper_Scripts.txt"; then
                    jq --arg path "$helper_scripts_logo_path" '. + {logo: $path}' "$fastfetch_config" > "${fastfetch_config}.tmp" && mv "${fastfetch_config}.tmp" "$fastfetch_config"
                    msg_ok "$(translate "Helper-Scripts logo applied")"
                else
                    msg_error "$(translate "Failed to download Helper-Scripts logo")"
                fi
                break
                ;;
            4)
                msg_info "$(translate "Downloading Home-Labs-Club logo...")"
                local home_lab_club_logo_path="$logos_dir/home_labsclub.txt"
                if wget -qO "$home_lab_club_logo_path" "https://raw.githubusercontent.com/MacRimi/ProxMenux/main/images/logos_txt/home_labsclub.txt"; then
                    jq --arg path "$home_lab_club_logo_path" '. + {logo: $path}' "$fastfetch_config" > "${fastfetch_config}.tmp" && mv "${fastfetch_config}.tmp" "$fastfetch_config"
                    msg_ok "$(translate "Home-Lab-Club logo applied")"
                else
                    msg_error "$(translate "Failed to download Home-Lab-Club logo")"
                fi
                break
                ;;
            5)
                msg_info "$(translate "Downloading Proxmology logo...")"
                local proxmology_logo_path="$logos_dir/proxmology.txt"
                if wget -qO "$proxmology_logo_path" "https://raw.githubusercontent.com/MacRimi/ProxMenux/main/images/logos_txt/proxmology.txt"; then
                    jq --arg path "$proxmology_logo_path" '. + {logo: $path}' "$fastfetch_config" > "${fastfetch_config}.tmp" && mv "${fastfetch_config}.tmp" "$fastfetch_config"
                    msg_ok "$(translate "Proxmology logo applied")"
                else
                    msg_error "$(translate "Failed to download Proxmology logo")"
                fi
                break
                ;;
            6)
                whiptail --title "$(translate "Custom Logo Instructions")" --msgbox "$(translate "To use a custom Fastfetch logo, place your ASCII logo file in:\n\n/usr/local/share/fastfetch/logos/\n\nThe file should not exceed 35 lines to fit properly in the terminal.\n\nPress OK to continue and select your logo.")" 15 70

                local logo_files=($(ls "$logos_dir"/*.txt 2>/dev/null))
                
                if [ ${#logo_files[@]} -eq 0 ]; then
                    whiptail --title "$(translate "No Custom Logos Found")" --msgbox "$(translate "No custom logos were found in /usr/local/share/fastfetch/logos/.\n\nPlease add a logo and try again.")" 10 60
                    continue
                fi

                local menu_items=()
                local index=1
                for file in "${logo_files[@]}"; do
                    menu_items+=("$index" "$(basename "$file")")
                    index=$((index+1))
                done

                local selected_logo_index
                selected_logo_index=$(whiptail --title "$(translate "Select a Custom Logo")" --menu "$(translate "Choose a custom logo:")" 20 70 10 "${menu_items[@]}" 3>&1 1>&2 2>&3)

                if [ -z "$selected_logo_index" ]; then
                    continue
                fi

                local selected_logo="${logo_files[$((selected_logo_index-1))]}"
                jq --arg path "$selected_logo" '. + {logo: $path}' "$fastfetch_config" > "${fastfetch_config}.tmp" && mv "${fastfetch_config}.tmp" "$fastfetch_config"
                msg_ok "$(translate "Custom logo applied: $(basename "$selected_logo")")"
                break
                ;;
            *)
                msg_warn "$(translate "You must select a logo to continue.")"
                ;;
        esac
    done

    # Modify Fastfetch modules to display custom title
    msg_info "$(translate "Modifying Fastfetch configuration...")"

    jq '.modules |= map(select(. != "title"))' "$fastfetch_config" > "${fastfetch_config}.tmp" && mv "${fastfetch_config}.tmp" "$fastfetch_config"

    jq 'del(.modules[] | select(type == "object" and .type == "custom"))' "$fastfetch_config" > "${fastfetch_config}.tmp" && mv "${fastfetch_config}.tmp" "$fastfetch_config"

    jq '.modules |= [{"type": "custom", "format": "\u001b[1;38;5;166mSystem optimised by ProxMenux\u001b[0m"}] + .' "$fastfetch_config" > "${fastfetch_config}.tmp" && mv "${fastfetch_config}.tmp" "$fastfetch_config"

    msg_ok "$(translate "Fastfetch now displays: System optimised by: ProxMenux")"

    fastfetch --gen-config > /dev/null 2>&1
    msg_ok "$(translate "Fastfetch configuration updated")"

    sed -i '/fastfetch/d' ~/.bashrc ~/.profile /etc/profile
    rm -f /etc/update-motd.d/99-fastfetch  

    echo "clear && fastfetch" >> ~/.bashrc
    msg_ok "$(translate "Fastfetch will start automatically in the console")"

    msg_success "$(translate "Fastfetch installation and configuration completed")"

}





# ==========================================================






add_repo_test() {
 msg_info2 "$(translate "Enable Proxmox testing repository...")"
    # Enable Proxmox testing repository
    if [ ! -f /etc/apt/sources.list.d/pve-testing-repo.list ] || ! grep -q "pvetest" /etc/apt/sources.list.d/pve-testing-repo.list; then
        msg_info "$(translate "Enabling Proxmox testing repository...")"
        echo -e "deb http://download.proxmox.com/debian/pve ${OS_CODENAME} pvetest\\n" > /etc/apt/sources.list.d/pve-testing-repo.list
        msg_ok "$(translate "Proxmox testing repository enabled")"
    fi
 msg_success "$(translate "Proxmox testing repository has been successfully enabled")"
}






# ==========================================================






# Main menu function
main_menu() {
local HEADER=$(printf " %-56s %10s" "$(translate "Description")" "$(translate "Category")")

# Define category order
declare -A category_order
category_order["Basic Settings"]=1
category_order["System"]=2
category_order["Hardware"]=3
category_order["Virtualization"]=4
category_order["Network"]=5
category_order["Storage"]=6
category_order["Security"]=7
category_order["Customization"]=8
category_order["Monitoring"]=9
category_order["Performance"]=10
category_order["Optional"]=11

# Define options with categories
local options=(
    "Basic Settings|Update and upgrade system|APTUPGRADE"
    "Basic Settings|Synchronize time automatically|TIMESYNC"
    "Basic Settings|Skip downloading additional languages|NOAPTLANG"
    "Basic Settings|Install common system utilities|UTILS"
    "System|Optimize journald|JOURNALD"
    "System|Optimize logrotate|LOGROTATE"
    "System|Increase various system limits|LIMITS"
    "System|Ensure entropy pools are populated|ENTROPY"
    "System|Optimize Memory|MEMORYFIXES"
    "System|Enable fast reboots|KEXEC"
    "System|Enable restart on kernel panic|KERNELPANIC"
    "System|Install kernel headers|KERNELHEADERS"
    "Optional|Apply AMD CPU fixes|AMDFIXES"
    "Virtualization|Install relevant guest agent|GUESTAGENT"
    "Virtualization|Enable VFIO IOMMU support|VFIO_IOMMU"
    "Virtualization|KSM control daemon|KSMTUNED"
    "Network|Force APT to use IPv4|APTIPV4"
    "Network|Apply network optimizations|NET"
    "Network|Install Open vSwitch|OPENVSWITCH"
    "Network|Enable TCP BBR/Fast Open control|TCPFASTOPEN"
    "Storage|Optimize ZFS ARC size|ZFSARC"
    "Storage|Install ZFS auto-snapshot|ZFSAUTOSNAPSHOT"
    "Storage|Increase vzdump backup speed|VZDUMP"
    "Security|Disable portmapper/rpcbind|DISABLERPC"
    "Security|Protect web interface with fail2ban|FAIL2BAN"
    "Security|Install Lynis security tool|LYNIS"
    "Customization|Customize bashrc|BASHRC"
    "Customization|Set up custom MOTD banner|MOTD"
    "Customization|Remove subscription banner|NOSUBBANNER"
    "Monitoring|Install OVH Real Time Monitoring|OVHRTM"
    "Performance|Use pigz for faster gzip compression|PIGZ"
    "Optional|Install and configure Fastfetch|FASTFETCH"
    "Optional|Add latest Ceph support|CEPH"
    "Optional|Add Proxmox testing repository|REPOTEST"
    "Optional|Enable High Availability services|ENABLE_HA"
)


# Sort options based on category order
IFS=$'\n' sorted_options=($(for option in "${options[@]}"; do
    IFS='|' read -r category description function_name <<< "$option"
    printf "%d|%s|%s|%s\n" "${category_order[$category]:-999}" "$category" "$description" "$function_name"
done | sort -n | cut -d'|' -f2-))
unset IFS

local menu_items=()
local i=1
local previous_category=""

for option in "${sorted_options[@]}"; do
    IFS='|' read -r category description function_name <<< "$option"
    translated_category=$(translate "$category")
    translated_description=$(translate "$description")

    # Set ON for all categories except Optional
    state="ON"
    if [ "$category" = "Optional" ]; then
        state="OFF"
    fi

    # Add a separator before Optional category, but only once
    if [ "$category" != "$previous_category" ] && [ "$category" = "Optional" ] && [ "$previous_category" != "" ]; then
        menu_items+=("" "================================================================" "")
    fi

    menu_items+=("$i" "$(printf "%-50s %s" "$translated_description" "$translated_category")" "$state")
    i=$((i+1))
    previous_category="$category"
done

cleanup

local selected_indices=$(whiptail --title "$(translate "ProxMenux Custom Script for Post-Installation")" \
                                  --checklist --separate-output \
                                  "\n$HEADER\n\n$(translate "Choose options to configure:")\n$(translate "Use [SPACE] to select/deselect and [ENTER] to confirm:")" \
                                  20 82 12 \
                                  "${menu_items[@]}" \
                                  3>&1 1>&2 2>&3)
    if [ $? -ne 0 ]; then
        echo "User cancelled. Exiting."
        exit 0
    fi


# Convert selected_indices to an array
IFS=$'\n' read -d '' -r -a selected_options <<< "$selected_indices"

declare -A selected_functions


if [ -n "$selected_indices" ]; then
        msg_title "$SCRIPT_TITLE"


# Mark selected options and apply exclusion logic
for index in "${selected_options[@]}"; do
    option=${sorted_options[$((index-1))]}
    IFS='|' read -r category description function_name <<< "$option"
    selected_functions[$function_name]=1

    # If FASTFETCH is selected, unmark MOTD
    if [[ "$function_name" == "FASTFETCH" ]]; then
        selected_functions[MOTD]=0
    fi
done

# Process selected options
for index in "${!sorted_options[@]}"; do
    option=${sorted_options[$index]}
    IFS='|' read -r category description function_name <<< "$option"
    if [[ ${selected_functions[$function_name]} -eq 1 ]]; then
        case $function_name in
            APTUPGRADE)
                apt_upgrade
                ;;
            TIMESYNC)
                configure_time_sync
                ;;
            NOAPTLANG)
                skip_apt_languages
                ;;
            UTILS)
                install_system_utils
                ;;
            JOURNALD)
                optimize_journald
                ;;
            LOGROTATE)
                optimize_logrotate
                ;;
            LIMITS)
                increase_system_limits
                ;;
            ENTROPY)
                configure_entropy
                ;;
            MEMORYFIXES)
                optimize_memory_settings
                ;;
            KEXEC)
                enable_kexec
                ;;
            KERNELPANIC)
                configure_kernel_panic
                ;;
            KERNELHEADERS)
                install_kernel_headers
                ;;
            AMDFIXES)
                apply_amd_fixes
                ;;
            GUESTAGENT)
                install_guest_agent
                ;;
            VFIO_IOMMU)
                enable_vfio_iommu
                ;;
            KSMTUNED)
                configure_ksmtuned
                ;;
            APTIPV4)
                force_apt_ipv4
                ;;
            NET)
                apply_network_optimizations
                ;;
            OPENVSWITCH)
                install_openvswitch
                ;;
            TCPFASTOPEN)
                enable_tcp_fast_open
                ;;
            ZFSARC)
                optimize_zfs_arc
                ;;
            ZFSAUTOSNAPSHOT)
                install_zfs_auto_snapshot
                ;;
            VZDUMP)
                optimize_vzdump
                ;;
            DISABLERPC)
                disable_rpc
                ;;
            FAIL2BAN)
                install_fail2ban
                ;;
            LYNIS)
                install_lynis
                ;;
            BASHRC)
                customize_bashrc
                ;;
            MOTD)
                setup_motd
                ;;
            NOSUBBANNER)
                remove_subscription_banner
                ;;
            OVHRTM)
                install_ovh_rtm
                ;;
            PIGZ)
                configure_pigz
                ;;
            FASTFETCH)
                configure_fastfetch
                ;;
            CEPH)
                install_ceph
                ;;
            REPOTEST)
                add_repo_test
                ;;
            ENABLE_HA)
                enable_ha
                ;;
            *)
                echo "Option $function_name not implemented yet"
                ;;
        esac
     fi
    done





  if [ "$NECESSARY_REBOOT" -eq 1 ]; then
    whiptail --title "Reboot Required" --yesno "$(translate "Some changes require a reboot to take effect. Do you want to restart now?")" 10 60
    if [ $? -eq 0 ]; then

        msg_info "$(translate "Removing no longer required packages and purging old cached updates...")"
        /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' autoremove >/dev/null 2>&1
        /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' autoclean >/dev/null 2>&1
        msg_ok "$(translate "Cleanup finished")"
        msg_warn  "$(translate "Rebooting the system...")"
        reboot
    else
        msg_info "$(translate "Removing no longer required packages and purging old cached updates...")"
        /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' autoremove >/dev/null 2>&1
        /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' autoclean >/dev/null 2>&1
        msg_ok "$(translate "Cleanup finished")"
        msg_info2 "$(translate "You can reboot later manually.")"
        exit 0
    fi

  fi
    msg_success "$(translate "All changes applied. No reboot required.")"
else
        exit 0
fi

}



show_proxmenux_logo
if [[ "$LANGUAGE" != "en" ]]; then
    msg_lang "$(translate "Generating automatic translations...")"
fi
main_menu

