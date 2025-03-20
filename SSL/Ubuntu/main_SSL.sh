#!/bin/bash

source Funciones_SSL.sh
source Funciones_HTTP.sh

install_opnessl
config_vsftpd

OPCION=-1

while [ "$OPCION" -ne 0 ]; do
    echo "¿Donde desea instalar el servicio HTTP?"
    echo "1. Desde FTP."
    echo "2. Desde la Web."
    echo "0. Salir."
    read -p "Eliga una opción: " OPCION

    case "$OPCION" in
        # Opción de instalación por FTP
        1)
            read -p "¿Deseas usar una conexión segura (SSL) para FTP? (SI/NO) " OPCION_SSL

            case "$OPCION_SSL" in
                "SI")
                    # Conectarse a FTP con certificación SSL
                    echo "Conectandose al servidor FTPS..."
                ;;
                "NO")
                    # Conectarse a FTP sin certificación SSL
                    echo "Conectandose al servidor FTP..."
                ;;
                *)
                    echo "Opción inválida (SI/NO)"
                ;;
            esac
        ;;
        # Opción de instalación por la Web
        2)
            read -p "¿Deseas incluir SSL en la configuración del servicio HTTP? (SI/NO) " OPCION_SSL

            case "$OPCION_SSL" in
                "SI")
                    echo "Instalar el servicio HTTP con SSL..."
                    OPCION_HTTP=-1
                    while [ "$OPCION_HTTP" -ne 0 ]; do
                        echo "¿Qué servicio desea instalar?"
                        echo "1. Apache."
                        echo "2. Tomcat."
                        echo "3. Nginx."
                        echo "0. Salir."
                        read -p "Elija una opción: " OPCION_HTTP

                        case "$OPCION_HTTP" in
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
                                    1)
                                        # Pedir el puerto al usuario
                                        read -p "Ingrese el puerto en el que se instalará Apache: " PORT
                                        read -p "Ingrese el puerto HTTPS para SSL (recomendado 443): " HTTPS_PORT
                                        verificar_puerto_reservado -puerto $PORT
                                        verificar_puerto_reservado -puerto $HTTPS_PORT

                                        # Verificar si el puerto esta disponible
                                        if ss -tuln | grep -q ":$PORT "; then
                                            echo "El puerto $PORT esta en uso. Eliga otro."
                                        elif ss -tuln | grep -q ":$HTTPS_PORT "; then
                                            echo "El puerto $HTTPS_PORT esta ocupado en otro servicio."
                                        else
                                            install_server_http_ssl "$downloadsApache" "httpd-$last_lts_version.tar.gz" "httpd-$last_lts_version" "apache2"
                                            # Verificar la instalacón
                                            /usr/local/apache2/bin/httpd -v
                                            # Ruta de la configuración del archivo
                                            routeFileConfiguration="/usr/local/apache2"
                                            configure_ssl_apache "$routeFileConfiguration" "$PORT" "$HTTPS_PORT"
                                            sudo /usr/local/apache2/bin/apachectl restart
                                            echo "Configuracion lista"
                                        fi
                                    ;;
                                    2)
                                        echo "Apache no cuenta con versión de desarrollo."
                                    ;;
                                    0)
                                        echo "Saliendo al menú principal..."
                                    ;;
                                    *)
                                        echo "Opción no válida."
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
                                    1)
                                        fisrt_digit=$(get_first_digit 0 "$last_lts_version")
                                        read -p "Ingrese el puerto en el que se instalará Tomcat: " PORT
                                        read -p "Ingrese el puerto HTTPS para SSL (recomendado 8443):" HTTPS_PORT
                                        verificar_puerto_reservado -puerto $PORT
                                        verificar_puerto_reservado -puerto $HTTPS_PORT

                                        if ss -tuln | grep -q ":$PORT "; then
                                            echo "El puerto $PORT esta en uso. Eliga otro."
                                        elif ss -tuln | grep -q ":$HTTPS_PORT "; then
                                            echo "El puerto $HTTPS_PORT esta ocupado en otro servicio."
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
                                            sudo sed -i "s/port=\"8080\"/port=\"$HTTPS_PORT\"/g" "$server_xml"
                                            # Cambiar el conector SSL para usar el puerto HTTPS
                                            sudo sed -i "s/keystoreFile=\"\"/keystoreFile=\"\/opt\/tomcat\/conf\/keystore.jks\"/g" "$server_xml"
                                            sudo sed -i "s/keystorePass=\"\"/keystorePass=\"changeit\"/g" "$server_xml"
                                            # Otorgar permisos de ejecución
                                            sudo chmod +x /opt/tomcat/bin/*.sh
                                            # Iniciar Tomcat
                                            /opt/tomcat/bin/startup.sh
                                        fi
                                    ;;
                                    2)
                                        fisrt_digit=$(get_first_digit 0 "$dev_version")
                                        read -p "Ingrese el puerto en el que se instalará Tomcat: " PORT
                                        read -p "Ingrese el puerto HTTPS para SSL (recomendado 8443):" HTTPS_PORT
                                        verificar_puerto_reservado -puerto $PORT
                                        verificar_puerto_reservado -puerto $HTTPS_PORT

                                        if ss -tuln | grep -q ":$PORT "; then
                                            echo "El puerto $PORT esta en uso. Eliga otro."
                                        elif ss -tuln | grep -q ":$HTTPS_PORT "; then
                                            echo "El puerto $HTTPS_PORT esta ocupado en otro servicio."
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
                                            sudo sed -i "s/port=\"8080\"/port=\"$HTTPS_PORT\"/g" "$server_xml"
                                            # Cambiar el conector SSL para usar el puerto HTTPS
                                            sudo sed -i "s/keystoreFile=\"\"/keystoreFile=\"\/opt\/tomcat\/conf\/keystore.jks\"/g" "$server_xml"
                                            sudo sed -i "s/keystorePass=\"\"/keystorePass=\"changeit\"/g" "$server_xml"
                                            # Otorgar permisos de ejecución
                                            sudo chmod +x /opt/tomcat/bin/*.sh
                                            # Iniciar Tomcat
                                            /opt/tomcat/bin/startup.sh
                                        fi
                                    ;;
                                    0)
                                        echo "Saliendo..."
                                    ;;
                                    *)
                                        echo "Opción no válida."
                                    ;;
                                esac
                            ;;
                            3)
                                echo "Instalar Nginx"
                                downloadsNginx="https://nginx.org/en/download.html"
                                dev_version=$(get_lts_version "$downloadsNginx" 0)
                                last_lts_version=$(get_lts_version "$downloadsNginx" 1)

                                echo "¿Que versión de Nginx desea instalar"
                                echo "1. Última versión LTS $last_lts_version"
                                echo "2. Versión de desarrollo $dev_version"
                                echo "0. Salir"
                                read -p "Eliga una opción: " OPCION_NGINX

                                case "$OPCION_NGINX" in
                                    1)
                                        read -p "Ingrese el puerto en el que se instalará Nginx: " PORT
                                        read -p "Ingrese el puerto HTTPS para SSL (recomendado 443): " HTTPS_PORT
                                        verificar_puerto_reservado -puerto $PORT
                                        verificar_puerto_reservado -puerto $HTTPS_PORT

                                        if ss -tuln | grep -q ":$PORT "; then
                                            echo "El puerto $PORT esta en uso. Eliga otro."
                                        elif [[ $? -eq 0 ]]; then
                                            echo "El puerto $PORT esta ocupado en otro servicio."
                                        else
                                            install_server_http_ssl "https://nginx.org/download/" "nginx-$last_lts_version.tar.gz" "nginx-$last_lts_version" "nginx"
                                            # Verificar la instalación de Nginx
                                            /usr/local/nginx/sbin/nginx -v
                                            # Ruta de la configuración del archivo
                                            routeFileConfiguration="/usr/local/nginx"
                                            configure_ssl_nginx "$routeFileConfiguration" "$PORT" "$HTTPS_PORT"
                                            ps aux | grep nginx
                                        fi
                                    ;;
                                    2)
                                        read -p "Ingrese el puerto en el que se instalará Nginx: " PORT
                                        read -p "Ingrese el puerto HTTPS para SSL (recomendado 443): " HTTPS_PORT
                                        verificar_puerto_reservado -puerto $PORT
                                        verificar_puerto_reservado -puerto $HTTPS_PORT

                                        if ss -tuln | grep -q ":$PORT "; then
                                            echo "El puerto $PORT esta en uso. Eliga otro."
                                        elif [[ $? -eq 0 ]]; then
                                            echo "El puerto $PORT esta ocupado en otro servicio."
                                        else
                                            install_server_http_ssl "https://nginx.org/download/" "nginx-$dev_version.tar.gz" "nginx-$dev_version" "nginx"
                                            # Verificar la instalación de Nginx
                                            /usr/local/nginx/sbin/nginx -v
                                            # Ruta de la configuración del archivo
                                            routeFileConfiguration="/usr/local/nginx"
                                            configure_ssl_nginx "$routeFileConfiguration" "$PORT" "$HTTPS_PORT"
                                            ps aux | grep nginx
                                        fi
                                    ;;
                                    0)
                                        echo "Saliendo al menú..."
                                    ;;
                                    *)
                                        echo "Opción no válida."
                                    ;;
                                esac
                            ;;
                            0)
                                echo "Saliendo..."
                            ;;
                            *)
                                echo "Opción no válida."
                            ;;
                        esac
                    done
                ;;
                "NO")
                    OPCION_HTTP=-1
                    while [ "$OPCION_HTTP" -ne 0 ]; do
                        echo "¿Qué servicio desea instalar?"
                        echo "1. Apache."
                        echo "2. Tomcat."
                        echo "3. Nginx."
                        echo "0. Salir."
                        read -p "Elija una opción: " OPCION_HTTP

                        case "$OPCION_HTTP" in
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
                                    1)
                                        # Pedir el puerto al usuario
                                        read -p "Ingrese el puerto en el que se instalará Apache: " PORT
                                        verificar_puerto_reservado -puerto $PORT

                                        # Verificar si el puerto esta disponible
                                        if ss -tuln | grep -q ":$PORT "; then
                                            echo "El puerto $PORT esta en uso. Eliga otro."
                                        elif [[ $? -eq 0 ]]; then
                                            echo "El puerto $PORT esta ocupado en otro servicio."
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
                                            sudo /usr/local/apache2/bin/apachectl restart
                                        fi
                                    ;;
                                    2)
                                        echo "Apache no cuenta con versión de desarrollo."
                                    ;;
                                    0)
                                        echo "Saliendo al menú principal..."
                                    ;;
                                    *)
                                        echo "Opción no válida."
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
                                    1)
                                        fisrt_digit=$(get_first_digit 0 "$last_lts_version")
                                        read -p "Ingrese el puerto en el que se instalará Tomcat: " PORT
                                        verificar_puerto_reservado -puerto $PORT

                                        if ss -tuln | grep -q ":$PORT "; then
                                            echo "El puerto $PORT esta en uso. Eliga otro."
                                        elif [[ $? -eq 0 ]]; then
                                            echo "El puerto $PORT esta ocupado en otro servicio."
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
                                    2)
                                        fisrt_digit=$(get_first_digit 0 "$dev_version")
                                        read -p "Ingrese el puerto en el que se instalará Tomcat: " PORT
                                        verificar_puerto_reservado -puerto $PORT

                                        if ss -tuln | grep -q ":$PORT "; then
                                            echo "El puerto $PORT esta en uso. Eliga otro."
                                        elif [[ $? -eq 0 ]]; then
                                            echo "El puerto $PORT esta ocupado en otro servicio."
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
                                    0)
                                        echo "Saliendo..."
                                    ;;
                                    *)
                                        echo "Opción no válida."
                                    ;;
                                esac
                            ;;
                            3)
                                echo "Instalar Nginx"
                                downloadsNginx="https://nginx.org/en/download.html"
                                dev_version=$(get_lts_version "$downloadsNginx" 0)
                                last_lts_version=$(get_lts_version "$downloadsNginx" 1)

                                echo "¿Que versión de Nginx desea instalar"
                                echo "1. Última versión LTS $last_lts_version"
                                echo "2. Versión de desarrollo $dev_version"
                                echo "0. Salir"
                                read -p "Eliga una opción: " OPCION_NGINX

                                case "$OPCION_NGINX" in
                                    1)
                                        read -p "Ingrese el puerto en el que se instalará Nginx: " PORT
                                        verificar_puerto_reservado -puerto $PORT

                                        if ss -tuln | grep -q ":$PORT "; then
                                            echo "El puerto $PORT esta en uso. Eliga otro."
                                        elif [[ $? -eq 0 ]]; then
                                            echo "El puerto $PORT esta ocupado en otro servicio."
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
                                        verificar_puerto_reservado -puerto $PORT

                                        if ss -tuln | grep -q ":$PORT "; then
                                            echo "El puerto $PORT esta en uso. Eliga otro."
                                        elif [[ $? -eq 0 ]]; then
                                            echo "El puerto $PORT esta ocupado en otro servicio."
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
                                    0)
                                        echo "Saliendo..."
                                    ;;
                                    *)
                                        echo "Opción no válida."
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
                ;;
                *)
                    echo "Opción inválida (SI/NO)"
                ;;
            esac
        ;;
        0)
            echo "Saliendo..."
            exit 0
        ;;
        *)
            echo "Opción inválida."
        ;;
    esac
done