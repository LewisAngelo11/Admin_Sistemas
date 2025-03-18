#!/bin/bash

# Función para instalar OpenSSL
install_opnessl(){
    sudo apt update & sudo apt install openssl
}

# Función para configurar el archivo vsftpd.conf
config_vsftpd() {
    # Hacer un respaldo de la configuración original
    sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

    # Escribir nueva configuración en vsftpd.conf
    sudo tee /etc/vsftpd.conf > /dev/null <<EOF
listen=YES
anonymous_enable=YES
local_enable=YES
write_enable=YES
anon_root=/srv/ftp
chroot_local_user=NO
allow_writeable_chroot=YES
anon_world_readable_only=YES
pasv_enable=YES
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
pasv_min_port=40000
pasv_max_port=50000
ssl_enable=YES
EOF

    # Reinicio el servicio FTP
    sudo systemctl restart vsftpd
    sudo systemctl enable vsftpd
}

# Mostrar 
show_services_web(){
    echo "¿Qué servicio desea instalar?"
    echo "1. Apache."
    echo "2. Tomcat."
    echo "3. Nginx."
    echo "0. Salir."
    read -p "Elija una opción: " OPCION
}