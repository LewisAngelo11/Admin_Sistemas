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
write_enable=YES
anon_root=/srv/ftp
chroot_local_user=NO
allow_writeable_chroot=YES
anon_world_readable_only=YES
pasv_enable=YES
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

create_files_FTP() {
    sudo mkdir -p /ftp/general
    sudo mkdir -p /ftp/reprobados
    sudo mkdir -p /ftp/recursadores

    sudo chown -R root:users /ftp/general
    sudo chmod -R 775 /ftp/general

    sudo chown -R :reprobados /ftp/reprobados
    sudo chmod -R 770 /ftp/reprobados

    sudo chown -R :recursadores /ftp/recursadores
    sudo chmod -R 770 /ftp/recursadores
}

# Función para crear un usuario y asignarlo a un grupo
create_user() {
    local username=$1
    local password=$2
    local group=$3

    if id "$username" &>/dev/null; then
        echo "El usuario $username ya existe"
    else
        if getent group "$group" &>/dev/null; then
            sudo useradd "$username"
            echo "$username:$password" | sudo chpasswd

            sudo useradd "$username" "$group"

            # Crear carpetas y asignar permisos
            sudo mkdir -p /home/$username/ftp/$username

            sudo mkdir -p /home/$username/ftp/general
            sudo mkdir -p /home/$username/ftp/$group

            # Carpeta personal: accesible solo por el propio usuario
            sudo chown -R $username:$username /home/$username/ftp/$username
            sudo chmod -R 700 /home/$username/ftp/$username

            sudo mount --bind /ftp/general /home/$username/ftp/general
            sudo mount --bind /ftp/$group /home/$username/ftp/$group

            echo "Carpetas creadas y permisos asignados a $username."
        else
            echo "El group '$group' no existe."
        fi
    fi
}


change_user_group() {
    local username=$1
    local new_group=$2

    # Obtener el grupo actual del usuario
    current_group=$(groups "$username" | awk '{print $5}')

    # Verificar si el usuario existe
    if id "$username" &>/dev/null; then
        # Verificar si el grupo existe
        if getent group "$new_group" &>/dev/null; then
            # Verificar si el grupo nuevo no es el mismo al actual
            if [[ "$current_group" ==  "$new_group" ]]; then
                echo "El usuario '$username' ya esta en el grupo '$current_group'."
                return
            fi
            # Desmontar la carpeta del grupo anterior y montar la nueva
            sudo umount "/home/$username/ftp/$current_group" 2>/dev/null

            sudo deluser $username $current_group
            sudo adduser $username $new_group

            sudo mv "/home/$username/ftp/$current_group" "/home/$username/ftp/$new_group"

            # Asegurar que la carpeta personal del usuario sigue existiendo
            sudo mkdir -p "/home/$username/ftp/$username"
            sudo chown -R "$username:$username" "/home/$username/ftp/$username"
            sudo chmod -R 700 "/home/$username/ftp/$username"

            # Montar la nueva carpeta del nuevo grupo y la general
            sudo mount --bind "/ftp/$new_group" "/home/$username/ftp/$new_group"
            sudo mount --bind "/ftp/$general" "/home/$username/ftp/$new_group"

            echo "El usuario '$username' ha sido cambiado al grupo '$new_group' y las carpetas han sido actualizadas."
        else
            echo "Error. El grupo '$new_group' no existe."
        fi
    else
        echo "Error. El usuario '$username' no existe."
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
    sudo mount --bind /ftp/general /srv/ftp/general
    echo "Acceso anónimo configurado en /srv/ftp/general."

    sudo systemctl restart vsftpd
}

allow_ftp_port() {
    # Activar la regla para el puerto 21 (FTP) en el firewall
    sudo ufw allow 21/tcp
    sudo ufw allow 40000:50000/tcp

    # Verificar el estado para confirmar que la regla se ha añadido
    echo "Regla para el puerto 21 (FTP) añadida al firewall."
    sudo ufw status | grep "21"
}

# Función para validar el nombre de usuario
validar_usuario() {
    local usuario="$1"
    
    # Validar que no esté vacío
    if [[ -z "$usuario" ]]; then
        echo "El nombre de usuario no puede estar vacío."
        return 1
    fi

    # Validar que no exceda los 20 caracteres
    if [[ ${#usuario} -gt 20 ]]; then
        echo "El nombre de usuario no puede tener más de 20 caracteres."
        return 1
    fi

    # Validar que no sea solo números
    if [[ "$usuario" =~ ^[0-9]+$ ]]; then
        echo "El nombre de usuario no puede ser solo números."
        return 1
    fi

    # Si pasa todas las validaciones
    echo "El nombre de usuario '$usuario' es válido."
    return 0
}
