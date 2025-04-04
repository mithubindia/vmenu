#!/bin/bash

VMID="105"

echo -e "\n=== 📦 Discos físicos detectados (lsblk) ==="
lsblk -dn -o PATH,TYPE | awk '$2 == "disk" {print $1}'

echo -e "\n=== 📌 Discos montados ==="
mount | grep /dev/sd || echo "Ninguno"

echo -e "\n=== 🧱 Discos en uso por LVM (pvs) ==="
pvs --noheadings -o pv_name | xargs -n1 readlink -f | sort -u || echo "Ninguno"

echo -e "\n=== ⚠ RAID activos (mdstat) ==="
awk '/^md/ {for (i=4; i<=NF; i++) print $i}' /proc/mdstat || echo "Ninguno"

echo -e "\n=== 💻 Discos ya asignados a la VM ID $VMID ==="
qm config "$VMID" | grep -E '^(scsi|sata|virtio|ide)[0-9]+:' | awk -F ':' '{print $2}' | cut -d',' -f1

echo -e "\n=== 🧪 FSTYPE de cada disco ==="
for disk in $(lsblk -dn -o PATH,TYPE | awk '$2 == "disk" {print $1}'); do
    echo -e "\n→ $disk"
    lsblk -ln -o NAME,FSTYPE "$disk" | tail -n +2
done



echo "📋 Analizando discos físicos..."
ACTIVE_MD_DEVICES=$(awk '/^md/ {for (i=4; i<=NF; i++) print $i}' /proc/mdstat)
LVM_DEVICES=$(pvs --noheadings -o pv_name | xargs -n1 readlink -f | sed 's/ *$//' | sort -u)
MOUNTED_DISKS=$(mount | grep /dev/sd | awk '{print $1}' | sort -u)

for DISK in $(lsblk -dn -o PATH,TYPE | awk '$2 == "disk" {print $1}'); do
    echo -e "\n🔍 Disco: $DISK"
    echo " - En LVM: $(echo "$LVM_DEVICES" | grep -Fxq "$DISK" && echo 'SÍ' || echo 'NO')"
    echo " - Es ZVOL (zd*): $( [[ $(basename "$DISK") == zd* ]] && echo 'SÍ' || echo 'NO')"
    echo " - Ya está en la VM: $(qm config "$VMID" | grep -q "$DISK" && echo 'SÍ' || echo 'NO')"

    IS_MOUNTED=false
    IS_RAID=false
    IS_RAID_ACTIVE=false
    IS_ZFS=false

    while read -r part fstype; do
        full_path="/dev/$part"
        real_path=$(readlink -f "$full_path")

        [[ -z "$fstype" ]] && continue

        echo "   ➤ Partición: $part ($fstype)"
        if echo "$MOUNTED_DISKS" | grep -q "$full_path"; then
            echo "     ⛔ Montado en el sistema"
            IS_MOUNTED=true
        fi

        if echo "$LVM_DEVICES" | grep -Fxq "$real_path"; then
            echo "     ⛔ En uso por LVM"
            IS_MOUNTED=true
        fi

        if [[ "$fstype" == "linux_raid_member" ]]; then
            IS_RAID=true
            if echo "$ACTIVE_MD_DEVICES" | grep -q "$part"; then
                IS_RAID_ACTIVE=true
                echo "     ⛔ RAID activo"
            else
                echo "     ⚠ RAID pasivo"
            fi
        fi

        if [[ "$fstype" == "zfs_member" ]]; then
            IS_ZFS=true
            echo "     ⛔ ZFS detectado"
        fi

    done < <(lsblk -ln -o NAME,FSTYPE "$DISK" | tail -n +2)

    echo "Resumen:"
    echo " - Montado: $IS_MOUNTED"
    echo " - RAID activo: $IS_RAID_ACTIVE"
    echo " - RAID pasivo: $IS_RAID"
    echo " - ZFS: $IS_ZFS"
done

