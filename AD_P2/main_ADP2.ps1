function Instalar-ActiveDirectory(){
    if(-not((Get-WindowsFeature -Name AD-Domain-Services).Installed)){
        Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
    }
    else{
        Write-Host "Active Directory ya se encuentra instalado, omitiendo instalación..."
    }
}

function Configurar-DominioAD(){
    if((Get-WmiObject Win32_ComputerSystem).Domain -eq "5demayo.com"){
        Write-Host "El dominio ya se encuentra configurado, omitiendo configuración..."
    }
    else{
        Import-Module ADDSDeployment
        Install-ADDSForest -DomainName "5demayo.com" -DomainNetbiosName "5DEMAYO" -InstallDNS
    }
}

function Crear-UnidadesOrganizativas(){
    try {
        if((Get-ADGroup -Filter "Name -eq 'cuates'") -and (Get-ADGroup -Filter "Name -eq 'nocuates'") -and (Get-ADOrganizationalUnit -Filter "Name -eq 'cuates'") -and (Get-ADOrganizationalUnit -Filter "Name -eq 'nocuates'")){
            Write-Host "Los grupos ya se encuentran creados en este equipo"
        }
        else{
            New-ADGroup -Name "cuates" -SamAccountName "cuates" -GroupScope Global -GroupCategory Security
            New-ADGroup -Name "nocuates" -SamAccountName "nocuates" -GroupScope Global -GroupCategory Security
            Write-Host "Grupos creados correctamente"
        }
    }
    catch {
        Write-Host $Error[0].ToString()
    }
}

function Es-ContrasenaValida($contrasena) {
    return ($contrasena.Length -ge 8 -and
            $contrasena -match '[A-Z]' -and
            $contrasena -match '[a-z]' -and
            $contrasena -match '\d' -and
            $contrasena -match '[^a-zA-Z\d]')
}

function Crear-Usuario(){
    try {
        $nombreUsuario = Read-Host "Ingresa el nombre de usuario"
        $contrasena = Read-Host "Ingresa la contrasena"
        $grupo = Read-Host "Ingresa el grupo de la que sera parte el usuario (grupo1/grupo2)"
        if(($grupo -ne "cuates") -and ($grupo -ne "nocuates")){
            Write-Host "Ingresa un grupo valido (cuates/nocuates)"
        }
        elseif(-not(Es-ContrasenaValida -contrasena $contrasena)){
            Write-Host "El password no es lo suficientemente seguro"
        }
        else{
            New-ADUser -Name $nombreUsuario -GivenName $nombreUsuario -Surname $nombreUsuario -SamAccountName $nombreUsuario -UserPrincipalName "$nombreUsuario@5demayo.com" -Path "OU=$grupo,DC=5demayo,DC=com" -ChangePasswordAtLogon $true -AccountPassword (ConvertTo-SecureString $contrasena -AsPlainText -Force) -Enabled $true
            Add-ADGroupMember -Identity $grupo -Members $nombreUsuario
            Configurar-Horarios -nombreUsuario $nombreUsuario -grupo $grupo
            Write-Host "Cuenta creada correctamente"
        }
    }
    catch {
        Write-Host $Error[0].ToString()
    }
}

