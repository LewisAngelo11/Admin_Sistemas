# Importar funciones
. C:\Users\Administrador\Documents\Funciones_FTP.ps1

# Inicializar carpetas y montar unidades
Configure-FTPServer
create_groups
Enabled-Autentication
Enabled-SSL
Enabled-AccessAnonym
Restart-Site
# create_files_FTP

# Menú interactivo
while ($true) {
    Write-Host "`n===== GESTIÓN DE USUARIOS FTP ====="
    Write-Host "1) Crear un usuario FTP"
    Write-Host "2) Cambiar usuario de grupo"
    Write-Host "3) Eliminar usuario"
    Write-Host "0) Salir"
    $option = Read-Host "Seleccione una opción"

    switch ($option) {
        "1" {
            $user = Read-Host "Ingrese el nombre de usuario"
            $passwd = Read-Host "Ingrese la contraseña"
            $group = Read-Host "Asignele un grupo al usuario creado (reprobados/recursadores)"
            if ($group -eq "reprobados" -or $group -eq "recursadores") {
                create_user -Username $user -Password $passwd -Group $group
                add_user_to_group -Username $user -GroupName $group
                Restart-Site
                break # Salir del bucle si el grupo es válido
            } else {
                Write-Output "Grupo no válido. Debe ser 'reprobados' o 'recursadores'."
            }
        }
        "2" {
            $user = Read-Host "Ingrese el nombre de usuario"
            $group = Read-Host "Ingrese el nombre del grupo al que se va a cambiar"
            #change_user_group -Username $user -NewGroup $group
            Remove-LocalGroupMember -Member $user -Group "recursadores"
            rm "C:\FTPRoot\LocalUser\$user\recursadores" -Recurse -Force
            #add_user_to_group -Username $user -GroupName $group
            New-Item -ItemType Junction -Path "C:\FTPRoot\LocalUser\$user\$group" -Target "C:\FTPRoot\$group"
            icacls "C:\FTPRoot\LocalUser\$user\$group" /grant "$($user):(OI)(CI)F"
            icacls "C:\FTPRoot\$group" /grant "$($user):(OI)(CI)F"
            Restart-Site
        }
        "3" { 
            $user = Read-Host "Ingresa el usuario a eliminar"
            
            delete_user -Username $user
            Restart-Site
        }
        "0" {
            break
        }
        default { Write-Host "Opción inválida" }
    }
}