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

# Instalar servicio http con SSL
install_server_http_ssl() {
    local url=$1
    local versionInstall=$2
    local archivoDescomprimido=$3
    local servicio=$4

    # Instalar la version
    if ! curl -s -O "$url$versionInstall"; then
        echo "Error al descargar el archivo $versionInstall"
        return 1
    fi
    
    # Descomprimir el archivo descargado
    sudo tar -xzf $versionInstall > /dev/null 2>&1
    
    # Entrar a la carpeta
    cd "$archivoDescomprimido"
    
    # Instalar dependencias para SSL
    sudo apt install -y libssl-dev > /dev/null 2>&1
    
    # Configurar según el tipo de servidor
    if [ "$servicio" = "apache2" ]; then
        # Compilar Apache con soporte SSL
        ./configure --prefix=/usr/local/"$servicio" --enable-ssl --enable-so > /dev/null 2>&1
    elif [ "$servicio" = "nginx" ]; then
        # Compilar Nginx con soporte SSL
        ./configure --prefix=/usr/local/"$servicio" \
            --with-http_ssl_module \
            --with-http_v2_module > /dev/null 2>&1
    else
        echo "Tipo de servidor no soportado"
        return 1
    fi
    
    # Instalar servicio
    make -s > /dev/null 2>&1
    sudo make install > /dev/null 2>&1
}

# Función para generar certificados SSL
generate_ssl_cert() {
    local cert_dir=$1
    
    # Crear directorios para certificados si no existen
    sudo mkdir -p $cert_dir
    
    # Generar certificado autofirmado
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout $cert_dir/server.key \
        -out $cert_dir/server.crt \
        -subj "/C=ES/ST=State/L=City/O=Organization/CN=localhost" \
        > /dev/null 2>&1
        
    echo "Certificado SSL autofirmado generado en $cert_dir"
}

# Función para configurar SSL en Apache
configure_ssl_apache() {
    local apache_root=$1
    local port=$2
    local https_port=$3
    
    # Ruta para certificados
    local cert_dir="$apache_root/conf/ssl"
    
    # Generar certificados
    generate_ssl_cert "$cert_dir"
    
    # Habilitar módulos SSL en httpd.conf
    sudo sed -i 's/#LoadModule ssl_module modules\/mod_ssl.so/LoadModule ssl_module modules\/mod_ssl.so/' $apache_root/conf/httpd.conf
    sudo sed -i 's/#LoadModule socache_shmcb_module modules\/mod_socache_shmcb.so/LoadModule socache_shmcb_module modules\/mod_socache_shmcb.so/' $apache_root/conf/httpd.conf
    
    # Configurar puerto HTTP
    sudo sed -i '/^Listen/d' $apache_root/conf/httpd.conf
    sudo printf "Listen $port\n" >> $apache_root/conf/httpd.conf
    
    # Añadir configuración SSL al final del archivo
    cat << EOF | sudo tee -a $apache_root/conf/httpd.conf > /dev/null
# SSL Configuration
Listen $https_port
<VirtualHost *:$https_port>
    DocumentRoot "$apache_root/htdocs"
    SSLEngine on
    SSLCertificateFile "$cert_dir/server.crt"
    SSLCertificateKeyFile "$cert_dir/server.key"
    <Directory "$apache_root/htdocs">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
    
    echo "SSL configurado correctamente para Apache"
}