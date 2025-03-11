#!/bin/bash

source Funciones_HTTP.sh

OPCION=-1  # Inicializa la variable para evitar errores

while [ "$OPCION" -ne 0 ]; do
    echo "¿Qué servicio desea instalar?"
    echo "1. Apache"
    echo "2. Tomcat (No disponible)"
    echo "3. Nginx"
    echo "0. Salir."
    read -p "Elija una opción: " OPCION

    case "$OPCION" in
        1)
            downloadsApache="https://downloads.apache.org/httpd/"
            page_apache=$(get_html "$downloadsApache")
            all_versions=$(get_all_apache_versions "$downloadsApache")
            last_lts_version=$(get_last_lts_apache_version "$downloadsApache")
            clean_version=$(remove_tar_gz_suffix "$last_lts_version")
            echo "Versiones: $all_versions"
            echo "Versiones LTS: $all_lts_versions"
            echo "Version LTS mas recente: $last_lts_version"

            echo "¿Que versión de apache desea instalar"
            echo "1. Última versión LTS $last_lts_version"
            echo "2. Versión de desarrollo (No tiene)"
            echo "0. Salir"
            read -p "Eliga una opción: " OPCION_APACHE

            case "$OPCION_APACHE" in
                "1")
                    read -p "Ingrese el puerto en el que se instalará Apache: " PORT
                    
                    if ss -tuln | grep -q ":$PORT "; then
                        echo "El puerto $PORT esta en uso. Eliga otro."
                    else 
                        instalar_servidor_http "$downloadsApache" "$last_lts_version" "$clean_version" "apache2"
                        # Verificar la instalacón
                        /usr/local/apache2/bin/httpd -v
                        # Ruta de la configuración del archivo
                        routeFileConfiguration="/usr/local/apache2/conf/httpd.conf"
                        # Remover el puerto en uso actual
                        sudo sed -i '/^Listen/d' $routeFileConfiguration
                        # Añadir puerto que eligio el usuario
                        sudo printf "Listen $PORT" >> $routeFileConfiguration
                        # Comprobar si el puerto esta escuchando
                        sudo grep -i "Listen $puerto" $routeFileConfiguration
                    fi
                    ;;
                "2")
                    echo "Apache no cuenta com versión de desarrollo."
                    ;;
                "0")
                    echo "Saliendo..."
                    break
                *)
                    echo "Opción inválida."
                    ;;
            esac
            ;;
        2)
            ;;
        3)
            echo "Instalar Nginx..."
            downloadsNginx="https://nginx.org/en/download.html"
            page_nginx=$(get_html "$downloadsNginx")
            all_versions=$(get_all_nginx_versions "$downloadsNginx")
            last_lts_version=$(get_last_lts_nginx_version "$downloadsNginx")
            clean_version=$(remove_tar_gz_suffix "$last_lts_version")
            echo "$page_nginx"
            echo "Versiones: $all_versions"
            echo "Ultima versión LTS: $last_lts_version"

            echo "¿Que versión de apache desea instalar"
            echo "1. Última versión LTS $last_lts_version"
            echo "2. Versión de desarrollo (No disponible)"
            echo "0. Salir"
            read -p "Eliga una opción: " OPCION_NGINX

            case "$OPCION_NGINX" in
                "1")
                    read -p "Ingrese el puerto en el que se instalará Apache: " PORT

                    if ss -tuln | grep -q ":$PORT "; then
                        echo "El puerto $PORT esta en uso. Eliga otro."
                    else
                        instalar_servidor_http "$downloadsNginx" "$last_lts_version" "$clean_version" "nginx"
                        # Verificar la instalación de Nginx
                        /usr/local/nginx/sbin/nginx -v
                        # Ruta de la configuración del archivo
                        routeFileConfiguration= "/usr/local/nginx/conf/nginx.conf"
                        # Modificar el puerto
                        sed -i -E "s/listen[[:space:]]{7}[0-9]{1,5}/listen $PORT./" "$routeFileConfiguration"
                        # Verificar si esta escuchando en el puerto
                        sudo grep -i "listen\s\s\s\s\s\s\s" "$routeFileConfiguration"
                    fi
                    ;;
                2)
                    echo "Instalando al versión de desarrollo de Nginx..."
                    ;;
                *)
                    ;;
            esac
            ;;
        0)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            ;;
    esac
done