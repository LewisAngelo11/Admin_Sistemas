# Verificar si el rol de servidor DNS está instalado
$dnsFeature = Get-WindowsFeature -Name DNS

if (-not $dnsFeature.Installed) {
    Write-Output "El servicio DNS no está instalado. Instalándolo ahora..."
    Install-WindowsFeature -Name DNS -IncludeManagementTools
    Write-Output "El servicio DNS se ha instalado correctamente."
} else {
    Write-Output "El servicio DNS ya está instalado."
}

# Solicitar el nombre del dominio
$domain = Read-Host "Nombre del dominio"
Write-Output "Dominio ingresado es: $domain"

# Crear la zona primaria en el servidor DNS
Add-DnsServerPrimaryZone -Name $domain -ZoneFile "$domain.dns" -DynamicUpdate NonsecureAndSecure
Write-Output "Zona DNS primaria creada para el dominio: $domain"

# Solicitar la IP del cliente
$ipclient = Read-Host "Ingrese la IP del cliente"

# Agregar registros A
Add-DnsServerResourceRecordA -Name "@" -ZoneName "$domain" -IPv4Address "$ipclient"
Add-DnsServerResourceRecordA -Name "www" -ZoneName "$domain" -IPv4Address "$ipclient"

Write-Output "¡Servidor DNS configurado exitosamente!"
