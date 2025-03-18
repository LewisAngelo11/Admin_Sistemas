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
                                        fi
                                    ;;
                                    2)
                                        echo "Apache no cuenta com versión de desarrollo."
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

                            ;;
                            3)

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

        ;;
        *)
            echo "Opción inválida."
        ;;
    esac
done