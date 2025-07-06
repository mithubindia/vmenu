#!/bin/bash
# ==========================================================
# ProxMenu - Network Management and Repair Tool
# ==========================================================
# Author      : MacRimi
# Copyright   : (c) 2024 MacRimi
# License     : MIT (https://raw.githubusercontent.com/MacRimi/ProxMenux/main/LICENSE)
# Version     : 1.1
# Last Updated: 06/07/2025
# ==========================================================

# Description:
# ProxMenu is an advanced yet user-friendly network management tool for Proxmox VE.
# Core features:
# - View and analyze network interfaces, bridges, and routing table
# - Test Internet and LAN connectivity
# - Diagnose and repair basic network issues
# - Backup, restore, and clean network configuration
# - Safely restart the network service

# Configuration ============================================
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
BASE_DIR="/usr/local/share/proxmenux"
UTILS_FILE="$BASE_DIR/utils.sh"
VENV_PATH="/opt/googletrans-env"
BACKUP_DIR="/var/backups/proxmenux"

if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
fi

load_language
initialize_cache

# ==========================================================

create_backup_dir() {
    [ ! -d "$BACKUP_DIR" ] && mkdir -p "$BACKUP_DIR"
}

backup_network_config() {
    create_backup_dir
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    cp /etc/network/interfaces "$BACKUP_DIR/interfaces_backup_$timestamp"
    msg_ok "$(translate "Network configuration backed up")"
}

# ==========================================================

detect_physical_interfaces() {
    ip -o link show | awk -F': ' '$2 !~ /^(lo|veth|dummy|bond|tap|tun)/ && $2 !~ /vmbr/ {print $2}' | sort
}

detect_bridge_interfaces() {
    ip -o link show | awk -F': ' '$2 ~ /^vmbr/ {print $2}' | sort
}

detect_all_interfaces() {
    ip -o link show | awk -F': ' '$2 !~ /^(lo|veth|dummy|tap|tun)/ {print $2}' | sort
}