function Configurar-PermisosAplicaciones(){ 
    try {
        # Los nombres de las políticas no tienen nada que ver, pero así funcionan
        # Bloquear bloc de notas para el grupo2
        # Esta parte funciona correctamente, bloquea el bloc de notas
        if(Get-GPO -Name "Bloquear solo notepad" -ErrorAction SilentlyContinue){
            Write-Host "La regla para el grupo2 ya se encuentra creada"
        }
        else{
            New-GPO -Name "Bloquear solo notepad" | Out-Null
            New-GPLink -Name "Bloquear solo notepad" -Target "OU=nocuates,DC=5demayo,DC=com"

            Set-GPRegistryValue -Name "Bloquear solo notepad" `
            -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
            -ValueName "DisallowRun" -Type DWord -Value 1

            Set-GPRegistryValue -Name "Bloquear solo notepad" `
            -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" `
            -ValueName "1" -Type String -Value "notepad.exe"
 
            Set-GPPermissions -Name "Bloquear solo notepad" -TargetName "nocuates" -TargetType Group -PermissionLevel GpoApply

            Write-Host "Regla para el grupo dos creada correctamente"
        }

        # Bloquear todo menos bloc de notas para el grupo1
        if(Get-GPO -Name "Permitir solo notepad" -ErrorAction SilentlyContinue){
            Write-Host "La regla para el grupo1 ya se encuentra creada"
        }
        else{
            New-GPO -Name "Permitir solo notepad" | Out-Null
            New-GPLink -Name "Permitir solo notepad" -Target "OU=grupo1,DC=dia-nino,DC=com"

            Set-GPRegistryValue -Name "Permitir solo notepad" `
            -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
            -ValueName "RestrictRun" -Type DWord -Value 1

            Set-GPRegistryValue -Name "Permitir solo notepad" `
            -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\RestrictRun" `
            -ValueName "1" -Type String -Value "notepad.exe"

            Set-GPPermission -Name "Permitir solo notepad" -TargetName "cuates" -TargetType Group -PermissionLevel GpoApply

            Write-Host "Regla para el grupo uno creada correctamente"
        }
    }
    catch {
        Write-Host $Error[0].ToString()
    }
}

function Configurar-Auditoria(){
    try {
        $nombreGpo = "Auditoria dominio"
        if (-not (Get-GPO -Name $nombreGpo -ErrorAction SilentlyContinue)) {
            New-GPO -Name $nombreGpo
            New-GPLink -Name $nombreGpo -Target "DC=5demayo,DC=com"

            Set-GPRegistryValue -Name $nombreGpo `
            -Key "HKLM\Software\Policies\Microsoft\Windows\System\Audit" `
            -ValueName "Auditar" -Type DWord -Value 1

            AuditPol /set /subcategory:"Acceso de servicio del directorio" /success:enable /failure:enable
            AuditPol /set /subcategory:"Cambios de servicio de directorio" /success:enable /failure:enable

            Write-Host "Configuracion de auditoria realizada correctamente "
        }
        else {
            Write-Host "La regla de auditoria ya se encuentra creada"
        }
    }
    catch {
        Write-Host $Error[0].ToString()
    }
}

