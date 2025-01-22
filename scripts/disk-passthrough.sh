#!/bin/bash

# set -e  # Detener el script en caso de error

# Configuración de traducción
BASE_DIR="/usr/local/share/proxmenux"
CACHE_FILE="$BASE_DIR/cache.json"
VENV_PATH="/opt/googletrans-env"  # Ruta del entorno virtual

# Detectar el idioma seleccionado en el menú principal
LANGUAGE=$(jq -r '.language' "$BASE_DIR/config.json" 2>/dev/null || echo "en")

# Crear directorios necesarios
mkdir -p "$BASE_DIR"

# Colores y estilos
YW="\033[33m"
YWB="\033[1;33m"
GN="\033[1;92m"
RD="\033[01;31m"
CL="\033[m"
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
TAB="    "

# Crear y mostrar spinner.
spinner() {
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local spin_i=0
  local interval=0.1
  printf "\e[?25l"

  local color="${YWB}"

  while true; do
    printf "\r ${color}%s${CL}" "${frames[spin_i]}"
    spin_i=$(( (spin_i + 1) % ${#frames[@]} ))
    sleep "$interval"
  done
}

# Mostrar mensaje spiner.
msg_info() {
  local msg="$1"
  echo -ne "${TAB}${YW}${HOLD}${msg}${HOLD}"
  spinner &
  SPINNER_PID=$!
}

# Mostrar mensaje de proceso realizado .
msg_ok() {
  if [ -n "$SPINNER_PID" ] && ps -p $SPINNER_PID > /dev/null; then kill $SPINNER_PID > /dev/null; fi
  printf "\e[?25h"
  local msg="$1"
  echo -e "${BFR}${CM}${GN}${msg}${CL}"
}

msg_error() { echo -e " ${RD}[ERROR] $1${CL}"; }

# Función de traducción
translate() {
    local text="$1"

    # Verificar y asegurar la estructura inicial del archivo de caché
    if [ ! -f "$CACHE_FILE" ] || ! jq -e . "$CACHE_FILE" > /dev/null 2>&1; then
        echo "{}" > "$CACHE_FILE"
    fi

    # Verificar traducciones en caché
    local cached_translation=$(jq -r --arg text "$text" --arg lang "$LANGUAGE" '.[$text][$lang]' "$CACHE_FILE")
    if [ "$cached_translation" != "null" ]; then
        echo "$cached_translation"
        return
    fi

    # Traducir usando googletrans
    if [ ! -d "$VENV_PATH" ]; then
        echo "$text"
        return
    fi

    source "$VENV_PATH/bin/activate"
    local translated
    translated=$(python -c "
from googletrans import Translator
translator = Translator()
try:
    print(translator.translate('$text', dest='$LANGUAGE').text)
except:
    print('$text')
" 2>/dev/null)
    deactivate

    # Verificar si la traducción se realizó correctamente
    if [ -z "$translated" ] || [ "$translated" == "$text" ]; then
        echo "$text"
        return
    fi

    # Guardar en caché con idioma destino
    local temp_cache=$(mktemp)
    jq --arg text "$text" --arg lang "$LANGUAGE" --arg translated "$translated" '
        if (.[$text] // null | type != "object") then
            .[$text] = {($lang): $translated}
        else
            .[$text][$lang] = $translated
        end
    ' "$CACHE_FILE" > "$temp_cache" && mv "$temp_cache" "$CACHE_FILE"

    echo "${translated:-$text}"
}

# Función para identificar el disco físico donde está instalado Proxmox
obtener_disco_fisico() {
    local ruta_lv=$1
    local nombre_pv
    nombre_pv=$(pvs --noheadings -o pv_name 2>/dev/null | grep -v "/dev/mapper" | head -n1 | tr -d ' ') || true
    if [ -z "$nombre_pv" ]; then
        echo "$(translate "No se pudo determinar el disco físico. ¿Está instalado LVM?")" >&2
        return 1
    fi
    echo "$nombre_pv" | sed 's/[0-9]*$//'
}

# Función para obtener información detallada del disco
get_disk_info() {
    local disk=$1
    lsblk -ndo NAME,MODEL,SIZE "$disk" | awk '{print $1 " " $2 " " $3}'
}

# Detectar la partición raíz y el disco físico asociado
dispositivo_raiz=$(findmnt -n -o SOURCE / 2>/dev/null) || { echo "$(translate "No se pudo determinar el dispositivo raíz.")" >&2; exit 1; }
if [[ $dispositivo_raiz == /dev/mapper/* ]]; then
    disco_fisico=$(obtener_disco_fisico "$dispositivo_raiz")
else
    disco_fisico=$(echo "$dispositivo_raiz" | sed 's/[0-9]*$//')
fi

if [ -z "$disco_fisico" ]; then
    echo "$(translate "No se pudo determinar el disco físico.")" >&2
    exit 1
fi

msg_ok "$(translate "Disco físico del sistema identificado"): $disco_fisico. $(translate "Este disco no se mostrará.")"

# Mostrar lista de VMs disponibles
VM_LIST=$(qm list | awk 'NR>1 {print $1, $2}')
if [ -z "$VM_LIST" ]; then
    whiptail --title "$(translate "Error")" --msgbox "$(translate "No hay VMs disponibles en el sistema.")" 8 40
    exit 1
fi

# Seleccionar VM
VMID=$(whiptail --title "$(translate "Seleccionar VM")" --menu "$(translate "Selecciona la VM a la que deseas añadir discos:")" 15 60 8 $VM_LIST 3>&1 1>&2 2>&3)

if [ -z "$VMID" ]; then
    whiptail --title "$(translate "Error")" --msgbox "$(translate "No se seleccionó ninguna VM.")" 8 40
    exit 1
fi

VMID=$(echo "$VMID" | tr -d '"')

# Verificar que VMID es un número
if ! [[ "$VMID" =~ ^[0-9]+$ ]]; then
    whiptail --title "$(translate "Error")" --msgbox "$(translate "El ID de VM seleccionado no es válido.")" 8 40
    exit 1
fi

clear
msg_ok "$(translate "VM seleccionada correctamente.")"

# Comprobar si la VM está encendida
VM_STATUS=$(qm status "$VMID" | awk '{print $2}')
if [ "$VM_STATUS" == "running" ]; then
    whiptail --title "$(translate "Advertencia")" --msgbox "$(translate "La VM está encendida. Apágala antes de añadir discos.")" 12 60
    exit 1
fi

msg_info "$(translate "Detectando discos disponibles...")"

# Detectar discos libres, excluyendo el disco del sistema y los ya asignados a la VM seleccionada
DISCOS_LIBRES=()
while read -r LINE; do
    DISCO=$(echo "$LINE" | awk '{print $1}')
    if [[ "/dev/$DISCO" != "$disco_fisico" ]] && ! qm config "$VMID" | grep -q "/dev/$DISCO"; then
        DESCRIPCION=$(echo "$LINE" | awk '{$1=""; print $0}' | xargs)
        DISCOS_LIBRES+=("/dev/$DISCO" "$DESCRIPCION" "OFF")
    fi
done < <(lsblk -d -n -e 7,11 -o NAME,MODEL,SIZE)

msg_ok "$(translate "Discos disponibles detectados.")"

if [ "${#DISCOS_LIBRES[@]}" -eq 0 ]; then
    whiptail --title "$(translate "Error")" --msgbox "$(translate "No hay discos disponibles para esta VM.")" 8 40
    clear
    exit 1
fi

# Calcular longitud máxima del contenido
MAX_WIDTH=$(printf "%s\n" "${DISCOS_LIBRES[@]}" | awk '{print length}' | sort -nr | head -n1)
TOTAL_WIDTH=$((MAX_WIDTH + 20)) # Añade margen adicional

# Establecer un ancho mínimo razonable
if [ $TOTAL_WIDTH -lt 70 ]; then
    TOTAL_WIDTH=70
fi

# Mostrar menú para seleccionar discos libres con el ancho calculado dinámicamente
SELECCIONADOS=$(whiptail --title "$(translate "Seleccionar Discos")" --checklist \
    "$(translate "Selecciona los discos que deseas añadir:")" 20 $TOTAL_WIDTH 10 "${DISCOS_LIBRES[@]}" 3>&1 1>&2 2>&3)

# Comprobar si se seleccionaron discos
if [ -z "$SELECCIONADOS" ]; then
    whiptail --title "$(translate "Error")" --msgbox "$(translate "No se seleccionaron discos.")" 10 $TOTAL_WIDTH
    clear
    exit 1
fi

msg_ok "$(translate "Discos seleccionados correctamente.")"

# Seleccionar tipo de interfaz una sola vez para todos los discos
INTERFAZ=$(whiptail --title "$(translate "Tipo de Interfaz")" --menu "$(translate "Selecciona el tipo de interfaz para todos los discos:")" 15 40 4 \
    "sata" "$(translate "Añadir como SATA")" \
    "scsi" "$(translate "Añadir como SCSI")" \
    "virtio" "$(translate "Añadir como VirtIO")" \
    "ide" "$(translate "Añadir como IDE")" 3>&1 1>&2 2>&3)

if [ -z "$INTERFAZ" ]; then
    whiptail --title "$(translate "Error")" --msgbox "$(translate "No se seleccionó un tipo de interfaz para los discos.")" 8 40
    clear
    exit 1
fi

msg_ok "$(translate "Tipo de interfaz seleccionado: $INTERFAZ")"

# Verificar discos seleccionados
DISCOS_ADDED=0
MENSAJES_ERROR=""
MENSAJES_EXITO=""

msg_info "$(translate "Procesando discos seleccionados...")"

for DISCO in $SELECCIONADOS; do
    DISCO=$(echo "$DISCO" | tr -d '"')
    DISCO_INFO=$(get_disk_info "$DISCO")

    # Verificar si el disco ya está asignado a otra VM
    ASIGNADO_A=""
    while read -r VM_ID VM_NAME; do
        if [[ "$VM_ID" =~ ^[0-9]+$ ]] && qm config "$VM_ID" | grep -q "$DISCO"; then
            ASIGNADO_A+="$VM_ID $VM_NAME\n"
        fi
    done < <(qm list | awk 'NR>1 {print $1, $2}')

    CONTINUAR=true
    if [ -n "$ASIGNADO_A" ]; then
        VMS_ENCENDIDAS=""
        while read -r VM_ID VM_NAME; do
            if [[ "$VM_ID" =~ ^[0-9]+$ ]] && [ "$(qm status "$VM_ID" | awk '{print $2}')" == "running" ]; then
                VMS_ENCENDIDAS+="$VM_ID $VM_NAME\n"
            fi
        done < <(echo -e "$ASIGNADO_A")

        if [ -n "$VMS_ENCENDIDAS" ]; then
            MENSAJES_ERROR+="$(translate "El disco") $DISCO_INFO $(translate "está en uso por la(s) VM(s) encendida(s):")\\n$VMS_ENCENDIDAS\\n\\n"
            CONTINUAR=false
        fi
    fi

    if $CONTINUAR; then
        INDEX=0
        while qm config "$VMID" | grep -q "${INTERFAZ}${INDEX}"; do
            ((INDEX++))
        done

        # Realizar la asignación
        RESULTADO=$(qm set "$VMID" -${INTERFAZ}${INDEX} "$DISCO" 2>&1)

        if [ $? -eq 0 ]; then
            MENSAJE="$(translate "El disco") $DISCO_INFO $(translate "se ha añadido correctamente a la VM") $VMID."
            if [ -n "$ASIGNADO_A" ]; then
                MENSAJE+="\n$(translate "ADVERTENCIA: Este disco también está asignado a la(s) VM(s):")\n$ASIGNADO_A"
                MENSAJE+="$(translate "Asegúrate de no encender simultáneamente las VMs que comparten este disco para evitar daños en los datos.")\n"
            fi
            MENSAJES_EXITO+="$MENSAJE\\n\\n"
            ((DISCOS_ADDED++))
        else
            MENSAJES_ERROR+="$(translate "No se pudo añadir el disco") $DISCO_INFO $(translate "a la VM") $VMID.\\n$(translate "Error:") $RESULTADO\\n\\n"
        fi
    fi
done

msg_ok "$(translate "Procesamiento de discos completado.")"

# Mostrar mensajes de éxito
if [ -n "$MENSAJES_EXITO" ]; then
    whiptail --title "$(translate "Operaciones Exitosas")" --scrolltext --msgbox "$MENSAJES_EXITO" 20 70
fi

# Mostrar mensajes de error o advertencia si los hay
if [ -n "$MENSAJES_ERROR" ]; then
    whiptail --title "$(translate "Advertencias y Errores")" --scrolltext --msgbox "$MENSAJES_ERROR" 20 70
fi

# Mensaje de operación completada
if [ $DISCOS_ADDED -gt 0 ]; then
    whiptail --title "$(translate "Operación Completada")" --msgbox "$(translate "Se añadieron $DISCOS_ADDED disco(s) correctamente a la VM") $VMID." 8 60
else
    whiptail --title "$(translate "Información")" --msgbox "$(translate "No se añadieron discos a la VM") $VMID." 8 60
fi

clear
