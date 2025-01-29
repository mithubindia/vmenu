show_storage_menu() {
    while true; do
        OPTION=$(whiptail --title "$(translate "Disk and Storage Menu")" --menu "$(translate "Select an option:")" 15 60 3 \
            "1" "$(translate "Add Disk Passthrough to a VM")" \
            "2" "$(translate "Import Disk Image to a VM")" \
            "3" "$(translate "Return to Main Menu")" 3>&1 1>&2 2>&3)

        case $OPTION in
            1)
                echo -e "\033[33m[INFO] $(translate "Running script:") $(translate "Disk Passthrough")...\033[0m"
                bash <(curl -s "$REPO_URL/scripts/disk-passthrough.sh")
                if [ $? -ne 0 ]; then
                    msg_info "$(translate "Operation cancelled.")"
                    sleep 2
                fi
                ;;
            2)
                echo -e "\033[33m[INFO] $(translate "Running script:") $(translate "Import Disk Image")...\033[0m"
                bash <(curl -s "$REPO_URL/scripts/import-disk-image.sh")
                if [ $? -ne 0 ]; then
                    msg_info "$(translate "Operation cancelled.")"
                    sleep 2
                fi
                ;;
            3)
                return
                ;;
            *)
                return
                ;;
        esac
    done
