#!/bin/bash

# Función que obtiene el HTML de la pagina
get_html(){
    # Obtener el HTML de la página de descargas de Apache
    local url=$1
    local html
    html=$(curl -s "$url")
    echo "${html}"
}


get_lts_version(){
    local url=$1
    local index=${2:-0}
    readarray -t versions < <(curl -s "$url" | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | sort -V -r | uniq)
    echo "${versions[$index]}"
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
    make -s > /dev/null 2>&1
    sudo make install > /dev/null 2>&1
}

# Función para eliminar los sufijos .tar.gz del los archivos
remove_tar_gz_suffix() {
    local filename=$1
    echo "${filename%.tar.gz}"
}
get_first_digit(){
    local index=$1
    local cadena=$2

    IFS='.' read -ra version <<< "$cadena"
    echo "${version[$index]}"
}

