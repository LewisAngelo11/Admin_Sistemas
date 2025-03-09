#!/bin/bash

get_last_lts_version(){
    # Obtener el HTML de la página de descargas de Apache
    local url=$1
    local html
    html=$(curl -s "$url")

    # Extraer las URLs de las versiones de Apache del html de descargas
    local versions
    versions=$(echo "$html" | grep -oP 'httpd-\d+\.\d+\.\d+\.tar\.gz')

    # Filtrar las versiones LTS (pares en el número menor de la versión)
    local lts_versions
    lts_versions=$(echo "$versions" | grep -E 'httpd-\d+\.(2|4|6|8)\.' )

    # Obtener la última versión LTS (más reciente)
    local latest_lts_version
    latest_lts_version=$(echo "$lts_versions" | sort -V | tail -1)

    # Imprimir la última versión LTS
    echo "$latest_lts_version"
}

instalar_servidor_http(){
    
}





