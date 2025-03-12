# Función para obtener el HTML de la página
function Get-HTML {
    param (
        [string]$url
    )
    return Invoke-WebRequest -UseBasicParsing -Uri $url
}

function get-version-format {
    param (
        [string]$page
    )
    $format = "\d+\.\d+\.\d+"
    $versiones = [regex]::Matches($page, $format) | ForEach-Object {$_.Value}
    # Eliminar duplicados y ordenar las versiones de mayor a menor
    return $versiones | Sort-Object { [System.Version]$_ } -Descending | Get-Unique
}

function quit-V([string]$version) {
    return $version -replace "^v", ""
}