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
config_vsftpd() {
    # Hacer un respaldo de la configuración original
    sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

    # Escribir nueva configuración en vsftpd.conf
    sudo tee /etc/vsftpd.conf > /dev/null <<EOF
listen=YES
anonymous_enable=YES
local_enable=YES
write_enable=NO
anon_root=/srv/ftp
chroot_local_user=YES
allow_writeable_chroot=YES
anon_world_readable_only=YES
pasv_min_port=40000
pasv_max_port=50000
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


change_user_group() {
    local username=$1
    local new_group=$2

    # Obtener el grupo actual del usuario
    current_group=$(id -gn "$username")

    # Verificar si el usuario existe
    if id "$username" &>/dev/null; then
        # Verificar si el grupo existe
        if getent group "$new_group" &>/dev/null; then
            # Cambiar el grupo del usuario
            sudo usermod -g "$new_group" "$username"

            # Renombrar el nombre de la carpeta del grupo al actual
            sudo mv "/home/$username/ftp/$current_group" "/home/$username/ftp/$new_group"
            # Cambiar el propietario y grupo de la nueva carpeta
            sudo chown -R "$username:$new_group" "/home/$username/ftp/$new_group"

            echo "El usuario '$username' ha sido cambiado al grupo '$new_group'."
        else
            echo "Error. El grupo '$new_group' no existe, deben de ser los grupos 'reprobados' o 'recursadores'."
        fi
    else
        echo "Error. El usuario '$username' no existe."
    fi
}

delete_user() {
    local username=$1

    # Verificar si el usuario existe
    if id "$username" &>/dev/null; then
        # Eliminar la carpeta asociada al usuario en el FTP
        sudo rm -rf "/home/$username/ftp"

        # Eliminar el usuario del servidor
        sudo userdel "$username"

        echo "El usuario '$username' y sus archivos FTP han sido eliminados."
    else
        echo "Erro: El usuario '$username' no existe."
    fi
}

get_user_and_group() {
    local username
    local new_group

    read -p "Ingrese el nombre del usuario: " username
    read -p "Ingrese el nombre del grupo al que se va a cambiar: " new_group

    # Retornar los valores
    echo "$username $new_group"
}

# Función para permitir acceso anónimo a la carpeta "general"
setup_anonymous_access() {
    sudo mkdir -p /srv/ftp/general
    sudo chmod -R 755 /srv/ftp/general
    sudo chown -R nobody:nogroup /srv/ftp/general

    sudo systemctl restart vsftpd
    echo "Acceso anónimo configurado en /srv/ftp/general."
}

allow_ftp_port() {
    # Activar la regla para el puerto 21 (FTP) en el firewall
    sudo ufw allow 21/tcp

    # Verificar el estado para confirmar que la regla se ha añadido
    echo "Regla para el puerto 21 (FTP) añadida al firewall."
    sudo ufw status | grep "21"
}
