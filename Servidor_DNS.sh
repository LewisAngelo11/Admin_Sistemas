echo "=== Configuración del servidor DNS ==="

read -p "Ingrese el Nombre del dominio: " DOMINIO
read -p "Ingrese la IP del Servidor: " IP_SERVER
read -p "Ingrese la IP del Cliente: " IP_CLIENT


echo "Instalando Bind9"
#!/bin/bash

echo "==== Configuración del Servidor DNS en Ubuntu ===="

# Pedir datos al usuario
read -p "Ingrese el nombre del dominio (ej: ejemplo.com): " DOMINIO
read -p "Ingrese la IP del servidor DNS: " IP_SERVIDOR
read -p "Ingrese la IP del cliente que usará este DNS: " IP_CLIENTE

# Instalar Bind9 si no está instalado
echo "Instalando Bind9..."
apt update && apt install -y bind9 bind9utils bind9-doc

# Extraer el nombre de la zona
ZONA_DIRECTA="/etc/bind/db.$DOMINIO"
sudo cp /etc/bind/db.local "$ZONA_DIRECTA"

# Configurar el archivo named.conf.local
echo "Configurando named.conf.local..."
cat <<EOF > /etc/bind/named.conf.local
zone "$DOMINIO" {
    type master;
    file "/etc/bind/db.$DOMINIO";
};
EOF

echo "Configuracion: $DOMINIO, $IP_SERVER, $IP_CLIENT, $ZONA_DIRECTA"
# Crear la zona directa
echo "Creando archivo de zona directa..."
cat <<EOF > $ZONA_DIRECTA
\$TTL 604800
@   IN  SOA     $DOMINIO. root.$DOMINIO. (
                2           ; Serial
                604800      ; Refresh
                86400       ; Retry
                2419200     ; Expire
                604800 )    ; Negative Cache TTL

@   IN  NS      ns.$DOMINIO.
@   IN  A       $IP_CLIENT
ns  IN  A       $IP_SERVIDOR
www IN  A       $IP_CLIENTE
EOF

# Reiniciar Bind9
echo "Reiniciando Bind9..."
systemctl restart named
systemctl enable named

# Verificar el estado del servicio
echo "Verificando el estado de Bind9"
systemctl status bind9 --no-pager
echo "Configuración completada"

