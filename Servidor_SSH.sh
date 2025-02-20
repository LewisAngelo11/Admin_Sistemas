#!/bin/bash

# Actualizar los paquetes antes de instalar SSH
sudo apt update && sudo apt upgrade -y

# Instalar el servicio OpenSSH Server
sudo apt install -y openssh-server

# Iniciar y habilitar el servicio SSH para que arranque automáticamente
sudo systemctl enable --now ssh

# Verificar el estado del servicio SSH
sudo systemctl status ssh

# Activar el firewall de Ubuntu Server (si no está activo)
sudo ufw enable

# Permitir el tráfico en el puerto del SSH (22)
sudo ufw allow ssh

# Confirmar que la regla de firewall se ha aplicado
sudo ufw status
