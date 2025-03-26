#!/bin/bash
#set -x


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


CONFIG_FILE="/etc/proxmox-telegram.conf"
PID_DIR="/var/run/proxmox-telegram"


# Crear archivo de configuración si no existe
if [[ ! -f "$CONFIG_FILE" ]]; then
    cat <<EOF > "$CONFIG_FILE"
BOT_TOKEN=""
CHAT_ID=""
vm_start=0
vm_shutdown=0
vm_restart=0
vm_fail=0
update_available=0
update_complete=0
system_shutdown=0
system_problem=0
system_load_high=0
kernel_panic=0
disk_fail=0
disk_full=0
disk_io_error=0
node_disconnect=0
split_brain=0
network_down=0
network_saturation=0
firewall_issue=0
backup_complete=0
backup_fail=0
snapshot_complete=0
snapshot_fail=0
auth_fail=0
ip_block=0
user_permission_change=0
cpu_high=0
ram_high=0
temp_high=0
low_disk_space=0
EOF
    chmod 600 "$CONFIG_FILE"  # Proteger el archivo de configuración
fi

# Leer configuración actual
source "$CONFIG_FILE"

# Función para enviar notificaciones a Telegram (sin logging)
send_notification() {
    local message="$1"
    
    # Si el token o chat ID están vacíos → No enviar nada
    if [[ -z "$BOT_TOKEN" || -z "$CHAT_ID" ]]; then
        return 1
    fi
    
    # Enviar notificación a Telegram (sin output)
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "text=$message" > /dev/null 2>&1
}

# Opciones para el menú
options=(
    "VM y Contenedor|Inicio de VM/Contenedor|vm_start"
    "VM y Contenedor|Apagado de VM/Contenedor|vm_shutdown"
    "VM y Contenedor|Reinicio de VM/Contenedor|vm_restart"
    "VM y Contenedor|Error en inicio de VM/Contenedor|vm_fail"
    "Sistema|Nueva actualización disponible|update_available"
    "Sistema|Actualización completada|update_complete"
    "Sistema|Apagado del sistema|system_shutdown"
    "Sistema|Problema con el sistema|system_problem"
    "Sistema|Carga del sistema alta|system_load_high"
    "Sistema|Kernel Panic|kernel_panic"
    "Almacenamiento|Fallo de disco|disk_fail"
    "Almacenamiento|Almacenamiento lleno|disk_full"
    "Almacenamiento|Problemas de lectura/escritura|disk_io_error"
    "Clúster|Nodo desconectado|node_disconnect"
    "Clúster|Split-brain (conflicto en quorum)|split_brain"
    "Red|Interfaz de red caída|network_down"
    "Red|Saturación de red|network_saturation"
    "Red|Problema con el firewall|firewall_issue"
    "Backup y Snapshot|Backup completado|backup_complete"
    "Backup y Snapshot|Backup fallido|backup_fail"
    "Backup y Snapshot|Snapshot completado|snapshot_complete"
    "Backup y Snapshot|Snapshot fallido|snapshot_fail"
    "Seguridad|Intento de autenticación fallido|auth_fail"
    "Seguridad|Bloqueos automáticos de IP|ip_block"
    "Seguridad|Cambio de permisos de usuario|user_permission_change"
    "Recursos|Uso alto de CPU|cpu_high"
    "Recursos|Uso alto de RAM|ram_high"
    "Recursos|Temperatura alta del sistema|temp_high"
    "Recursos|Bajo espacio en disco|low_disk_space"
)

# Función para obtener el nombre de una VM/CT a partir de su ID
get_vm_name() {
    local vmid="$1"
    local name=""
    
    if [[ -f "/etc/pve/qemu-server/$vmid.conf" ]]; then
        name=$(grep -i "^name:" "/etc/pve/qemu-server/$vmid.conf" | cut -d ' ' -f2-)
    elif [[ -f "/etc/pve/lxc/$vmid.conf" ]]; then
        name=$(grep -i "^hostname:" "/etc/pve/lxc/$vmid.conf" | cut -d ' ' -f2-)
    fi
    
    # Siempre devolver el nombre y el ID en el mismo formato
    if [[ -n "$name" ]]; then
        echo "$name ($vmid)"
    else
        echo "$vmid"
    fi
}

