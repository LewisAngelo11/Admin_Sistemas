# Importar las funciones
. .\Funciones_DNS.ps1

# Ejecutar instalación y configuración
VerificarInstalarDNS

# Solicitar datos al usuario
$domain = Read-Host "Nombre del dominio"
Write-Output "Dominio ingresado: $domain"

# Crear zona DNS
ConfigurarZonaDNS -domain $domain

# Solicitar IP del cliente
$ipclient = Read-Host "Ingrese la IP del cliente"

# Agregar registros A
AgregarRegistrosA -domain $domain -ipclient $ipclient

Write-Output "¡Servidor DNS configurado exitosamente!"
