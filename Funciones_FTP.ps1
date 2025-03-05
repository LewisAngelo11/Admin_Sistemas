Install-WindowsFeature Web-FTP-Server -IncludeAllSubFeature -Verbose
Import-Module WebAdministration
$FTPSiteName = 'Default FTP Site'
$FTPRootDir = 'D:\FTPRoot'
$FTPPort = 21
New-WebFtpSite -Name $FTPSiteName -Port $FTPPort -PhysicalPath $FTPRootDir


function create_groups() {
    $groups = @("reprobados", "recursadores")
    $ADSI = [ADSI]"WinNT://$env:ComputerName"

    foreach ($group in $groups) {
        # Verificar si el grupo ya existe
        if ($ADSI.Children | Where-Object { $_.Name -eq $group }) {
            Write-Output "El grupo '$group' ya existe."
        } else {
            # Crear el grupo si no existe
            $FTPUserGroup = $ADSI.Create("Group", "$group")
            $FTPUserGroup.SetInfo()
            Write-Output "Grupo '$group' creado correctamente."
        }
    }
}

function create_user ([String]$Username, [String]$Password, [String]$Group) {
    $ADSI = [ADSI]"WinNT://$env:ComputerName"

    # Verificar si el usuario ya existe
    if ($ADSI.Children | Where-Object { $_.Name -eq $Username }) {
        Write-Output "El usuario '$Username' ya existe."
    } else {
        # Crear usuario
        $CreateFTPUser = $ADSI.Create("User", "$Username")
        $CreateFTPUser.SetPassword("$Password")
        $CreateFTPUser.SetInfo()
        Write-Output "Usuario '$Username' creado correctamente."
    }
}

function add_user_to_group([String]$Username, [String]$GroupName) {
    $UserAccount = New-Object System.Security.Principal.NTAccount($Username)
    $SID = $UserAccount.Translate([System.Security.Principal.SecurityIdentifier])
    $Group = [ADSI]"WinNT://$env:ComputerName/$GroupName,Group"
    $UserADSI = [ADSI]"WinNT://$SID"

    try {
        $Group.Add($UserADSI.Path)
        Write-Output "Usuario '$Username' agregado correctamente al grupo '$GroupName'."
    } catch {
        Write-Output "Error al agregar el usuario '$Username' al grupo '$GroupName'."
    }
}


function Configure-FTPServer {
    param(
        [string]$FTPSiteName = 'Default FTP Site',
        [string]$FTPRootDir = 'D:\FTPRoot',
        [int]$FTPPort = 21
    )

    # 1. Verificar si IIS está instalado
    if (-not (Get-WindowsFeature -Name Web-Server).Installed) {
        Write-Host "IIS no está instalado. Instalando IIS..."
        Install-WindowsFeature Web-Server -IncludeManagementTools -Verbose
    } else {
        Write-Host "IIS ya está instalado."
    }

    # 2. Verificar si la característica Web-FTP-Server está instalada
    if (-not (Get-WindowsFeature -Name Web-FTP-Server).Installed) {
        Write-Host "La característica FTP Server no está instalada. Instalando..."
        Install-WindowsFeature Web-FTP-Server -IncludeAllSubFeature -Verbose
    } else {
        Write-Host "FTP Server ya está instalado."
    }

    # 3. Importar el módulo WebAdministration si no está importado
    if (-not (Get-Module -ListAvailable -Name WebAdministration)) {
        Write-Host "Importando el módulo WebAdministration..."
        Import-Module WebAdministration
    } else {
        Write-Host "El módulo WebAdministration ya está importado."
    }

    # 4. Validar que el directorio raíz exista, si no, crearlo
    if (-not (Test-Path $FTPRootDir)) {
        Write-Host "El directorio raíz FTP '$FTPRootDir' no existe. Creándolo..."
        New-Item -ItemType Directory -Force -Path $FTPRootDir
    } else {
        Write-Host "El directorio raíz FTP '$FTPRootDir' ya existe."
    }

    # 5. Validar que el puerto esté disponible (puerto 21)
    $portInUse = Test-NetConnection -ComputerName 'localhost' -Port $FTPPort
    if ($portInUse.TcpTestSucceeded) {
        Write-Host "El puerto $FTPPort ya está en uso, eligiendo otro puerto..."
        $FTPPort = 2121 # Cambiar al puerto alternativo 2121 si está ocupado
    } else {
        Write-Host "Puerto $FTPPort disponible para usar."
    }

    # 6. Crear el sitio FTP si no existe
    $existingFtpSite = Get-WebFtpSite | Where-Object { $_.Name -eq $FTPSiteName }
    if ($existingFtpSite) {
        Write-Host "El sitio FTP '$FTPSiteName' ya existe."
    } else {
        New-WebFtpSite -Name $FTPSiteName -Port $FTPPort -PhysicalPath $FTPRootDir
        Write-Host "Sitio FTP '$FTPSiteName' creado exitosamente."
    }
}