# Función para configurar notificaciones
configure_notifications() {
    # Ordenar las opciones por categoría y descripción
    IFS=$'\n' sorted_options=($(for option in "${options[@]}"; do
        IFS='|' read -r category description var_name <<< "$option"
        printf "%s|%s|%s\n" "$category" "$description" "$var_name"
    done | sort -t'|' -k1,1 -k2,2))
    unset IFS

    # Crear un mapeo de índices a nombres de variables
    declare -A index_to_var
    index=1

    # Preparar las opciones para `whiptail`
    menu_items=()
    for option in "${sorted_options[@]}"; do
        IFS='|' read -r category description var_name <<< "$option"

        # Guardar el mapeo de índice a nombre de variable
        index_to_var["$index"]="$var_name"
        
        # Formatear descripción con espacios para alinear la categoría a la derecha
        formatted_item="$description"
        current_length=${#formatted_item}
        spaces_needed=$((50 - current_length))

        for ((j = 0; j < spaces_needed; j++)); do
            formatted_item+=" "
        done

        formatted_item+="$category"

        # Marcar como ON u OFF según la configuración guardada
        state="OFF"
        [[ "$(eval echo \$$var_name)" -eq 1 ]] && state="ON"

        menu_items+=("$index" "$formatted_item" "$state")
        ((index++))
    done

    # Mostrar menú `whiptail`
    selected_indices=$(whiptail --title "$(translate "Configuración de Notificaciones a Telegram")" \
                            --checklist --separate-output \
                            "\n$(translate "Selecciona los eventos que deseas recibir:")\n" \
                            30 100 20 \
                            "${menu_items[@]}" \
                            3>&1 1>&2 2>&3)
    
    local result=$?

    # Si se ha seleccionado alguna opción, actualizar configuración
    if [[ $result -eq 0 ]]; then
        # Hacer una copia de seguridad del archivo de configuración
        cp "$CONFIG_FILE" "${CONFIG_FILE}.bak" 2>/dev/null
        
        # Establecer todas las opciones en OFF
        for var_name in "${index_to_var[@]}"; do
            sed -i "s/^$var_name=.*/$var_name=0/" "$CONFIG_FILE"
        done

        # Activar las opciones seleccionadas
        for selected_index in $selected_indices; do
            var_name="${index_to_var[$selected_index]}"
            sed -i "s/^$var_name=.*/$var_name=1/" "$CONFIG_FILE"
        done

        # Recargar la configuración
        source "$CONFIG_FILE"

        whiptail --title "$(translate "Éxito")" \
                 --msgbox "$(translate "Configuración actualizada correctamente.")" 10 70
    fi
}

# Función: captura eventos desde journalctl
capture_journal_events() {
    # Usar un archivo para almacenar eventos ya procesados
    local processed_events_file="$PID_DIR/processed_events"
    
    # Crear directorio si no existe
    mkdir -p "$PID_DIR" 2>/dev/null
    
    # Crear el archivo si no existe
    if [[ ! -f "$processed_events_file" ]]; then
        touch "$processed_events_file"
    fi
    
    # Monitorear continuamente el log
    while true; do
        # Usar tail para el archivo de tareas de Proxmox
        tail -F /var/log/pve/tasks/index 2>/dev/null | while read -r line; do
            # Crear un identificador único para este evento
            event_id=$(echo "$line" | md5sum | cut -d' ' -f1)
            
            # Verificar si ya procesamos este evento
            if grep -q "$event_id" "$processed_events_file" 2>/dev/null; then
                continue
            fi
            
            # Añadir el ID al archivo de eventos procesados
            echo "$event_id" >> "$processed_events_file"
            
            # Limitar el tamaño del archivo de eventos procesados
            tail -n 1000 "$processed_events_file" > "${processed_events_file}.tmp" 2>/dev/null && mv "${processed_events_file}.tmp" "$processed_events_file" 2>/dev/null
            
            # Variable para controlar si el evento ya fue procesado por algún patrón
            local event_processed=false
            
            # ===== EVENTOS CRÍTICOS (INMEDIATOS) =====
            
            # Error al iniciar VM (CRÍTICO)
            if [[ "$line" =~ "Failed to start VM" ]] && [[ "$vm_fail" -eq 1 ]] && [[ "$event_processed" = false ]]; then
                VM_ID=$(echo "$line" | grep -oP 'VM \K[0-9]+')
                NAME=$(get_vm_name "$VM_ID")
                send_notification "🚨 $(translate "CRÍTICO: Error al iniciar la VM:") $NAME"
                event_processed=true
            fi
            
            # Errores de I/O de disco (CRÍTICO)
            if [[ "$disk_io_error" -eq 1 ]] && [[ "$event_processed" = false ]]; then
                if [[ "$line" =~ "I/O error" || "$line" =~ "read error" || "$line" =~ "write error" || "$line" =~ "blk_update_request" || "$line" =~ "buffer I/O error" ]]; then
                    DISK=$(echo "$line" | grep -oE "/dev/[a-zA-Z0-9]+" || echo "desconocido")
                    send_notification "🚨 $(translate "CRÍTICO: Error de lectura/escritura en disco:") $DISK"
                    event_processed=true
                fi
            fi
            
            # Fallo de disco (CRÍTICO)
            if [[ "$disk_fail" -eq 1 ]] && [[ "$line" =~ "disk failure" ]] && [[ "$event_processed" = false ]]; then
                DISK=$(echo "$line" | grep -oE "/dev/[a-zA-Z0-9]+" || echo "desconocido")
                send_notification "🚨 $(translate "CRÍTICO: Fallo de disco detectado:") $DISK"
                event_processed=true
            fi
            
            # Snapshot fallido (CRÍTICO)
            if [[ "$line" =~ "snapshot" ]] && [[ "$snapshot_fail" -eq 1 ]] && [[ "$line" =~ "error" ]] && [[ "$event_processed" = false ]]; then
                VM_ID=$(echo "$line" | grep -oP 'TASK \K[0-9]+' || echo "")
                if [[ -n "$VM_ID" ]]; then
                    NAME=$(get_vm_name "$VM_ID")
                    send_notification "🚨 $(translate "CRÍTICO: Snapshot fallido para:") $NAME"
                else
                    send_notification "🚨 $(translate "CRÍTICO: Snapshot fallido")"
                fi
                event_processed=true
            fi
            
            # Backup fallido (CRÍTICO)
            if [[ "$line" =~ "backup" ]] && [[ "$backup_fail" -eq 1 ]] && [[ "$line" =~ "error" ]] && [[ "$event_processed" = false ]]; then
                VM_ID=$(echo "$line" | grep -oP 'TASK \K[0-9]+' || echo "")
                if [[ -n "$VM_ID" ]]; then
                    NAME=$(get_vm_name "$VM_ID")
                    send_notification "🚨 $(translate "CRÍTICO: Backup fallido para:") $NAME"
                else
                    send_notification "🚨 $(translate "CRÍTICO: Backup fallido")"
                fi
                event_processed=true
            fi
            
            # Intento de autenticación fallido (CRÍTICO)
            if [[ "$line" =~ "authentication failure" ]] && [[ "$auth_fail" -eq 1 ]] && [[ "$event_processed" = false ]]; then
                USER=$(echo "$line" | grep -oP 'user=\K[^ ]+' || echo "desconocido")
                IP=$(echo "$line" | grep -oP 'rhost=\K[^ ]+' || echo "desconocida")
                send_notification "🚨 $(translate "CRÍTICO: Intento de autenticación fallido:") $USER desde $IP"
                event_processed=true
            fi
            
            # Problema con el firewall (CRÍTICO)
            if [[ "$line" =~ "firewall" ]] && [[ "$firewall_issue" -eq 1 ]] && [[ "$line" =~ "error|block|reject" ]] && [[ "$event_processed" = false ]]; then
                send_notification "🚨 $(translate "CRÍTICO: Problema con el firewall:") $line"
                event_processed=true
            fi
            
            # Interfaz de red caída (CRÍTICO)
            if [[ "$line" =~ "network" ]] && [[ "$network_down" -eq 1 ]] && [[ "$line" =~ "down" ]] && [[ "$event_processed" = false ]]; then
                IFACE=$(echo "$line" | grep -oP 'interface \K[^ ]+' || echo "desconocida")
                send_notification "🚨 $(translate "CRÍTICO: Interfaz de red caída:") $IFACE"
                event_processed=true
            fi
            
            # Split-brain detectado (CRÍTICO)
            if [[ "$line" =~ "Split-Brain" ]] && [[ "$split_brain" -eq 1 ]] && [[ "$event_processed" = false ]]; then
                send_notification "🚨 $(translate "CRÍTICO: Split-brain detectado en el clúster")"
                event_processed=true
            fi
            
            # Nodo desconectado del clúster (CRÍTICO)
            if [[ "$line" =~ "quorum" ]] && [[ "$node_disconnect" -eq 1 ]] && [[ "$line" =~ "lost" ]] && [[ "$event_processed" = false ]]; then
                NODE=$(echo "$line" | grep -oP 'node \K[^ ]+' || echo "desconocido")
                send_notification "🚨 $(translate "CRÍTICO: Nodo desconectado del clúster:") $NODE"
                event_processed=true
            fi
            
            # Kernel panic (CRÍTICO)
            if [[ "$line" =~ "kernel panic" ]] && [[ "$kernel_panic" -eq 1 ]] && [[ "$event_processed" = false ]]; then
                send_notification "🚨 $(translate "CRÍTICO: Kernel panic detectado")"
                event_processed=true
            fi
            
            # ===== EVENTOS NO CRÍTICOS (INMEDIATOS) =====
            
            # Inicio de VM (NO CRÍTICO pero inmediato)
            if [[ "$line" =~ "qmstart" ]] && [[ "$vm_start" -eq 1 ]] && [[ "$event_processed" = false ]]; then
                VM_ID=$(echo "$line" | grep -oP 'qmstart:\K[0-9]+')
                NAME=$(get_vm_name "$VM_ID")
                send_notification "✅ $(translate "VM comenzó con éxito:") $NAME"
                event_processed=true
            fi
            
            # Apagado de VM (NO CRÍTICO pero inmediato)
            if [[ "$line" =~ "qmstop" ]] && [[ "$vm_shutdown" -eq 1 ]] && [[ "$event_processed" = false ]]; then
                VM_ID=$(echo "$line" | grep -oP 'qmstop:\K[0-9]+')
                NAME=$(get_vm_name "$VM_ID")
                send_notification "✅ $(translate "VM se detuvo con éxito:") $NAME"
                event_processed=true
            fi
            
            # Reinicio de VM (NO CRÍTICO pero inmediato)
            if [[ "$line" =~ "qmreset" || "$line" =~ "qmreboot" ]] && [[ "$vm_restart" -eq 1 ]] && [[ "$event_processed" = false ]]; then
                VM_ID=$(echo "$line" | grep -oP '(qmreset|qmreboot):\K[0-9]+')
                NAME=$(get_vm_name "$VM_ID")
                send_notification "✅ $(translate "VM reinició con éxito:") $NAME"
                event_processed=true
            fi
            
            # Snapshot completado (NO CRÍTICO pero inmediato)
            if [[ "$line" =~ "snapshot" ]] && [[ "$snapshot_complete" -eq 1 ]] && [[ ! "$line" =~ "error" ]] && [[ "$event_processed" = false ]]; then
                VM_ID=$(echo "$line" | grep -oP 'TASK \K[0-9]+' || echo "")
                if [[ -n "$VM_ID" ]]; then
                    NAME=$(get_vm_name "$VM_ID")
                    send_notification "✅ $(translate "Snapshot completado para:") $NAME"
                else
                    send_notification "✅ $(translate "Snapshot completado")"
                fi
                event_processed=true
            fi
            
            # Backup completado (NO CRÍTICO pero inmediato)
            if [[ "$line" =~ "backup" ]] && [[ "$backup_complete" -eq 1 ]] && [[ "$line" =~ "successful" ]] && [[ "$event_processed" = false ]]; then
                VM_ID=$(echo "$line" | grep -oP 'TASK \K[0-9]+' || echo "")
                if [[ -n "$VM_ID" ]]; then
                    NAME=$(get_vm_name "$VM_ID")
                    send_notification "✅ $(translate "Backup completado para:") $NAME"
                else
                    send_notification "✅ $(translate "Backup completado")"
                fi
                event_processed=true
            fi
            
            # Actualización completada (NO CRÍTICO pero inmediato)
            if [[ "$line" =~ "update" ]] && [[ "$update_complete" -eq 1 ]] && [[ "$line" =~ "complete" ]] && [[ "$event_processed" = false ]]; then
                send_notification "✅ $(translate "Actualización del sistema completada")"
                event_processed=true
            fi
        done

        # Si llegamos aquí, es porque tail -F terminó inesperadamente
        sleep 5
    done
}

# Función: captura eventos directos del sistema
capture_direct_events() {
    # Variables para controlar la frecuencia de las notificaciones
    local last_load_notification=0
    local last_temp_notification=0
    local last_disk_space_notification=0
    local last_cpu_notification=0
    local last_ram_notification=0
    local last_update_notification=0
    
    # Tiempo mínimo entre notificaciones repetitivas (en segundos)
    local resource_interval=900  # 15 minutos para recursos
    local update_interval=86400  # 24 horas para actualizaciones
    
    # Variables para eventos CRÍTICOS (sin intervalo)
    local disk_full_detected=false
    
    while true; do
        current_time=$(date +%s)
        
        # ===== EVENTOS CRÍTICOS (INMEDIATOS) =====
        
        # Disco lleno (CRÍTICO - inmediato)
        if [[ "$disk_full" -eq 1 ]]; then
            full_disks=$(df -h | awk '$5 == "100%" {print $1 " (100% lleno)"}')
            if [[ -n "$full_disks" && "$disk_full_detected" = false ]]; then
                send_notification "🚨 $(translate "CRÍTICO: Almacenamiento completamente lleno:") $full_disks"
                disk_full_detected=true
            elif [[ -z "$full_disks" ]]; then
                disk_full_detected=false
            fi
        fi
        
        # ===== EVENTOS NO CRÍTICOS (CON INTERVALO) =====
        
        # Carga alta del sistema (NO CRÍTICO - con intervalo)
        if [[ "$system_load_high" -eq 1 ]]; then
            load=$(awk '{print $1}' /proc/loadavg)
            if (( $(echo "$load > 5.00" | bc -l) )) && (( current_time - last_load_notification > resource_interval )); then
                send_notification "⚠️ $(translate "Carga alta del sistema detectada:") $load"
                last_load_notification=$current_time
            fi
        fi

        # Actualizaciones disponibles (NO CRÍTICO - con intervalo diario)
        if [[ "$update_available" -eq 1 ]] && (( current_time - last_update_notification > update_interval )); then
            if command -v apt-get &>/dev/null; then
                apt-get update -qq &>/dev/null
                updates=$(apt list --upgradable 2>/dev/null | grep -v "Listing..." | wc -l)
                if [[ $updates -gt 0 ]]; then
                    send_notification "ℹ️ $(translate "Actualizaciones disponibles:") $updates"
                    last_update_notification=$current_time
                fi
            fi
        fi

        # Espacio en disco bajo (NO CRÍTICO - con intervalo)
        if [[ "$low_disk_space" -eq 1 ]] && (( current_time - last_disk_space_notification > resource_interval )); then
            # Comprobar particiones con más del 90% pero menos del 100% de uso
            low_space=$(df -h | awk '$5 ~ /9[0-9]%/ && $5 != "100%" {print $1 " (" $5 " lleno)"}')
            if [[ -n "$low_space" ]]; then
                send_notification "⚠️ $(translate "Espacio en disco bajo:") $low_space"
                last_disk_space_notification=$current_time
            fi
        fi

        # Uso alto de CPU (NO CRÍTICO - con intervalo)
        if [[ "$cpu_high" -eq 1 ]] && (( current_time - last_cpu_notification > resource_interval )); then
            # Usar mpstat si está disponible, si no, usar top
            if command -v mpstat &>/dev/null; then
                cpu_usage=$(mpstat 1 1 | awk '/Average:/ {print 100 - $NF}')
            else
                cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
            fi
            
            if (( $(echo "$cpu_usage > 90" | bc -l) )); then
                send_notification "⚠️ $(translate "Uso alto de CPU:") $cpu_usage%"
                last_cpu_notification=$current_time
            fi
        fi

        # Uso alto de RAM (NO CRÍTICO - con intervalo)
        if [[ "$ram_high" -eq 1 ]] && (( current_time - last_ram_notification > resource_interval )); then
            ram_usage=$(free | awk '/Mem:/ {printf "%.2f", $3/$2 * 100}')
            if (( $(echo "$ram_usage > 90" | bc -l) )); then
                send_notification "⚠️ $(translate "Uso alto de RAM:") $ram_usage%"
                last_ram_notification=$current_time
            fi
        fi

        # Temperatura alta (NO CRÍTICO - con intervalo)
        if [[ "$temp_high" -eq 1 ]] && (( current_time - last_temp_notification > resource_interval )); then
            if command -v sensors &>/dev/null; then
                # Intentar diferentes patrones para detectar la temperatura
                temp=$(sensors | grep -E 'Package id 0:|Core 0:|CPU:' | head -1 | grep -oP '\+\d+\.\d+°C' | grep -oP '\d+\.\d+' || echo "0")
                
                if [[ -n "$temp" && "$temp" != "0" ]] && (( $(echo "$temp > 80" | bc -l) )); then
                    send_notification "⚠️ $(translate "Temperatura alta del sistema:") $temp°C"
                    last_temp_notification=$current_time
                fi
            fi
        fi

        # Pausa entre comprobaciones
        sleep 30
    done
}

# Función para configurar Telegram
configure_telegram() {
    # Cargar configuración existente (si existe)
    [[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

    # Solicitar BOT_TOKEN
    BOT_TOKEN=$(whiptail --title "$(translate "Configuración de Telegram")" \
                         --inputbox "$(translate "Introduce tu Token de Bot de Telegram:")" 10 70 "$BOT_TOKEN" 3>&1 1>&2 2>&3)

    if [[ $? -ne 0 ]]; then
        return
    fi

    # Solicitar CHAT_ID
    CHAT_ID=$(whiptail --title "$(translate "Configuración de Telegram")" \
                       --inputbox "$(translate "Introduce tu ID de Chat de Telegram:")" 10 70 "$CHAT_ID" 3>&1 1>&2 2>&3)

    if [[ $? -ne 0 ]]; then
        return
    fi

    # Guardar configuración en archivo
    if [[ -n "$BOT_TOKEN" && -n "$CHAT_ID" ]]; then
        # Hacer una copia de seguridad del archivo de configuración
        cp "$CONFIG_FILE" "${CONFIG_FILE}.bak" 2>/dev/null
        
        # Verificar si las variables ya existen en el archivo
        if grep -q "^BOT_TOKEN=" "$CONFIG_FILE"; then
            sed -i "s/^BOT_TOKEN=.*/BOT_TOKEN=\"$BOT_TOKEN\"/" "$CONFIG_FILE"
        else
            echo "BOT_TOKEN=\"$BOT_TOKEN\"" >> "$CONFIG_FILE"
        fi
        
        if grep -q "^CHAT_ID=" "$CONFIG_FILE"; then
            sed -i "s/^CHAT_ID=.*/CHAT_ID=\"$CHAT_ID\"/" "$CONFIG_FILE"
        else
            echo "CHAT_ID=\"$CHAT_ID\"" >> "$CONFIG_FILE"
        fi
        
        # Recargar la configuración
        source "$CONFIG_FILE"
        
        # Probar la configuración inmediatamente
        response=$(curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
            -d "chat_id=$CHAT_ID" \
            -d "text=$(translate "¡Telegram está funcionando correctamente!")")

        if [[ "$response" =~ "ok\":true" ]]; then
            whiptail --title "$(translate "Éxito")" \
                     --msgbox "$(translate "Configuración de Telegram válida. Las notificaciones serán enviadas.")" 10 70
        else
            whiptail --title "$(translate "Error")" \
                     --msgbox "$(translate "Configuración de Telegram inválida. Por favor, verifica el token y el ID de chat.")" 10 70
        fi
    else
        whiptail --title "$(translate "Error")" \
                 --msgbox "$(translate "Configuración de Telegram incompleta. Por favor, proporciona tanto el token como el ID de chat.")" 10 70
    fi
}







# Función para iniciar el servicio de notificaciones
start_notification_service() {
    if [[ ! -f /etc/systemd/system/proxmox-telegram.service ]]; then
        install_systemd_service
    fi

    if systemctl is-active --quiet proxmox-telegram.service; then
        whiptail --title "$(translate "Información")" \
                 --msgbox "$(translate "El servicio de notificaciones ya está en ejecución.")" 10 70
    else
        systemctl start proxmox-telegram.service
        if systemctl is-active --quiet proxmox-telegram.service; then
            whiptail --title "$(translate "Iniciado")" \
                     --msgbox "$(translate "El servicio se ha iniciado correctamente.")" 10 70
        else
            whiptail --title "$(translate "Error")" \
                     --msgbox "$(translate "No se pudo iniciar el servicio de notificaciones.")" 10 70
        fi
    fi
}

# Función para detener el servicio
stop_notification_service() {
    if [[ -f /etc/systemd/system/proxmox-telegram.service ]]; then
        if systemctl is-active --quiet proxmox-telegram.service; then
            systemctl stop proxmox-telegram.service
            sleep 2
        fi

        if ! systemctl is-active --quiet proxmox-telegram.service; then
            whiptail --title "$(translate "Detenido")" \
                     --msgbox "$(translate "El servicio ha sido detenido correctamente.")" 10 70
        else
            whiptail --title "$(translate "Error")" \
                     --msgbox "$(translate "No se pudo detener el servicio de notificaciones.")" 10 70
        fi
    else
        whiptail --title "$(translate "Información")" \
                 --msgbox "$(translate "El servicio de notificaciones no está instalado aún.")" 10 70
    fi
}

# Función para verificar el estado del servicio
check_service_status() {
    clear
    if [[ -f /etc/systemd/system/proxmox-telegram.service ]]; then
        systemctl status proxmox-telegram.service
    else
        echo "$(translate "El servicio no está instalado.")"
    fi
    echo
    echo "$(translate "Pulsa Enter para volver al menú...")"
    read -r
}

# Función para eliminar el servicio systemd
remove_systemd_service() {
    if [[ -f /etc/systemd/system/proxmox-telegram.service ]]; then
        if systemctl is-active --quiet proxmox-telegram.service; then
            systemctl stop proxmox-telegram.service
        fi
        systemctl disable proxmox-telegram.service
        rm -f /etc/systemd/system/proxmox-telegram.service
        systemctl daemon-reexec
        whiptail --title "$(translate "Eliminado")" \
                 --msgbox "$(translate "El servicio ha sido eliminado correctamente. Puedes reinstalarlo desde el menú si lo deseas.")" 10 70
    else
        whiptail --title "$(translate "Información")" \
                 --msgbox "$(translate "El servicio no existe, no se requiere eliminar nada.")" 10 70
    fi
}






# Función para instalar el servicio como un servicio systemd
install_systemd_service() {
    mkdir -p "$PID_DIR"

    cat > /etc/systemd/system/proxmox-telegram.service <<EOF
[Unit]
Description=Proxmox Telegram Notification Service
After=network.target pve-cluster.service

[Service]
Type=simple
ExecStart=/bin/bash -c 'bash <(curl -fsSL https://raw.githubusercontent.com/MacRimi/ProxMenux/main/scripts/telegram-notifier.sh) start_silent'
ExecStop=/bin/bash -c 'bash <(curl -fsSL https://raw.githubusercontent.com/MacRimi/ProxMenux/main/scripts/telegram-notifier.sh) stop_silent'
Restart=on-failure
PIDFile=$PID_DIR/service.pid

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reexec
    systemctl enable proxmox-telegram.service
    systemctl start proxmox-telegram.service
}

# Menú principal
main_menu() {
    local extra_option=""
    if [[ -f /etc/systemd/system/proxmox-telegram.service ]]; then
        extra_option="8 \"\$(translate \"Eliminar Servicio de Notificaciones\")\""
    fi

    while true; do
        OPTION=$(eval whiptail --title "\"\$(translate \"Configuración de Notificaciones de Proxmox\")\"" \
            --menu "\"\$(translate \"Elige una opción:\")\"" 20 70 10 \
            "1" "\"\$(translate \"Configurar Telegram\")\"" \
            "2" "\"\$(translate \"Configurar Notificaciones\")\"" \
            "3" "\"\$(translate \"Iniciar Servicio de Notificaciones\")\"" \
            "4" "\"\$(translate \"Detener Servicio de Notificaciones\")\"" \
            "5" "\"\$(translate \"Verificar Estado del Servicio\")\"" \
            "7" "\"\$(translate \"Salir\")\"" \
            $extra_option 3>&1 1>&2 2>&3)

        if [[ $? -ne 0 ]]; then exit 0; fi

        case "$OPTION" in
            1) configure_telegram ;;
            2) configure_notifications ;;
            3) start_notification_service ;;
            4) stop_notification_service ;;
            5) check_service_status ;;
            7) exit 0 ;;
            8) remove_systemd_service ;;
        esac
    done
}

case "$1" in
  start_silent) start_silent ;;
  stop_silent) stop_silent ;;
  *) main_menu ;;
esac
