#!/bin/bash

get_last_lts_version(){
    # Obtener el HTML de la página de descargas de Apache
    local url=$1
    local html
    html=$(curl -s "$url")

    # Extraer las URLs de las versiones de Apache del html de descargas
    local versions
    versions=$(curl -s "$url" | grep -oE 'httpd-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz')

    # Filtrar las versiones LTS (pares en el número menor de la versión)
    local lts_versions
    lts_versions=$(curl -s "$versions" | grep -E 'httpd-\d+\.(2|4|6|8)\.' )

    # Obtener la última versión LTS (más reciente)
    local latest_lts_version
    latest_lts_version=$(curl -s "$lts_versions" | sort -V | tail -1)

    # Imprimir la última versión LTS
    echo "$latest_lts_version"
}

instalar_servidor_http(){
    
}

get_html(){
    # Obtener el HTML de la página de descargas de Apache
    local url=$1
    local html
    html=$(curl -s "$url")
    echo "${html}"
}


get_last_lts_version(){
    local url=$1

    # Filtrar las versiones LTS (pares en el número menor de la versión)
    local lts_versions=$(curl -s "$url" | grep -oE 'httpd-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz' | grep -E 'httpd-[0-9]+\.(2|4|6|8)\.' | sort -V | tail -1)

    echo "${lts_versions}"
}


install_server_http(){
    local url=$1
    local versionInstall=$2
    local archivoDescomprimido=$3
    local servicio=$4

    # Instalar la version
    curl -s -O "$url/httpd-$versionInstall"
    # Descomprimir el acrichivo descarado
    sudo tar -xzf $versionInstall > /dev/null 2>&1
    # Entrar a la carpeta
    cd "$archivoDescomprimido"
    # Compilar el archivo
    ./configure --prefix=/usr/local/"$servicio" > /dev/null 2>&1
    # Instalar servicio
    make
    sudo make install

}

remove_tar_gz_suffix() {
    local filename=$1
    echo "${filename%.tar.gz}"
}
