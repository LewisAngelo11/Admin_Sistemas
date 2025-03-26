function Habilitar-SSL(){
    param (
        [string]$numeroCert
    )

    Set-ItemProperty "IIS:\Sites\FTP Site" -Name ftpServer.security.ssl.controlChannelPolicy -Value "SslAllow"
    Set-ItemProperty "IIS:\Sites\FTP Site" -Name ftpServer.security.ssl.dataChannelPolicy -Value "SslAllow"
    Set-ItemProperty "IIS:\Sites\FTP Site" -Name ftpServer.security.ssl.serverCertHash -Value $numeroCert
}

function generar-certificado(){
    param (
        [string]$DnsName = "WIN-AC2DN26G1LP"  # Nombre del servidor FTP
    )

    # Generar el certificado auto-firmado
    $cert = New-SelfSignedCertificate -DnsName $DnsName -CertStoreLocation "Cert:\LocalMachine\My"

    # Mover el certificado a la lista de certificados confiables (Root)
    $rootStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root", "LocalMachine")
    $rootStore.Open("ReadWrite")
    $rootStore.Add($cert)
    $rootStore.Close()

    # Mostrar información del certificado
    Write-Output "Certificado generado exitosamente"
    Write-Output "Nombre: $($cert.Subject)"
    Write-Output "Thumbprint: $($cert.Thumbprint)"
    Write-Output "Expira el: $($cert.NotAfter)"
    
    # Devolver el Thumbprint del certificado
    return $cert.Thumbprint
}
