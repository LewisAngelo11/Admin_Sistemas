#!/bin/bash

# Importar el script de las funciones
source ./Funciones_DHCP.sh

echo "=== Configuración del servidor DHCP en Ubuntu ==="

# Obtener los parámetros del DHCP
read -r CONCESION SUBNET NETMASK IP_START IP_END GATEWAY <<< "$(get_dhcp_parametros)"

# Instalar el servicio DHCP
instalar_dhcp

# Configurar la interfaz de red en isc-dhcp-server
configurar_interfaz

# Escribir en el archivo de configuración dhcpd.conf
configurar_dhcp_conf "$CONCESION" "$SUBNET" "$NETMASK" "$IP_START" "$IP_END" "$GATEWAY"

# Reiniciar y habilitar el servicio DHCP
reiniciar_servicio_dhcp

# Mostrar el estado del servicio
mostrar_estado_dhcp

echo "=== Instalación y configuración de DHCP completada ==="