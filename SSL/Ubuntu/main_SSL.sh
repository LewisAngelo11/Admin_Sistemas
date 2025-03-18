#!/bin/bash

source Funciones_SSL.sh

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

                ;;
                "NO")

                ;;
                *)

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