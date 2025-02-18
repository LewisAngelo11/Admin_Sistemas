# Verificar si el rol de servidor DHCP está instalado
$dhcpFeature = Get-WindowsFeature -Name DHCP

if (-not $dhcpFeature.Installed) {
    Write-Output "El protocolo DHCP no está instalado. Instalándolo ahora..."
    Install-WindowsFeature DHCP -IncludeManagementTools -Source C:\sources\sxs
    Write-Output "El protocolo DHCP se ha instalado correctamente."
} else {
    Write-Output "El servicio DHCP ya está instalado."
}

# Pedir parámetros esenciales
$serverIP = Read-Host "Ingresa la dirección IP del servidor DHCP (Ejemplo: 192.168.1.10)"
$subnetMask = Read-Host "Ingrese la máscara de subred"
$gateway = Read-Host "Ingrese la puerta de enlace"
$leaseTime = Read-Host "Ingrese la duración de la concesión en segundos"
# Pedir el rango de IPs
$ipStartRange = Read-Host "Ingrese el rango inicial de direcciones IPs"
$ipEndRange = Read-Host "Ingrese el rango límite de direcciones IPs"

# Crear el ámbito DHCP
Write-Host "Creando el ámbito DHCP..." -ForegroundColor Cyan
Add-DhcpServerV4Scope -Name "Scope_$serverIP" -StartRange $ipStartRange -EndRange $ipEndRange -SubnetMask $subnetMask -State Active

# Configurar la puerta de enlace
Write-Host "Configurando la puerta de enlace..." -ForegroundColor Cyan
Set-DhcpServerv4OptionValue -ScopeId $serverIP -OptionId 3 -Value $gateway

# Configurar el tiempo de concesión
Write-Host "Configurando la duración de la concesión..." -ForegroundColor Cyan
Set-DhcpServerv4Scope -ScopeId $serverIP -LeaseDuration ([TimeSpan]::FromSeconds($leaseTime))

# Habilitar reglas de firewall para DHCP
Write-Host "Habilitando reglas de firewall para DHCP..." -ForegroundColor Cyan
New-NetFirewallRule -DisplayName "DHCP" -Direction Inbound -Protocol UDP -LocalPort 67,68 -Action Allow

Write-Host "Configuración del servidor DHCP completada con éxito." -ForegroundColor Green