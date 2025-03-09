#!/bin/bash

source Funciones_HTTP.sh

OPCION=-1  # Inicializa la variable para evitar errores

while [ "$OPCION" -ne 0 ]; do
    echo "¿Qué servicio desea instalar?"
    echo "1. Apache"
    echo "2. Tomcat"
    echo "3. Nginx"
    echo "0. Salir."
    read -p "Elija una opción: " OPCION

    case "$OPCION" in
        1)
            downloadsApache="https://httpd.apache.org/download.cgi"
            last_lts_version=$(get_last_lts_version "$downloadsApache")
            ;;
        2)
            ;;
        3)
            ;;
        0)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            ;;
    esac
done
