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
            downloadsApache="https://downloads.apache.org/httpd/"
            #page_apache=$(get_html "$downloadsApache")
            #all_versions=$(get_all_versions "$downloadsApache")
            #all_lts_versions=$(get_all_lts_versions "$downloadsApache")
            last_lts_version=$(get_last_lts_version "$downloadsApache")
            clean_version=$(remove_tar_gz_suffix "$last_lts_version")
            echo "Versiones: $all_versions"
            echo "Versiones LTS: $all_lts_versions"
            echo "Version LTS mas recente: $last_lts_version"

            echo "¿Que versión de apache desea instalar"
            echo "1. Última versión LTS "
            echo "2. Versión de desarrollo"
            echo "0. Salir"
            read -p "Eliga una opción: " OPCION_APACHE

            case "$OPCION_APACHE" in
                "1")
                    read -p "Ingrese el puerto en el que se instalará Apache: " PORT
                    
                    if ss -tuln | grep -q ":$PORT "; then
                        echo "El puerto $PORT esta en uso. Eliga otro."
                    else 
                        instalar_servidor_http "$downloadsApache" "$last_lts_version" "$clean_version" "apache"
                        # Verificar la instalacón
                        /usr/local/apache2/bin/httpd -v
                        # Ruta de la configuración del archivo
                        routeFileConfiguration="/usr/local/apache2/conf/httpd.conf"
                        # Remover el puerto en uso actual
                        sudo sed -i '/^Listen/d' $routeFileConfiguration
                        # Añadir puerto que eligio el usuario
                        sudo printf "Listen $PORT" >> $routeFileConfiguration
                        # Comprobar si el puerto esta escichando
                        sudo grep -i "Listen $puerto" $routeFileConfiguration
                    fi
                    ;;
                *)
                    echo "Saliendo..."
                    break
                    ;;
            esac
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