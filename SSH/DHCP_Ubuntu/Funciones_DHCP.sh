#!/bin/bash

# Función para instalar el servicio DHCP
instalar_dhcp() {
    echo "Instalando el servicio DHCP..."
    sudo apt update && sudo apt install isc-dhcp-server -y
}

# Función para configurar la interfaz en isc-dhcp-server
configurar_interfaz() {
    echo "Configurando la interfaz de red..."
    sudo bash -c "cat > /etc/default/isc-dhcp-server" <<EOF
INTERFACESv4="enp0s3"
INTERFACES6=
EOF
}

# Función para escribir en el archivo de configuración dhcpd.conf
configurar_dhcp_conf() {
    local CONCESION="$1"
    local SUBNET="$2"
    local NETMASK="$3"
    local IP_START="$4"
    local IP_END="$5"
    local GATEWAY="$6"

    echo "Escribiendo configuración en /etc/dhcp/dhcpd.conf..."
    sudo bash -c "cat > /etc/dhcp/dhcpd.conf" <<EOF
option domain-name "example.org";
option domain-name-server ns1.example.org, ns2.example.org;
default-lease-time $CONCESION;
max-lease-time $CONCESION;

subnet $SUBNET netmask $NETMASK {
    range $IP_START $IP_END;
    option subnet-mask $NETMASK;
    option routers $GATEWAY;
    option domain-name-servers 1.1.1.1, 8.8.8.8;
}
EOF
}

# Función para reiniciar y habilitar el servicio DHCP
reiniciar_servicio_dhcp() {
    echo "Reiniciando el servicio DHCP..."
    sudo systemctl restart isc-dhcp-server
    sudo systemctl enable isc-dhcp-server
}

# Función para mostrar el estado del servicio DHCP
mostrar_estado_dhcp() {
    echo "Estado del servicio DHCP..."
    sudo systemctl status isc-dhcp-server --no-pager
}

# Función para pedir los parámetros esenciales
get_dhcp_parametros() {
    read -p "Ingrese el tiempo de concesión en segundos: " CONCESION
    read -p "Ingrese la subred: " SUBNET
    read -p "Ingrese la máscara de red: " NETMASK
    read -p "Ingrese el inicio del rango de IPs: " IP_START
    read -p "Ingrese el final del rango de IPs: " IP_END
    read -p "Ingrese la puerta de enlace: " GATEWAY

    echo "$CONCESION $SUBNET $NETMASK $IP_START $IP_END $GATEWAY"
}


