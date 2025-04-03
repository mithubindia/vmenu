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
