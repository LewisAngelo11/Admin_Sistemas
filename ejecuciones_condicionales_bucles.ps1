$numero = 2
if ( $numero -ge 3 )
{
    Write-Output "El número [$numero] es mayor o igual que 3"
}
elseif ( $numero -lt 2 )
{
    Write-Output "El número [$numero] es menor que 2"
}
else
{
    Write-Output "El número [$numero] es igual a 2"
}

$PSVersionTable


switch (3)
{
    1 {"[$_] es uno."}
    2 {"[$_] es dos."}
    3 {"[$_] es tres."}
    4 {"[$_] es cuatro."}
    3 {"[$_] tres de nuevo."}

}

switch (1, 5)
{
    1 {"[$_] es uno."}
    2 {"[$_] es dos."}
    3 {"[$_] es tres."}
    4 {"[$_] es cuatro."}
    5 {"[$_] es cinco"}

}

switch ("seis")
{
    1 {"[$_] es uno."}
    2 {"[$_] es dos."}
    3 {"[$_] es tres."}
    4 {"[$_] es cuatro."}
    5 {"[$_] es cinco."}
    "se*" {"[$_] coincide con se*."}
    Default {
        "No hay coincidencias con [$_]"
    }
}

$email = 'antonio.yanes@udc.es'
$email2 = 'antonio.yanez@usc.gal'
$url = 'https://www.dc.fi.udc.es/~afyanez/Docencia/2023'
switch -Regex($url, $email, $email2)
{
    '^\w+\.\w+@(udc|usc|edu)\.es|gal$' {"[$_] es una direccion de correo electronico academica"}
    '^ftp\://.*$' {"[$_] es una direccion ftp"}
    '^(http[s]?)\://.*$' {"[$_] es una direccion web, que utiliza [$($matches[1])]"}
}

1 -eq "1.0"
"1.0" -eq 1

for (($i = 0), ($j = 0); $i -lt 5; $i++)
{
    "`$i:$i"
    "`$j:$j"
}

for ($($i = 0;$j = 0); $i -lt 5; $($i++;$j++))
{
    "`$i:$i"
    "`$j:$j"
}

$ssoo = "freebsd", "openbsd", "solaris", "fedora", "ubuntu", "netbsd"
foreach ($so in $ssoo)
{
    Write-Host $so
}

foreach ($archivo in Get-ChildItem)
{
    if ($archivo.lenght -ge 10KB)
    {
        Write-Host $archivo -> [($archivo.lenght)]
    }
}

$num = 0
while ($num -ne 3)
{
    $num++
    Write-Host $num
}

while ($num -ne 5)
{
    if ($num -eq 1) { $num = $num + 3 ; Continue}
    $num++
    Write-Host $num
}

$valor = 5
$multiplicacion = 1
do
{
    $multiplicacion = $multiplicacion * $valor
    $valor--
}
while ($valor -gt 0)
Write-Host $multiplicacion

$valor = 5
$multiplicacion = 1
do
{
    $multiplicacion = $multiplicacion * $valor
    $valor--
}
until ($valor -eq 0)
Write-Host $multiplicacion

$num = 10
for ($i = 2; $i -lt 10; $i++)
{
    $num = $num+$i
    if ($i -eq 5) { Break }
}
Write-Host $num
Write-Host $i

$cadena = "Hola, buenas tardes"
$cadena2 = "Hola, buenas noches"
switch -Wildcard ($cadena, $cadena2)
{
    "Hola, buenas*" {"[$_] coincide con [Hola, buenas*]"}
    "Hola, bue*" {"[$_] coincide con [Hola, bue*]"}
    "Hola,*" {"[$_] coincide con [Hola,*]"; Break }
    "Hola, buenas tardes" {"[$_] coincide con [Hola, buenas tardes]"}
}

$num = 10
for ($i = 2; $i -lt 10; $i++)
{
    if ($i -eq 5) { Continue }
    $num = $num+$i
}
Write-Host $num
Write-Host $i

$cadena = "Hola, buenas tardes"
$cadena2 = "Hola, buenas noches"
switch -Wildcard ($cadena, $cadena2)
{
    "Hola, buenas*" {"[$_] coincide con [Hola, buenas*]"}
    "Hola, bue*" {"[$_] coincide con [Hola, bue*]"; Continue}
    "Hola,*" {"[$_] coincide con [Hola,*]" }
    "Hola, buenas tardes" {"[$_] coincide con [Hola, buenas tardes]"}
}