function Configurar-ContrasenasSeguras(){
    try {
        Set-ADDefaultDomainPasswordPolicy -Identity "5demayo.com" `
        -MinPasswordLength 8 `
        -ComplexityEnabled $true `
        -PasswordHistoryCount 1 `
        -MinPasswordAge "1.00:00:00" `
        -MaxPasswordAge "30.00:00:00"

        Write-Host "Regla de passwords seguros configurada correctamente"
    }
    catch {
        Write-Host $Error[0].ToString()
    }
}

function Configurar-Horarios($nombreUsuario, $grupo){
    try {
        if($grupo -eq "cuates"){
            # Horas de 8am a 3pm
            [byte[]]$horasGrupoUno = @(0,128,63,0,128,63,0,128,63,0,128,63,0,128,63,0,128,63,0,128,63)
            Get-ADUser -Identity $nombreUsuario | Set-ADUser -Replace @{logonhours = $horasGrupoUno}
            Write-Host "Se ha configurado el horario del grupo uno para $nombreUsuario"
        }
        elseif($grupo -eq "cuatesno"){
            # Horas de 3pm a 2am
            [byte[]]$horasGrupoDos = @(255,1,192,255,1,192,255,1,192,255,1,192,255,1,192,255,1,192,255,1,192) 
            Get-ADUser -Identity $nombreUsuario | Set-ADUser -Replace @{logonhours = $horasGrupoDos}
            Write-Host "Se ha configurado el horario del grupo dos para $nombreUsuario"
        }
        else{
            Write-Host "Grupo invalido"
        }
    }
    catch {
        Write-Host $Error[0].ToString()
    }
}

function Configurar-AlmacenamientoArchivos(){
    Import-Module GroupPolicy
    try {
        if (Get-GPO -Name "Cuota5MbGrupoUno" -ErrorAction SilentlyContinue) {
            Write-Host "La politica de configuracion de archivos para el grupo uno ya existe"
        } else {
            $gpo1 = "Cuota5MbGrupoUno"
            New-GPO -Name $gpo1
            New-GPLink -Name $gpo1 -Target "OU=cuates,DC=5demayo,DC=com" -Enforced "Yes"

            Set-GPRegistryValue -Name $gpo1 -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "EnableProfileQuota" -Type DWord -Value 1
            Set-GPRegistryValue -Name $gpo1 -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "MaxProfileSize" -Type DWord -Value 5000
            Set-GPRegistryValue -Name $gpo1 -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "WarnUser" -Type DWord -Value 1
            Set-GPRegistryValue -Name $gpo1 -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "WarnUserTimeout" -Type DWord -Value 10
            Set-GPRegistryValue -Name $gpo1 -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "ProfileQuotaMessage" -Type String -Value "Has excedido el limite de 5 MB por perfil. Libera espacio para evitar problemas."

            Write-Host "Regla para el grupo uno configurada correctamente"
        }

        if (Get-GPO -Name "Cuota10MbGrupo2" -ErrorAction SilentlyContinue) {
            Write-Host "La politica de configuracion de archivos para el grupo dos ya existe"
        } else {
            $gpo2 = "Cuota10MbGrupoDos"
            New-GPO -Name $gpo2
            New-GPLink -Name $gpo2 -Target "OU=nocuates,DC=5demayo,DC=com" -Enforced "Yes"

            Set-GPRegistryValue -Name $gpo2 -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "EnableProfileQuota" -Type DWord -Value 1
            Set-GPRegistryValue -Name $gpo2 -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "MaxProfileSize" -Type DWord -Value 10000
            Set-GPRegistryValue -Name $gpo2 -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "WarnUser" -Type DWord -Value 1
            Set-GPRegistryValue -Name $gpo2 -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "WarnUserTimeout" -Type DWord -Value 10
            Set-GPRegistryValue -Name $gpo2 -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "ProfileQuotaMessage" -Type String -Value "Has excedido el limite de 10 MB por perfil. Libera espacio para evitar problemas."

            Write-Host "Regla para el grupo dos configurada correctamente"
        }

        Write-Host "Reglas de almacenamiento configuradas correctamente"
    }
    catch {
        Write-Host $Error[0].ToString()
    }
}

while($true){
    Write-Host "Menu de opciones"
    Write-Host "1. Instalar y configurar Active Directory"
    Write-Host "2. Crear grupos"
    Write-Host "3. Crear usuario"
    Write-Host "4. Configurar politicas de aplicaciones"
    Write-Host "5. Configurar auditoria de eventos y passwords seguros"
    Write-Host "6. Configurar almacenamiento de archivos"
    Write-Host "7. Salir"
    $opc = Read-Host "Selecciona una opcion"

    if($opc -eq "7"){
        Write-Host "Saliendo..."
        break
    }

    switch($opc){
        "1"{
            Instalar-ActiveDirectory
            Configurar-DominioAD
        }
        "2"{
            Crear-UnidadesOrganizativas
        }
        "3"{
            Crear-Usuario
        }
        "4"{
            Configurar-PermisosAplicaciones
        }
        "5" {
            Configurar-Auditoria
            Configurar-ContrasenasSeguras
        }
        "6"{
            Configurar-AlmacenamientoArchivos
        }
        default { Write-Host "Selecciona una opcion valida (1..7)"}
    }
    Write-Host ""
}