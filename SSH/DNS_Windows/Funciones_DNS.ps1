# Función para verificar e instalar el servicio DNS
function VerificarInstalarDNS {
    $dnsFeature = Get-WindowsFeature -Name DNS
    if (-not $dnsFeature.Installed) {
        Write-Output "El servicio DNS no está instalado. Instalándolo ahora..."
        Install-WindowsFeature -Name DNS -IncludeManagementTools
        Write-Output "El servicio DNS se ha instalado correctamente."
    } else {
        Write-Output "El servicio DNS ya está instalado."
    }
}

# Función para crear la zona DNS
function ConfigurarZonaDNS {
    param (
        [string]$domain
    )
    Add-DnsServerPrimaryZone -Name $domain -ZoneFile "$domain.dns" -DynamicUpdate NonsecureAndSecure
    Write-Output "Zona DNS primaria creada para el dominio: $domain"
}

# Función para agregar registros A
function AgregarRegistrosA {
    param (
        [string]$domain,
        [string]$ipclient
    )
    Add-DnsServerResourceRecordA -Name "@" -ZoneName $domain -IPv4Address $ipclient
    Add-DnsServerResourceRecordA -Name "www" -ZoneName $domain -IPv4Address $ipclient
    Write-Output "Registros A agregados para $domain con IP $ipclient."
}