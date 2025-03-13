#!/bin/bash

source Funciones_HTTP.sh

OPCION=-1  # Inicializa la variable para evitar errores
patron_versiones='[0-9]+\.[0-9]+\.[0-9]+'

while [ "$OPCION" -ne 0 ]; do
    echo "¿Qué servicio desea instalar?"
    echo "1. Apache."
    echo "2. Tomcat."
    echo "3. Nginx."
    echo "0. Salir."
    read -p "Elija una opción: " OPCION

    case "$OPCION" in
        1)
            downloadsApache="https://downloads.apache.org/httpd/"
            page_apache=$(get_html "$downloadsApache")
            mapfile -t versions < <(get_lts_version "$downloadsApache" 0)
            last_lts_version=${versions[0]}

            echo "¿Que versión de apache desea instalar"
            echo "1. Última versión LTS $last_lts_version"
            echo "2. Versión de desarrollo (No tiene)"
            echo "0. Salir"
            read -p "Eliga una opción: " OPCION_APACHE

            case "$OPCION_APACHE" in
                "1")
                    # Pedir el puerto al usuario
                    read -p "Ingrese el puerto en el que se instalará Apache: " PORT
                    # Verificar si el puerto esta disponible
                    if ss -tuln | grep -q ":$PORT "; then
                        echo "El puerto $PORT esta en uso. Eliga otro."
                    else
                        install_server_http "$downloadsApache" "httpd-$last_lts_version.tar.gz" "httpd-$last_lts_version" "apache2"
                        # Verificar la instalacón
                        /usr/local/apache2/bin/httpd -v
                        # Ruta de la configuración del archivo
                        routeFileConfiguration="/usr/local/apache2/conf/httpd.conf"
                        # Remover el puerto en uso actual
                        sudo sed -i '/^Listen/d' $routeFileConfiguration
                        # Añadir puerto que eligio el usuario
                        sudo printf "Listen $PORT" >> $routeFileConfiguration
                        # Comprobar si el puerto esta escuchando
                        sudo grep -i "Listen $PORT" $routeFileConfiguration
                    fi
                    ;;
                "2")
                    echo "Apache no cuenta com versión de desarrollo."
                    ;;
                "0")
                    echo "Saliendo al menú principal..."
                    ;;
                *)
                    echo "Opción inválida."
                    ;;
            esac
            ;;
        2)
            echo "Instalar Tomcat..."
            downloadsTomcat="https://tomcat.apache.org/index.html"
            dev_version=$(get_lts_version "$downloadsTomcat" 0)
            last_lts_version=$(get_lts_version "$downloadsTomcat" 1)

            echo "¿Que versión de Tomcat desea instalar"
            echo "1. Última versión LTS $last_lts_version"
            echo "2. Versión de desarrollo $dev_version"
            echo "0. Salir"
            read -p "Eliga una opción: " OPCION_TOMCAT

            case "$OPCION_TOMCAT" in
                "1")
                    fisrt_digit=$(get_first_digit 0 "$last_lts_version")
                    read -p "Ingrese el puerto en el que se instalará Nginx: " PORT

                    if ss -tuln | grep -q ":$PORT "; then
                        echo "El puerto $PORT esta en uso. Eliga otro."
                    else
                        # Instalar Java ya que Tomcat lo requiere
                        sudo apt update
                        sudo apt install default-jdk -y
                        java -version
                        curl -s -O "https://dlcdn.apache.org/tomcat/tomcat-$fisrt_digit/v$last_lts_version/bin/apache-tomcat-$last_lts_version.tar.gz"
                        tar -xzvf apache-tomcat-$last_lts_version.tar.gz
                        sudo mv apache-tomcat-$last_lts_version /opt/tomcat
                        # Modificar el puerto en server.xml
                        server_xml="/opt/tomcat/conf/server.xml"
                        sudo sed -i "s/port=\"8080\"/port=\"$PORT\"/g" "$server_xml"
                        # Otorgar permisos de ejecución
                        sudo chmod +x /opt/tomcat/bin/*.sh
                        # Iniciar Tomcat
                        /opt/tomcat/bin/startup.sh
                    fi
                    ;;
                "2")
                    fisrt_digit=$(get_first_digit 0 "$dev_version")
                    read -p "Ingrese el puerto en el que se instalará Nginx: " PORT

                    if ss -tuln | grep -q ":$PORT "; then
                        echo "El puerto $PORT esta en uso. Eliga otro."
                    else
                        # Instalar Java ya que Tomcat lo requiere
                        sudo apt update
                        sudo apt install default-jdk -y
                        java -version
                        curl -s -O "https://dlcdn.apache.org/tomcat/tomcat-$fisrt_digit/v$dev_version/bin/apache-tomcat-$dev_version.tar.gz"
                        tar -xzvf apache-tomcat-$dev_version.tar.gz
                        sudo mv apache-tomcat-$dev_version /opt/tomcat
                        # Modificar el puerto en server.xml
                        server_xml="/opt/tomcat/conf/server.xml"
                        sudo sed -i "s/port=\"8080\"/port=\"$PORT\"/g" "$server_xml"
                        # Otorgar permisos de ejecución
                        sudo chmod +x /opt/tomcat/bin/*.sh
                        # Iniciar Tomcat
                        /opt/tomcat/bin/startup.sh
                    fi
                    ;;
                "0")
                    echo "Saliendo al menú principal..."
                    ;;
                *)
                    echo "Opción no válida"
                    ;;
            esac
            ;;
        3)
            echo "Instalar Nginx..."
            downloadsNginx="https://nginx.org/en/download.html"
            dev_version=$(get_lts_version "$downloadsNginx" 0)
            last_lts_version=$(get_lts_version "$downloadsNginx" 1)

            echo "¿Que versión de Nginx desea instalar"
            echo "1. Última versión LTS $last_lts_version"
            echo "2. Versión de desarrollo $dev_version"
            echo "0. Salir"
            read -p "Eliga una opción: " OPCION_NGINX

            case "$OPCION_NGINX" in
                "1")
                    read -p "Ingrese el puerto en el que se instalará Nginx: " PORT

                    if ss -tuln | grep -q ":$PORT "; then
                        echo "El puerto $PORT esta en uso. Eliga otro."
                    else
                        install_server_http "https://nginx.org/download/" "nginx-$last_lts_version.tar.gz" "nginx-$last_lts_version" "nginx"
                        # Verificar la instalación de Nginx
                        /usr/local/nginx/sbin/nginx -v
                        # Ruta de la configuración del archivo
                        routeFileConfiguration="/usr/local/nginx/conf/nginx.conf"
                        # Modificar el puerto
                        sed -i -E "s/listen[[:space:]]{7}[0-9]{1,5}/listen      $PORT/" "$routeFileConfiguration"
                        # Verificar si esta escuchando en el puerto
                        sudo grep -i "listen[[:space:]]{7}" "$routeFileConfiguration"
                        sudo /usr/local/nginx/sbin/nginx
                        sudo /usr/local/nginx/sbin/nginx -s reload
                        ps aux | grep nginx
                    fi
                    ;;
                2)
                    echo "Instalando al versión de desarrollo de Nginx..."
                    read -p "Ingrese el puerto en el que se instalará Nginx: " PORT

                    if ss -tuln | grep -q ":$PORT "; then
                        echo "El puerto $PORT esta en uso. Eliga otro."
                    else
                        install_server_http "https://nginx.org/download/" "nginx-$dev_version.tar.gz" "nginx-$dev_version" "nginx"
                        # Verificar la instalación de Nginx
                        /usr/local/nginx/sbin/nginx -v
                        # Ruta de la configuración del archivo
                        routeFileConfiguration="/usr/local/nginx/conf/nginx.conf"
                        # Modificar el puerto
                        sed -i -E "s/listen[[:space:]]{7}[0-9]{1,5}/listen      $PORT/" "$routeFileConfiguration"
                        # Verificar si esta escuchando en el puerto
                        sudo grep -i "listen[[:space:]]{7}" "$routeFileConfiguration"
                        sudo /usr/local/nginx/sbin/nginx
                        sudo /usr/local/nginx/sbin/nginx -s reload
                        ps aux | grep nginx
                    fi
                    ;;
                "0")
                    echo "Saliendo al menú principal..."
                    ;;
                *)
                    echo "Opción no válida"
                    ;;
            esac
            ;;
        0)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción no válida."
            ;;
    esac
done