get_interface_info() {
    local interface="$1"
    local info=""
    

    local ip=$(ip -4 addr show "$interface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+' | head -1)
    [ -z "$ip" ] && ip="$(translate "No IP")"
    

    local status=$(ip link show "$interface" 2>/dev/null | grep -o "state [A-Z]*" | cut -d' ' -f2)
    [ -z "$status" ] && status="UNKNOWN"
    

    local mac=$(ip link show "$interface" 2>/dev/null | grep -o "link/ether [a-f0-9:]*" | cut -d' ' -f2)
    [ -z "$mac" ] && mac="$(translate "No MAC")"
    
    echo "$interface|$ip|$status|$mac"
}

# ==========================================================

show_interface_details() {
    local interfaces=($(detect_all_interfaces))
    local info_text=""
    
    info_text+="$(translate "Network Interface Details")\n"
    info_text+="$(printf '=%.0s' {1..50})\n\n"
    
    for interface in "${interfaces[@]}"; do
        local details=$(get_interface_info "$interface")
        IFS='|' read -r name ip status mac <<< "$details"
        
        info_text+="$(translate "Interface"): $name\n"
        info_text+="  $(translate "IP Address"): $ip\n"
        info_text+="  $(translate "Status"): $status\n"
        info_text+="  $(translate "MAC Address"): $mac\n\n"
    done
    
    dialog --title "$(translate "Interface Details")" \
           --msgbox "$info_text" 20 70
}

show_bridge_status() {
    local bridges=($(detect_bridge_interfaces))
    local bridge_info=""
    
    bridge_info+="$(translate "Bridge Configuration Status")\n"
    bridge_info+="$(printf '=%.0s' {1..40})\n\n"
    
    if [ ${#bridges[@]} -eq 0 ]; then
        bridge_info+="$(translate "No bridges found")\n"
    else
        for bridge in "${bridges[@]}"; do
            local details=$(get_interface_info "$bridge")
            IFS='|' read -r name ip status mac <<< "$details"
            

            local ports=$(grep -A5 "iface $bridge" /etc/network/interfaces 2>/dev/null | grep "bridge-ports" | cut -d' ' -f2-)
            [ -z "$ports" ] && ports="$(translate "None")"
            
            bridge_info+="$(translate "Bridge"): $name\n"
            bridge_info+="  $(translate "IP"): $ip\n"
            bridge_info+="  $(translate "Status"): $status\n"
            bridge_info+="  $(translate "Ports"): $ports\n\n"
        done
    fi
    
    dialog --title "$(translate "Bridge Status")" \
           --msgbox "$bridge_info" 18 70
}

show_routing_table() {
    local route_info=""
    route_info+="$(translate "Routing Table")\n"
    route_info+="$(printf '=%.0s' {1..30})\n\n"
    route_info+="$(ip route show)\n\n"
    route_info+="$(translate "Default Gateway"): $(ip route | grep default | awk '{print $3}' | head -1)\n"
    
    dialog --title "$(translate "Routing Information")" \
           --msgbox "$route_info" 15 80
}

# ==========================================================

test_connectivity() {
    local test_results=""
    local tests=(
        "8.8.8.8|Google DNS"
        "1.1.1.1|Cloudflare DNS"
        "$(ip route | grep default | awk '{print $3}' | head -1)|Gateway"
    )
    show_proxmenux_logo
    msg_info "$(translate "Test Connectivity")"
    test_results+="$(translate "Connectivity Test Results")\n"
    test_results+="$(printf '=%.0s' {1..35})\n\n"
    
    for test in "${tests[@]}"; do
        IFS='|' read -r target name <<< "$test"
        if [ -n "$target" ] && [ "$target" != "" ]; then
            if ping -c 2 -W 3 "$target" >/dev/null 2>&1; then
                test_results+="✓ $name ($target): $(translate "OK")\n"
            else
                test_results+="✗ $name ($target): $(translate "FAILED")\n"
            fi
        fi
    done
    

    if nslookup google.com >/dev/null 2>&1; then
        test_results+="✓ $(translate "DNS Resolution"): $(translate "OK")\n"
    else
        test_results+="✗ $(translate "DNS Resolution"): $(translate "FAILED")\n"
    fi
    cleanup
    dialog --title "$(translate "Connectivity Test")" \
           --msgbox "$test_results" 15 60
}

advanced_network_diagnostics() {
    show_proxmenux_logo
    msg_info "$(translate "Advanced Diagnostics")"
    sleep 1
    
    local diag_info=""
    
    diag_info+="$(translate "Advanced Network Diagnostics")\n"
    diag_info+="$(printf '=%.0s' {1..40})\n\n"
    

    diag_info+="$(translate "Active Connections"): $(ss -tuln | wc -l)\n"
    diag_info+="$(translate "Listening Ports"): $(ss -tln | grep LISTEN | wc -l)\n"
    diag_info+="$(translate "Network Interfaces"): $(ip link show | grep -c "^[0-9]")\n\n"
    

    diag_info+="$(translate "Common Issues Check"):\n"
    

    if systemctl is-active --quiet NetworkManager 2>/dev/null; then
        diag_info+="⚠ $(translate "NetworkManager is running (may cause conflicts)")\n"
    else
        diag_info+="✓ $(translate "NetworkManager not running")\n"
    fi
    

    local ips=($(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | sort | uniq -d))
    if [ ${#ips[@]} -gt 0 ]; then
        diag_info+="⚠ $(translate "Duplicate IP addresses found"): ${ips[*]}\n"
    else
        diag_info+="✓ $(translate "No duplicate IP addresses")\n"
    fi
    cleanup 
    dialog --title "$(translate "Network Diagnostics")" \
           --msgbox "$diag_info" 18 70
}

# ==========================================================

repair_bridge_configuration() {
    show_proxmenux_logo
    msg_info "$(translate "Analyzing Bridge Configuration")"
    sleep 1
    
    local physical_interfaces=($(detect_physical_interfaces))
    local bridges=($(detect_bridge_interfaces))
    local issues_found=""
    local proposed_changes=""
    

    for bridge in "${bridges[@]}"; do
        local current_ports=$(grep -A5 "iface $bridge" /etc/network/interfaces 2>/dev/null | grep "bridge-ports" | cut -d' ' -f2-)
        
        if [ -n "$current_ports" ]; then
            local invalid_ports=""
            local valid_ports=""
            
            for port in $current_ports; do
                if ip link show "$port" >/dev/null 2>&1; then
                    valid_ports+="$port "
                else
                    invalid_ports+="$port "
                fi
            done
            
            if [ -n "$invalid_ports" ]; then
                issues_found+="$(translate "Bridge") $bridge: $(translate "Invalid ports") - $invalid_ports\n"
                if [ -z "$valid_ports" ] && [ ${#physical_interfaces[@]} -gt 0 ]; then
                    proposed_changes+="$(translate "Assign") ${physical_interfaces[0]} $(translate "to") $bridge\n"
                else
                    proposed_changes+="$(translate "Remove invalid ports from") $bridge\n"
                fi
            fi
        fi
    done
    cleanup
    if [ -z "$issues_found" ]; then
        dialog --title "$(translate "Bridge Analysis")" \
               --msgbox "\n$(translate "No bridge configuration issues found.")" 8 60
        return
    fi
    

    local confirmation_text=""
    confirmation_text+="$(translate "Bridge Configuration Issues Found"):\n\n"
    confirmation_text+="$issues_found\n"
    confirmation_text+="$(translate "Proposed Changes"):\n\n"
    confirmation_text+="$proposed_changes\n"
    confirmation_text+="$(translate "A backup will be created before making changes.")\n\n"
    confirmation_text+="$(translate "Do you want to proceed with these repairs?")"
    
    if ! dialog --title "$(translate "Confirm Bridge Repair")" \
                --yesno "$confirmation_text" 18 70; then
        return
    fi
    

    show_proxmenux_logo
    echo -e
    backup_network_config
    sleep 1
    
    local repair_log=""
    repair_log+="$(translate "Bridge Repair Process")\n"
    repair_log+="$(printf '=%.0s' {1..30})\n\n"
    
    for bridge in "${bridges[@]}"; do
        local current_ports=$(grep -A5 "iface $bridge" /etc/network/interfaces 2>/dev/null | grep "bridge-ports" | cut -d' ' -f2-)
        
        if [ -n "$current_ports" ]; then
            local valid_ports=""
            for port in $current_ports; do
                if ip link show "$port" >/dev/null 2>&1; then
                    valid_ports+="$port "
                else
                    repair_log+="⚠ $(translate "Removed invalid port"): $port $(translate "from") $bridge\n"
                fi
            done
            
            if [ -z "$valid_ports" ] && [ ${#physical_interfaces[@]} -gt 0 ]; then
                valid_ports="${physical_interfaces[0]}"
                repair_log+="✓ $(translate "Assigned port"): ${physical_interfaces[0]} $(translate "to") $bridge\n"
            fi
            
            if [ "$valid_ports" != "$current_ports" ]; then
                sed -i "/iface $bridge/,/bridge-ports/ s/bridge-ports.*/bridge-ports $valid_ports/" /etc/network/interfaces
                repair_log+="✓ $(translate "Updated bridge"): $bridge\n"
            else
                repair_log+="✓ $(translate "Bridge OK"): $bridge\n"
            fi
        fi
    done
    
    dialog --title "$(translate "Bridge Repair Complete")" \
           --msgbox "$repair_log" 15 70
}

clean_network_configuration() {

    show_proxmenux_logo
    msg_info "$(translate "Analyzing Network Configuration")"
    sleep 1
    

    local configured_interfaces=($(grep "^iface" /etc/network/interfaces | awk '{print $2}' | grep -v "lo"))
    local interfaces_to_remove=""
    
    for iface in "${configured_interfaces[@]}"; do
        if [[ ! $iface =~ ^(vmbr|bond) ]] && ! ip link show "$iface" >/dev/null 2>&1; then
            interfaces_to_remove+="$iface "
        fi
    done
    cleanup
    if [ -z "$interfaces_to_remove" ]; then
        dialog --title "$(translate "Configuration Analysis")" \
               --msgbox "\n$(translate "No invalid interface configurations found.")" 8 60
        return
    fi
    

    local confirmation_text=""
    confirmation_text+="$(translate "Invalid Interface Configurations Found"):\n\n"
    confirmation_text+="$(translate "The following interfaces are configured but don't exist"):\n"
    confirmation_text+="$interfaces_to_remove\n\n"
    confirmation_text+="$(translate "These configurations will be removed from") /etc/network/interfaces\n"
    confirmation_text+="$(translate "A backup will be created before making changes.")\n\n"
    confirmation_text+="$(translate "Do you want to proceed with cleanup?")"
    
    if ! dialog --title "$(translate "Confirm Configuration Cleanup")" \
                --yesno "$confirmation_text" 16 70; then
        return
    fi
    
    show_proxmenux_logo
    echo -e
    backup_network_config
    sleep 1

    local cleanup_log=""
    cleanup_log+="$(translate "Network Configuration Cleanup")\n"
    cleanup_log+="$(printf '=%.0s' {1..35})\n\n"
    
    for iface in "${configured_interfaces[@]}"; do
        if [[ ! $iface =~ ^(vmbr|bond) ]] && ! ip link show "$iface" >/dev/null 2>&1; then
            sed -i "/iface $iface/,/^$/d" /etc/network/interfaces
            cleanup_log+="✓ $(translate "Removed configuration for"): $iface\n"
        fi
    done
    
    cleanup_log+="$(translate "Cleanup completed")\n"
    
    dialog --title "$(translate "Configuration Cleanup Complete")" \
           --msgbox "$cleanup_log" 12 60
}

restart_network_service() {
    if dialog --title "$(translate "Restart Network")" \
              --yesno "$(translate "This will restart the network service and may cause a brief disconnection. Continue?")" 10 60; then
        
        clear
        msg_info "$(translate "Restarting network service...")"
        
        if systemctl restart networking; then
            msg_ok "$(translate "Network service restarted successfully")"
        else
            msg_error "$(translate "Failed to restart network service")"
        fi
        
        msg_success "$(translate "Press ENTER to continue...")"
        read -r
    fi
}

# ==========================================================

show_network_config() {
    local config_content
    config_content=$(cat /etc/network/interfaces)
    show_proxmenux_logo
    echo -e
    echo -e
    echo "========== $(translate "Network Configuration File") =========="
    echo
    cat /etc/network/interfaces
    echo
    msg_success "$(translate "Press Enter to continue...")"
    read -r
}

restore_network_backup() {
    local backups=($(ls -1 "$BACKUP_DIR"/interfaces_backup_* 2>/dev/null | sort -r))
    
    if [ ${#backups[@]} -eq 0 ]; then
        dialog --title "$(translate "No Backups")" \
               --msgbox "$(translate "No network configuration backups found.")" 8 50
        return
    fi
    
    local menu_items=()
    local counter=1
    
    for backup in "${backups[@]}"; do
        local filename=$(basename "$backup")
        local timestamp=$(echo "$filename" | sed 's/interfaces_backup_//' | sed 's/_/ /')
        menu_items+=("$counter" "$timestamp")
        ((counter++))
    done
    
    local selection=$(dialog --title "$(translate "Restore Backup")" \
                            --menu "$(translate "Select backup to restore:"):" 15 60 8 \
                            "${menu_items[@]}" 3>&1 1>&2 2>&3)
    
    if [ -n "$selection" ] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#backups[@]} ]; then
        local selected_backup="${backups[$((selection-1))]}"
        
        if dialog --title "$(translate "Confirm Restore")" \
                  --yesno "$(translate "Are you sure you want to restore this backup? Current configuration will be overwritten.")" 10 60; then
            
            cp "$selected_backup" /etc/network/interfaces
            dialog --title "$(translate "Backup Restored")" \
                   --msgbox "$(translate "Network configuration has been restored from backup.")" 8 60
        fi
    fi
}

# ==========================================================

show_main_menu() {
    while true; do
        local selection=$(dialog --clear \
                                --backtitle "ProxMenux" \
                                --title "$(translate "Network Management")" \
                                --menu "$(translate "Select an option:"):" 20 70 12 \
                                "1" "$(translate "Show Interface Details")" \
                                "2" "$(translate "Show Bridge Status")" \
                                "3" "$(translate "Show Routing Table")" \
                                "4" "$(translate "Test Connectivity")" \
                                "5" "$(translate "Advanced Diagnostics")" \
                                "8" "$(translate "Restart Network Service")" \
                                "9" "$(translate "Show Network Config File")" \
                                "10" "$(translate "Restore Network Backup")" \
                                "0" "$(translate "Return to Main Menu")" \
                                3>&1 1>&2 2>&3)

                               # "6" "$(translate "Repair Bridge Configuration")" \
                               # "7" "$(translate "Clean Network Configuration")" \
        
        case $selection in
            1) show_interface_details ;;
            2) show_bridge_status ;;
            3) show_routing_table ;;
            4) test_connectivity ;;
            5) advanced_network_diagnostics ;;
            6) repair_bridge_configuration ;;
            7) clean_network_configuration ;;
            8) restart_network_service ;;
            9) show_network_config ;;
            10) restore_network_backup ;;
            0|"") exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh") ;;
        esac
    done
}

# ==========================================================
show_main_menu