#!/bin/bash
echo "=== Configuración del servidor DHCP en Ubuntu ==="

echo "Instalando ahora..."
# Instalar el servicio DHCP
sudo apt update && sudo apt install isc-dhcp-server -y

# Configurar la interfaz en isc-dhcp-server
sudo bash -c "cat > /etc/default/isc-dhcp-server" <<EOF
INTERFACESv4="enp0s3"
INTERFACES6=
EOF

# Pedir los parametros del DHCP
read -p "Ingrese la dirección de la subred" SUBNET
read -p "Ingrese la máscara de subred" NETMASK
read -p "Ingrese el rango inicial de direcciones IPs" IP_START
read -p "Ingrese el rango límite de direcciones IPs" IP_END
read -p "Ingrese la puerta de enlace" GATEWAY
read -p "Ingrese la duración de la concesión en minutos" CONCESION

# Escribir configuración en /etc/dhcp/dhcpd.conf
sudo bash -c "cat > /etc/dhcp/dhcpd.conf" <<EOF
option domain-name "example.org";
option domain-name-server ns1.example.org, ns2.example.org;
default-lease-time $CONCESION;
max-lease-time $CONCESION;

subnet $SUBNET netmask $NETMASK {
    range $IP_START $IP_END;
    option subnet-mask 255.255.255.0;
    option routers $GATEWAY;
    option domain-name-servers 1.1.1.1, 8.8.8.8;
}
EOF

# Reiniciar y habilitar el servicio DHCP
echo "=== Reiniciando el servicio DHCP ==="
sudo systemctl restart isc-dhcp-server
sudo systemctl enable isc-dhcp-server

# Mostrar estado del servicio
echo "=== Instalación y configuración de DHCP completada ==="
sudo systemctl status isc-dhcp-server --no-pager
