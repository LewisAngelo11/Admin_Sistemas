function apache_lastestversion{
    # Definir la URL de la página de descargas de Apache
    $url = "https://downloads.apache.org/httpd/"

    # Obtener el contenido de la página web
    $response = Invoke-WebRequest -Uri $url

    # Buscar enlaces que coincidan con "httpd-X.Y.Z.tar.bz2"
    $versions = $response.Links | Where-Object { $_.href -match "httpd-[\d.]+.tar.bz2" } | Select-Object -ExpandProperty href

    # Buscar la versión en desarrollo
    $dev_version = $versions | Where-Object { $_ -match "^2\.[5-9]" } | Select-Object -First 1

    # Mostrar la versión en desarrollo
    if ($dev_version) {
        Write-Host "Última versión en desarrollo de Apache: $dev_version"
    } else {
        Write-Host "No se encontró una versión en desarrollo de Apache en este momento."
    }
}


function apache_LTS_lastestversion {
    # Definir la URL de la página de descargas de Apache
    $url = "https://downloads.apache.org/httpd/"
    # Obtener el contenido de la página web
    $response = Invoke-WebRequest -Uri $url

    # Buscar enlaces que coincidan con "httpd-2.4.X.tar.bz2" (solo versiones 2.4.x LTS)
    $matches = $response.Links | Where-Object { $_.href -match "httpd-2.4[\d.]+.tar.bz2" } | Select-Object -ExpandProperty href

    # Extraer la última versión LTS disponible (ordenando por número de versión)
    $latestLTSVersion = ($matches | Sort-Object { $_ -replace '[^\d.]', '' } -Descending)[0]

    # Mostrar la última versión LTS en pantalla
    Write-Output "La última versión LTS de Apache es: $latestLTSVersion"
}


function nginx_LTS_lastestversion {
    # URL de la página de descargas de Nginx
    $url = "https://nginx.org/download/"

    # Descargar el contenido de la página
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing

    # Filtrar las versiones disponibles de Nginx
    $versions = $response.Links | Where-Object { $_.href -match "nginx-\d+\.\d+\.\d+\.(zip|tar\.gz)" } | ForEach-Object { $_.href -replace "nginx-|\.zip|\.tar\.gz", "" }

    # Ordenar las versiones de mayor a menor
    $versions = $versions | Sort-Object { [version]$_ } -Descending
    
    # Filtrar la versión estable (LTS)
    $lts_version = $versions | Where-Object { ($_ -match "^\d+\.(\d+)\.\d+$") -and ([int]$matches[1] % 2 -eq 0) } | Select-Object -First 1

    Write-Host "Última versión estable (LTS) de Nginx: $lts_version"
}