<#
    TRABAJO PRÁCTICO Nº1, EJERCICIO 1 PARTE B. ENTREGA.
    
#>

<# 

.SYNOPSIS
    Guarda los procesos en ejecución sobre la computadora local en un archivo de texto y muestra por pantalla una cantidad de procesos.

.DESCRIPTION
    El script guarda todos los procesos que se están ejecutando sobre la computadora en un archivo de texto llamado "procesos.txt".
    El mismo contendrá tanto el ID como el Nombre de cada uno de los procesos con un formato de lista; es decir, se muestra una propiedad por línea por cada proceso.

    El Script muestra por pantalla cierta cantidad de procesos.

.PARAMETER pathsalida
    Por defecto la ruta de salida para el archivo "procesos.txt" es el directorio en el que se esté posicionado.

.PARAMETER cantidad
    Por defecto la cantidad de procesos a mostrar en pantalla es de 3 (tres).

.EXAMPLE
    PS C:\>procesos.ps1
    AcroRd32 - 2944
    AcroRd32 - 7436
    aips - 1784

    El Script guarda el archivo "procesos.txt" en la ruta "C:\" y muestra 3 (tres) procesos que se están ejecutando.

.EXAMPLE

    PS C:\>procesos.ps1 -pathsalida "C:\Procesos" -cantidad 10
    AcroRd32 - 2944
    AcroRd32 - 7436
    aips - 1784
    ApplicationFrameHost - 2644
    armsvc - 6784
    atieclxx - 5616
    atiesrxx - 2180
    audiodg - 4264
    Calculator - 4092
    CCC - 4188

    El Script guarda el archivo "procesos.txt" en la ruta "C:\Procesos" y muestra 10 (diez) procesos que se están ejecutando.

.EXAMPLE
    PS C:\>procesos.ps1 "C:\Procesos" 5
    AcroRd32 - 2944
    AcroRd32 - 7436
    aips - 1784
    ApplicationFrameHost - 2644
    armsvc - 6784

    El Script guarda el archivo "procesos.txt" en la ruta "C:\Procesos" y muestra 5 (cinco) procesos que se están ejecutando, sin necesidad de explicitar los parámetros.

.INPUTS
    Se puede insertar un path seguido por la cantidad de procesos a mostrar, respetando el orden. Ver ejemplo 3.

.OUTPUTS
    Salida por pantalla de cierta cantidad arbitraria de procesos en ejecución.
    Salida por archivo de texto "procesos.txt" con todos los procesos en ejecución.
    
.NOTES
    Debido a que carecía de sentido que existiera un parámetro '$pathsalida' y se utilizara sólo para verificar si es válido o no, decidimos modificar una línea de código, para efectivamente el usuario al pasar por parámetro una ruta válida, el archivo de texto se guarde allí.

    ANTES DE LA MODIFICACIÓN:
    $proceso | Format-List -Property Id,Name >> \procesos.txt
    
    DESPUÉS DE LA MODIFICACIÓN:
    $proceso | Format-List -Property Id,Name >> $pathsalida\procesos.txt
    
    Ambas líneas dentro del ciclo 'foreach'.

.LINK
    Versión 1.0 

#>

Param
(
    [Parameter(Position = 1)] #No se definen parámetros obligatorios, ya que los mismos ya tienen valores predefinidos.
    [String] $pathsalida = ".",
    [Parameter(Position = 2)]
    $cantidad = 3 #No se define el tipo de dato de este parámetro. Se verificará dentro del script con un mensaje correspondiente.
)

# ---VALIDACIONES--- No se valida la cantidad de parámetros ya que tienen valores por defecto, en caso de no existir.

if($cantidad.GetType().FullName -NE "System.Int32" -AND 
    ($cantidad -GE 0)){
    Write-Host "La cantidad de procesos a mostrar no es un dato válido."
    break
}<#Verificación de si la cantidad de procesos a mostrar es un dato válido.
    Se valida la cantidad de procesos a mostrar, pudiendo ser 0 (cero), si no se quiere mostrar proceso alguno, en adelante.
    Tener en cuenta que PS verifica:
            *Si se ingresa un número flotante, redondea a un valor entero;
            *Si se ingresa un caracter no númerico o un número demasiado grande o pequeño, genera un error.#>

$existe = $true
$caractPath = [System.IO.Path]::GetInvalidPathChars()
<# Inicializaciones: 
    *Flag de la existencia de la ruta de salida;
    *Generación de un vector de caracteres especiales que no son permitidos en los path y hacen que el cmdlet 'Test-Path' falle en su verificación del string de entrada.#>

for($i = 0; $i -LT $caractPath.Count;  $i++){
    if($pathsalida.Contains($caractPath[$i])){
        $existe = $false
        break
    }
}#Verificación de si el string de entrada contiene al menos un caracter de los no permitidos en un path.

if($existe -AND -NOT[string]::IsNullOrWhiteSpace($pathsalida)){
    $existe = Test-Path $pathsalida
}#Verificación de si el string de entrada es nulo o contiene sólo blancos.
else{
    $existe = $false
}

if ($existe)
{ # ---SI TODO ES CORRECTO, SE PROCEDE CON EL OBJETIVO DEL SCRIPT---
    $listaproceso = Get-Process
    foreach ($proceso in $listaproceso)
    {
        $proceso | Format-List -Property Id, Name >> $pathsalida\procesos.txt
    }
    for ($i = 0; $i -LT $cantidad ; $i++)
    {
        Write-Host $listaproceso[$i].Name - $listaproceso[$i].Id
    }
}
else
{
    Write-Host "El path no existe"
}

<#
        FIN DE ARCHIVO
#>
