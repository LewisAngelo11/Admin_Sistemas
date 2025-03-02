# Función para validar la IP
function validar_ip {
    param ([String]$ip)

    $pattern = "^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"

    do {
        if ($ip -notmatch $pattern) {
            Write-Host "IP inválida. Inténtalo de nuevo." -ForegroundColor Red
            $ip = Read-Host "Ingresa una IP válida para tu servidor DNS"
        }
    } while ($ip -notmatch $pattern)

    return $ip
}