#!/bin/bash

# Importar el script de las funciones
source ./Funciones_DNS.sh

# Llamar a las funciones en el orden adecuado

echo "Iniciando la configuración de Bind9..."

# Instalar Bind9
install_bind9

read -p "Ingrese el nombre del dominio: " DOMINIO
read -p "Ingrese la IP del servidor: " IP_SERVIDOR
read -p "Ingrese la IP del cliente: " IP_CLIENTE

# Configurar la zona
setup_zone_file "$DOMINIO"

# Configurar named.conf.local
configure_named_conf "$DOMINIO"

# Crear la zona directa
create_zone_file "$DOMINIO" "$IP_CLIENTE" "$IP_SERVIDOR"

# Reiniciar Bind9
restart_bind9

# Verificar el estado de Bind9
check_bind9_status

echo "Configuración completada."
