Get-Service -Name "LSM" | Get-Member
Get-Service -Name "LSM" | Get-Member -MemberType Property
Get-Item .\test.txt | Get-Member -MemberType Method
Get-Item .\test.txt | Select-Object Name, Length
Get-Service | Select-Object -Last 5
Get-Service | Select-Object -First 5
Get-Service | Where-Object {$_.Status -eq "Running"}
(Get-Item .\test.txt).IsReadOnly
(Get-Item .\test.txt).IsReadOnly = 1
(Get-Item .\test.txt).IsReadOnly
Get-ChildItem *.txt
$miObjeto = New-Object PSObject
$miObjeto | Add-Member -MemberType NoteProperty -Name Nombre -Value "Miguel"
$miObjeto | Add-Member -MemberType NoteProperty -Name Edad -Value 23
$miObjeto | Add-Member -MemberType ScriptMethod -Name Saludar -Value { Write-Host "¡Hola Mundo!" }
$miObjeto = New-Object -TypeName PSObject -Property @{
    Nombre = "Miguel"
    Edad = 23
}
$miObjeto | Add-Member -MemberType ScriptMethod -Name Saludar -Value { Write-Host "¡Hola Mundo!" }
$miObjeto | Get-Member