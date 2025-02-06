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
$mensaje = (Test-Path $path) ? "Path existe" : "Path no encontrado"

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
    '^(http[s]?\://.*$' {"[$_] es una direccion web, que utiliza [$($matches[1])]"}
}