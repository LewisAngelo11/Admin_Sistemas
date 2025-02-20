# Instala el SSH servidor en el S.O.
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Iniciar el servicio ssh
Start-Service sshd

Set-Service -Name sshd -StartupType 'Automatic'

# Verifica si ya existe una regla de entrada en el firewall que permita la conexion en el puerto 22
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "La regla de firewall 'OpenSSH-Server-In-TCP' no existe, creando la regla..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "La regla de firewall 'OpenSSH-Server-In-TCP' ya ha sido creada."
}