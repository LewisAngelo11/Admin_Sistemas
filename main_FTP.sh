#!/bin/bash

source Funciones_FTP.sh

instalar_ftp
allow_ftp_port
config_vsftpd
create_groups
setup_anonymous_access

OPCION=-1  # Inicializa la variable para evitar errores

while [ "$OPCION" -ne 0 ]; do
    echo "¿Qué operación desea realizar?"
    echo "1. Crear un nuevo usuario."
    echo "2. Cambiar de grupo."
    echo "0. Salir."
    read -p "Elija una opción: " OPCION

    case "$OPCION" in
        1)  # Opción 1: Crear un usuario
            read -p "Ingrese el usuario: " USER
            read -p "Ingrese la contraseña: " PASSW

            while true; do
                read -p "Asignele un grupo al usuario creado (reprobados/recursadores): " GROUP

                if [ "$GROUP" = "reprobados" ] || [ "$GROUP" = "recursadores" ]; then
                    create_user "$USER" "$PASSW" "$GROUP"
                    break  # Salir del bucle si el grupo es válido
                else
                    echo "Grupo no válido. Debe ser 'reprobados' o 'recursadores'."
                fi
            done
            ;;
        
        2)  # Opción 2: Cambiar de grupo
            echo "Cambiando de grupo"
            user_group_info=$(get_user_and_group) # Capturar la salida de la función
            username=$(echo "$user_group_info" | awk '{print $1}') # Extrae el usuario
            new_group=$(echo "$user_group_info" | awk '{print $2}') # Extrae el grupo al que se cambiará

            change_user_group "$username" "$new_group"
            ;;
        0)  # Salir
            echo "Saliendo..."
            exit 0
            ;;
        *)  # Manejo de opciones inválidas
            echo "Opción no válida. Intente nuevamente."
            ;;
    esac
done
