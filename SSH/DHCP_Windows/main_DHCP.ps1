# Importar las Funciones
. .\Funciones_DHCP.ps1

# Verificar si DHCP está instalado
VerificarInstalarDHCP

# Obtener parámetros esenciales
$serverIP, $subnetMask, $gateway, $leaseTime = ObtenerParametros

# Obtener el rango de IPs
$ipStartRange, $ipEndRange = ObtenerRangosIP

# Crear el ámbito DHCP
CrearScopeDhcp -serverIP $serverIP -ipStartRange $ipStartRange -ipEndRange $ipEndRange -subnetMask $subnetMask

# Configurar la puerta de enlace
AsignarGatewayDhcp -serverIP $serverIP -gateway $gateway

# Configurar la duración de la concesión
AsignarDuracionLease -serverIP $serverIP -leaseTime $leaseTime

# Habilitar reglas de firewall
ActivarFirewallDhcp

Write-Host "Configuración del servidor DHCP completada con éxito." -ForegroundColor Green

