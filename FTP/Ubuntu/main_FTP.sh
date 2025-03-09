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
            if [[ ${#USER} -gt 20 ]]; then
                echo "El usuario es demasiado largo."
                continue
            elif [[ ${#USER} -lt 4 ]]; then
                echo "El nombre es demasiado corto."
                continue
            fi

            read -p "Ingrese la contraseña: " PASSW
            if [[ ${#PASSW} -gt 20 ]]; then
                echo "El contraseña es demasiado largo."
                continue
            elif [[ ${#PASSW} -lt 4 ]]; then
                echo "El contraseña es demasiado corto."
                continue
            fi

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
            read -p "Ingrese el usuario a cambiar: " USER
            if [[ ${#USER} -gt 20 ]]; then
                echo "El usuario es demasiado largo."
                continue
            elif [[ ${#USER} -lt 4 ]]; then
                echo "El nombre es demasiado corto."
                continue
            fi

            while true; do
                read -p "Asignele el nuevo grupo al usuario: " NEW_GROUP

                if [ "$GROUP" = "reprobados" ] || [ "$GROUP" = "recursadores" ]; then
                    change_user_group "$username" "$NEW_GROUP"
                    break  # Salir del bucle si el grupo es válido
                else
                    echo "Grupo no válido. Debe ser 'reprobados' o 'recursadores'."
                fi
            done
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
