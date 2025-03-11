#!/bin/bash

# Función que obtiene el HTML de la pagina
get_html(){
    # Obtener el HTML de la página de descargas de Apache
    local url=$1
    local html
    html=$(curl -s "$url")
    echo "${html}"
}

# Obtener la version LTS más reciente de apache
get_last_lts_apache_version(){
    local url=$1

    # Filtrar las versiones LTS (pares en el número menor de la versión)
    local lts_versions=$(curl -s "$url" | grep -oE 'httpd-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz' | grep -P 'httpd-[0-9]+\.[0-9]*[02468]\.' | sort -V | tail -1)
    echo "${lts_versions}"
}

# Obtener la version LTS más reciente de nginx
get_last_lts_nginx_version(){
    local url=$1

    # Buscar versiones LTS
    # Para Nginx, las versiones estables tienen el segundo número par (1.20.x, 1.22.x, etc.)
    local stable_versions=$(curl -s "$url" | grep -oE 'nginx-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz' | grep -P 'nginx-[0-9]+\.[0-9]*[02468]\.' | sort -V | tail -1)
    echo "${stable_versions}"
}

# Obtener la version de desarrollo de Nginx
get_last_dev_nginx_version(){
    local url=$1

    # Buscar versiones de desarrollo. 
    # Las versiones de desarrollo suelen tener un número impar en la segunda parte de la versión (por ejemplo: 1.25.x, 1.27.x, etc.)
    local dev_versions=$(curl -s "$url" | grep -oE 'nginx-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz' | grep -P 'nginx-[0-9]+\.[0-9]*[13579]\.' | sort -V | tail -1)
    echo "${dev_versions}"
}

# Funcion para instalar el servicio http
install_server_http(){
    local url=$1
    local versionInstall=$2
    local archivoDescomprimido=$3
    local servicio=$4

    # Instalar la version
    if ! curl -s -O "$url$versionInstall"; then
        echo "Error al descargar el archivo $versionInstall"
        return 1
    fi
    # Descomprimir el acrichivo descarado
    sudo tar -xzf $versionInstall > /dev/null 2>&1
    # Entrar a la carpeta
    cd "$archivoDescomprimido"
    # Compilar el archivo
    ./configure --prefix=/usr/local/"$servicio" > /dev/null 2>&1
    # Instalar servicio
    make #-s > /dev/null 2>&1
    sudo make install #> /dev/null 2>&1
}

# Función para eliminar los sufijos .tar.gz del los archivos
remove_tar_gz_suffix() {
    local filename=$1
    echo "${filename%.tar.gz}"
}

# FUNCIONES EXTRAS. Estas no son relevantes para el funcionamiento del script
# Funciones para depurar...
get_all_apache_versions(){
    local url=$1
    
    # Obtener todas las versiones de la pagina oficial
    local lts_versions=$(curl -s "$url" | grep -oE 'httpd-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz')
    echo "${lts_versions}"
}

get_all_nginx_versions(){
    local url=$1
    
    # Obtener todas las versiones de Nginx
    local versions=$(curl -s "$url" | grep -oE 'nginx-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz')
    echo "${versions}"
}
