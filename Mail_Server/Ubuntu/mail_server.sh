#!/bin/bash

# Función para instalar y configurar Postfix + Dovecot
install_mail_server() {
    echo "Instalando Postfix y Dovecot..."
    sudo apt update
    sudo apt install -y postfix dovecot-core dovecot-pop3d dovecot-imapd mailutils

    echo "Configurando Postfix..."
    sudo bash -c "cat > /etc/postfix/main.cf" <<EOF
myhostname = luissoto11
mydomain = localhost
myorigin = \$mydomain
inet_interfaces = all
inet_protocols = ipv4
mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain, luissoto11.localhost
home_mailbox = Maildir/
smtpd_banner = \$myhostname ESMTP
smtpd_relay_restrictions = reject_unauth_destination
smtpd_recipient_restrictions = reject_unauth_destination
EOF

    sudo systemctl restart postfix
    sudo systemctl enable postfix

    echo "Configurando Dovecot..."
    sudo sed -i 's/^#protocols = imap pop3 lmtp/protocols = imap pop3/' /etc/dovecot/dovecot.conf
    sudo sed -i 's/^#disable_plaintext_auth = yes/disable_plaintext_auth = no/' /etc/dovecot/conf.d/10-auth.conf
    sudo sed -i 's/^mail_location = mbox:~/Mail:INBOX=/mail_location = maildir:~\/Maildir/' /etc/dovecot/conf.d/10-mail.conf

    sudo systemctl restart dovecot
    sudo systemctl enable dovecot

    echo "Abriendo puertos en el firewall..."
    sudo ufw allow 25/tcp   # SMTP
    sudo ufw allow 110/tcp  # POP3
    sudo ufw allow 143/tcp  # IMAP
    sudo ufw reload

    echo "Servidor de correo instalado correctamente."
}

install_squirrelmail(){
    # Instalar dependencias necesarias
    sudo apt update
    sudo apt upgrade -y
    sudo apt install software-properties-common -y
    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt update
    sudo apt install apache2
    sudo apt install php7.4 libapache2-mod-php7.4 php-mysql -y
    # Descargar la última versión estable de SquirrelMail
    wget https://sourceforge.net/projects/squirrelmail/files/latest/download/squirrelmail-webmail-1.4.22.tar.gz
    # Extraer el archivo tar
    sudo tar -xzf squirrelmail-webmail-1.4.22.tar.gz > /dev/null 2>&1
    # Mover y configurar permisos de la carpeta
    sudo mv squirrelmail-webmail-1.4.22 /var/www/html/squirrelmail
    sudo chown -R www-data:www-data /var/www/html/squirrelmail
    sudo chmod 755 -R /var/www/html/squirrelmail
    # Crear la carpeta de data y asignar permisos
    sudo mkdir -p /var/local/squirrelmail/data
    sudo chown -R www-data:www-data /var/local/squirrelmail
    sudo chmod -R 755 /var/local/squirrelmail
    # Configurar squirrelmail
    cd /var/www/html/squirrelmail/config
    sudo cp config_default.php config.php
    sudo ./conf.pl
    # Configurar Apache
    cat > /etc/apache2/sites-available/squirrelmail.conf <<EOF
<VirtualHost *:80>
    ServerAdmin admin@example.com
    DocumentRoot /var/www/html/squirrelmail
    Alias /squirrelmail "/var/www/html/squirrelmail"

    <Directory "/var/www/html/squirrelmail">
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
    # Activar el sitio y el módulo de reescritura en Apache
    a2ensite squirrelmail
    a2enmod rewrite
    systemctl restart apache2

}

# Función para crear la zona directa enfocada al mail_server
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

; Servidores de nombres
@   IN  NS      ns.$DOMINIO.
ns  IN  A       $IP_SERVIDOR

; Registros A (dirección IP del servidor y del cliente)
@   IN  A       $IP_SERVIDOR
www IN  A       $IP_CLIENTE
mail IN  A      $IP_SERVIDOR  ; IP del servidor de correo

; Registro MX (prioridad 10 para mail.DOMINIO)
@   IN  MX 10   mail.$DOMINIO.

; Registros adicionales opcionales
imap IN  A      $IP_SERVIDOR
pop3 IN  A      $IP_SERVIDOR
smtp IN  A      $IP_SERVIDOR
EOF
}

# Función para crear un usuario de correo
create_mail_user() {
    read -p "Ingrese el nombre de usuario: " username
    
    # Crear usuario con su directorio home
    sudo adduser "$username"

    # Crear estructura Maildir
    sudo mkdir -p /home/test/Maildir/cur
    sudo mkdir -p /home/test/Maildir/new
    sudo mkdir -p /home/test/Maildir/tmp
    sudo chown -R $username:$username /home/$username/Maildir
    sudo chmod -R 700 /home/$username/Maildir

    # Asignar permisos adecuados
    sudo chown -R "$username:$username" "/home/$username"
    sudo chmod -R 755 "/home/$username"

    echo "Usuario '$username' creado con éxito y Maildir configurado correctamente."
}

# Función para probar el envío de un correo
send_test_email() {
    read -p "Ingrese el destinatario: " recipient
    echo "Hola, esto es un correo de prueba." | mail -s "Prueba de correo" "$recipient"
    echo "Correo enviado a $recipient."
}

# Función para ver correos recibidos
view_inbox() {
    read -p "Ingrese el nombre de usuario: " username
    sudo ls -l "/home/$username/Maildir/"
    sudo ls -l "/home/$username/Maildir/new/"
}

# install_squirrelmail
create_zone_file

# Menú interactivo
while true; do
    clear
    echo "=============================="
    echo " SERVIDOR DE CORREO SMTP/POP3"
    echo "=============================="
    echo "1) Instalar servidor de correo"
    echo "2) Crear usuario de correo"
    echo "3) Enviar correo de prueba"
    echo "4) Ver correos recibidos"
    echo "0) Salir"
    echo "=============================="
    read -p "Seleccione una opción: " option

    case $option in
        1) install_mail_server ;;
        2) create_mail_user ;;
        3) send_test_email ;;
        4) view_inbox ;;
        0) echo "Saliendo..."; exit ;;
        *) echo "Opción inválida"; sleep 2 ;;
    esac
done
