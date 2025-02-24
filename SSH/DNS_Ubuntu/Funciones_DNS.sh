#!/bin/bash

# Función para instalar Bind9
install_bind9() {
  echo "Instalando Bind9..."
  apt update && apt install -y bind9 bind9utils bind9-doc
}

# Función para extraer el nombre de la zona
setup_zone_file() {
  DOMINIO=$1  # Primer parámetro pasado a la función
  sudo cp /etc/bind/db.local "/etc/bind/db.$DOMINIO"
}

# Función para configurar named.conf.local
configure_named_conf() {
  DOMINIO=$1  # Primer parámetro pasado a la función
  echo "Configurando named.conf.local..."
  cat <<EOF > /etc/bind/named.conf.local
zone "$DOMINIO" {
    type master;
    file "/etc/bind/db.$DOMINIO";
};
EOF
}

# Función para crear la zona directa
create_zone_file() {
  DOMINIO=$1
  IP_CLIENTE=$2
  IP_SERVIDOR=$3
  
  echo "Creando archivo de zona directa..."
  cat <<EOF > /etc/bind/db.$DOMINIO
\$TTL 604800
@   IN  SOA     $DOMINIO. root.$DOMINIO. (
                2           ; Serial
                604800      ; Refresh
                86400       ; Retry
                2419200     ; Expire
                604800 )    ; Negative Cache TTL

@   IN  NS      ns.$DOMINIO.
@   IN  A       $IP_CLIENTE
ns  IN  A       $IP_SERVIDOR
www IN  A       $IP_CLIENTE
EOF
}

# Función para reiniciar Bind9
restart_bind9() {
  echo "Reiniciando Bind9..."
  systemctl restart named
  systemctl enable named
}

# Función para verificar el estado de Bind9
check_bind9_status() {
  echo "Verificando el estado de Bind9..."
  systemctl status bind9 --no-pager
}
