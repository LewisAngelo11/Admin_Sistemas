function Configure-ini($lines, $section, $key, $value){

    #Esto confugrua el archivo de configuracion, si alguien pregunra ehm... un hechicero lo hizo
    $sectionIndex = $lines.IndexOf("[$section]")
    if($sectionIndex -lt 0) {
        $lines += "[$section]", "$key=$value"
    } else {
        $i = $sectionIndex + 1
        $found = $false
        while ($i -lt $lines.Length -and $lines[$i] -notmatch "^\[.*\]"){
            if ($lines[$i] -match "^$key="){
                $lines[$i] = "$key=$value"
                $found = $true
                break
            }
            $i++
        }
        if(-not $found){
            $lines = @(
                $lines[0..$sectionIndex]
                "$key=$value"
                $lines[($sectionIndex + 1)..($lines.Length - 1)]
            )
        }
    }
    return $lines
}

function install-squirrel{
    Install-WindowsFeature -name Web-Server, Web-Common-Http, Web-Static-Content, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Http-Logging, Web-Request-Monitor, Web-Http-Redirect, Web-Filtering, Web-Performance, Web-Stat-Compression, Web-Security, Web-Mgmt-Console -IncludeManagementTools
    
    # Descargar Xammp
    Write-Host "Para ejecutar squirrelmail se necesita un servidor http que soporte php, se utilizará xampp para esto "
    curl.exe -L "https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/5.6.14/xampp-portable-win32-5.6.14-4-VC11-installer.exe/download" -o "C:\Users\Administrador\Downloads\xampp-portable-win32-5.6.14-4-VC11-installer.exe"
    Start-Process "C:\Users\Administrador\Downloads\xampp-portable-win32-5.6.14-4-VC11-installer.exe" -Wait
    
    # Descargar squirrelmail
    Write-Host "Descargando squirrelmail" 
    curl.exe -L "https://sourceforge.net/projects/squirrelmail/files/stable/1.4.22/squirrelmail-webmail-1.4.22.zip/download?use_mirror=psychz" -o "C:\Users\Administrador\Downloads\squirrelmail.zip"

    Expand-Archive -Path "C:\Users\Administrador\Downloads\squirrelmail.zip" -DestinationPath "C:\xampp\htdocs\"
    # Se renombra la carpeta descomprimida a squirrelmail
    Rename-Item -Path C:\xampp\htdocs\squirrelmail-webmail-1.4.22 -NewName "squirrelmail"

    # Renombrar y editar el archivo de configuración
    Rename-Item -Path C:\xampp\htdocs\squirrelmail\config\config_default.php -NewName "config.php"            #Aqui el dominio que se configuro en la instalacion
    (Get-Content "C:\xampp\htdocs\squirrelmail\config\config.php") -replace '\$domain\s*=\s*''[^'']+'';', '$domain = ''adad.com'';' | Set-Content "C:\xampp\htdocs\squirrelmail\config\config.php"
    (Get-Content "C:\xampp\htdocs\squirrelmail\config\config.php") -replace '\$data_dir\s*=\s*''[^'']+'';', '$data_dir = ''C:/xampp/htdocs/squirrelmail/data/'';' | Set-Content "C:\xampp\htdocs\squirrelmail\config\config.php"

    
    Write-Host "Squirrelmail instalado y configardo"
    #Para probar squirrelmail, se debe abrir xampp e iniciar apache
    # Luego ir al navegador y escribir localhost (o la IP del servidor), squirrelmail
    # Y tener el puerto 80 o 443 libre
}


# Main
while($true){
    Write-Host "Configuracion de servidor de correo, Selecciona una opcion [1-5]"
    Write-Host "1. Instalar Mercury"
    Write-Host "2. Configurar usuarios"
    Write-Host "3. Instalar squirrelmail"
    Write-Host "0. Salir"
    $opc = Read-Host "Opcion:"

    if($opc -eq "0"){
        Write-Output "Saliendo..."
        break
    } elseif ($opc -notmatch "^\d+$"){
        Write-Output "Debes ingresar un número."
    } else {
        switch($opc){
            '1'{
                # Instalar Mercury
            }
            '2'{
                Write-Host "Abre la ventana de Mercury Ve a Configuration -> Magae Local Users -> Add y ahi creas el usuario"
            }
            '3'{
                install-squirrel
            }
            default{
                Write-Host "Opción no válida."
            }
        }
    }
}