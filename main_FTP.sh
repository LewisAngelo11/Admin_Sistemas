#!/bin/bash

instalar_ftp

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
            read -p "Ingrese el usuario: " USER
            read -p "Ingrese el nuevo grupo: " GROUP
            sudo usermod -g "$GROUP" "$USER"
            echo "El usuario $USER ha sido cambiado al grupo $GROUP."
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
