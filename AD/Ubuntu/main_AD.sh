#!/usr/bin/env bash
installsssd(){
    sudo apt-get install sssd-ad sssd-tools realmd adcli
}


changehostname(){
    local domain="$1"
    current_hostname=$(cat /etc/hostname)
    new_hostname="${current_hostname}.${domain}"
    echo "$new_hostname" | sudo tee /etc/hostname > /dev/null
    sudo sed -i "s/${current_hostname}/${new_hostname}/g" /etc/hosts
}

changedateformat(){
    local IpDnsServer="$1"
    echo "NTP=${IpDnsServer}" | sudo tee -a /etc/systemd/timesyncd.conf
    sudo sed -i "s/nameserver *.*.*.*/nameserver ${IpDnsServer}/g" /etc/resolv.conf
}


jointodomainname(){
    local username="$1"
    local domain="$2"

    realm join -v -U $username $domain
}


userhashomedirectory(){
    sudo pam-auth-update --enable mkhomedir
}


# Main
echo "instalando sssd..........."
installsssd

clear
echo "sssd instalado.."

read -p "ingrese el nombre de dominio para conectarse a active directory" Domain
read -p "Ingrese la ip del active directory domain services" IpAd

changehostname "$Domain"
changedateformat "$IpAd"

read -p "ingrese el nombre de usuario con el que se conectara al dominio,sino tiene un usuario en grupo administradores use Administrador" username

jointodomainname "$username" "$Domain"

userhashomedirectory