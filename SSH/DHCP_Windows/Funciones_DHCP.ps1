# Función para verificar si el rol de servidor DHCP está instalado
function VerificarInstalarDHCP {
    $dhcpFeature = Get-WindowsFeature -Name DHCP
    if (-not $dhcpFeature.Installed) {
        Write-Output "El protocolo DHCP no está instalado. Instalándolo ahora..."
        Install-WindowsFeature DHCP -IncludeManagementTools
        Write-Output "El protocolo DHCP se ha instalado correctamente."
    } else {
        Write-Output "El servicio DHCP ya está instalado."
    }
}

# Función para pedir parámetros esenciales
function ObtenerParametros {
    $serverIP = "192.168.100.41"  # Ip de mi maquina virtual Windows Server
    $subnetMask = Read-Host "Ingrese la máscara de subred"
    $gateway = Read-Host "Ingrese la puerta de enlace"
    $leaseTime = Read-Host "Ingrese la duración de la concesión en segundos"
    return $serverIP, $subnetMask, $gateway, $leaseTime
}

# Función para pedir el rango de IPs
function ObtenerRangosIP {
    $ipStartRange = Read-Host "Ingrese el rango inicial de direcciones IPs"
    $ipEndRange = Read-Host "Ingrese el rango límite de direcciones IPs"
    return $ipStartRange, $ipEndRange
}

# Función para crear el ámbito DHCP
function CrearScopeDhcp {
    param (
        [string]$serverIP,
        [string]$ipStartRange,
        [string]$ipEndRange,
        [string]$subnetMask
    )
    Write-Host "Creando el ámbito DHCP..." -ForegroundColor Cyan
    Add-DhcpServerV4Scope -Name "Scope_$serverIP" -StartRange $ipStartRange -EndRange $ipEndRange -SubnetMask $subnetMask -State Active
}

# Función para configurar la puerta de enlace
function AsignarGatewayDhcp {
    param (
        [string]$serverIP,
        [string]$gateway
    )
    Write-Host "Configurando la puerta de enlace..." -ForegroundColor Cyan
    Set-DhcpServerv4OptionValue -ScopeId $serverIP -OptionId 3 -Value $gateway
}

# Función para configurar el tiempo de concesión
function AsignarDuracionLease {
    param (
        [string]$serverIP,
        [int]$leaseTime
    )
    Write-Host "Configurando la duración de la concesión..." -ForegroundColor Cyan
    Set-DhcpServerv4Scope -ScopeId $serverIP -LeaseDuration ([TimeSpan]::FromSeconds($leaseTime))
}

# Función para habilitar reglas de firewall para DHCP
function ActivarFirewallDhcp {
    Write-Host "Habilitando reglas de firewall para DHCP..." -ForegroundColor Cyan
    New-NetFirewallRule -DisplayName "DHCP" -Direction Inbound -Protocol UDP -LocalPort 67,68 -Action Allow
}
