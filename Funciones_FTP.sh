#!/bin/bash

# Función para instalar el FTP
instalar_ftp() {
    if dpkg -l | grep -q "^ii  vsftpd"; then
        echo "El servicio FTP ya está instalado."
        return 1
    else
        echo "El servicio FTP no está instalado, instalando ahora..."
        sudo apt update && sudo apt install -y vsftpd
        return 0
    fi
}

# Función para configurar el archivo vsftpd.conf
configurar_vsftpd() {
    # Hacer un respaldo de la configuración original
    sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

    # Escribir nueva configuración en vsftpd.conf
    sudo tee /etc/vsftpd.conf > /dev/null <<EOF
listen=YES
anonymous_enable=YES
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
EOF

    # Reinicio el servicio FTP
    sudo systemctl restart vsftpd
    sudo systemctl enable vsftpd
}

# Función para crear grupos
create_groups() {
    sudo groupadd reprobados
    sudo groupadd recursadores
    echo "Grupos reprobados y recursadores creados."
}

# Función para crear un usuario y asignarlo a un grupo
create_user() {
    local username=$1
    local password=$2
    local group=$3

    sudo useradd -m -d /home/$username -s /bin/bash -G $group $username
    echo "Usuario $username creado en el grupo $group."

    echo "Asignando contraseña a $username..."
    echo "$username:$password" | sudo chpasswd

    # Crear carpetas y asignar permisos
    sudo mkdir -p /home/$username/ftp/{general,$group,$username}
    sudo chown -R $username:$group /home/$username/ftp
    sudo chmod -R 770 /home/$username/ftp

    echo "Carpetas creadas y permisos asignados a $username."
}

# Función para permitir acceso anónimo a la carpeta "general"
setup_anonymous_access() {
    sudo mkdir -p /srv/ftp/general
    sudo chmod -R 755 /srv/ftp/general
    sudo chown -R nobody:nogroup /srv/ftp/general
    echo "Acceso anónimo configurado en /srv/ftp/general."
}
