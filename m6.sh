#!/bin/bash

total=0

find /home/gs/Projects/vmenu -type f | while read -r file; do
    count=$(grep -o 'Virtuliservmenu' "$file" | wc -l)
    if [ "$count" -gt 0 ]; then
        sed -i 's/Virtuliservmenu/Virtuliservmenu/g' "$file"
        echo "$count replacement(s) in: $file"
        total=$((total + count))
    fi
done

echo "Total replacements made: $total"
