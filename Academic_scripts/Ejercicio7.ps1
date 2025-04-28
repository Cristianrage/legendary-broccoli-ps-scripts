<#
TRABAJO PRÁCTICO Nº1, EJERCICIO 7. ENTREGA.

#>

<#
.SYNOPSIS
    Analiza una matriz cargada en un archivo de texto plano y devuelve el tipo de matriz que es (matriz fila, matriz columna, matriz cuadrada o rectangular, matriz identidad y matriz nula).

.DESCRIPTION
     El script pide al usuario que ingrese el separador de columna que tiene el archivo de la matriz y luego el path del archivo donde se encuentra la misma.
     Luego de validar los paths ingresados exitosamente, analiza la matriz y devuelve el resultado del mismo.

.PARAMETER separador
    El caracter que separa los elementos de cada fila de la matriz. No tiene nada cargado por defecto.

.PARAMETER origenPath
    El path del archivo de texto que contiene la matriz. No tiene nada cargado por defecto.
     
.EXAMPLE
    PS C:\> .\Ejercicio7.ps1 -separador ',' -origenPath 'C:\Matriz.txt'

    -Salida:

    Matriz cuadrada de orden 5
    Matriz nula

    Es una matriz cuyas columnas estan separadas por el caracter ','.
    En este caso nos devuelve que la matriz es cuadrada (igual numero de filas y de columnas) y aclara el orden. Además informa que es matriz nula (todas sus componentes son cero).

.EXAMPLE
    PS C:\> .\Ejercicio7.ps1 -separador '|' -origenPath 'C:\Matriz.txt'

    -Salida:

    Matriz cuadrada de orden 4
    Es matriz identidad

    Matriz cuyas columnas estan separadas por el caracter '|'. En este caso se trata de una matriz cuadrada que tambien es identidad.

.INPUTS
    Se debe ingresar el caracter separador y el path del archivo de texto que contiene la matriz a evaluar.

.OUTPUTS
    Muestra por pantalla la clasificación de la matriz correspondiente.

.NOTES
    El script supone que la ruta del archivo de texto que se cargue por parámetro, será uno que respete el formato de la matriz:
        *Columnas separadas por el caracter separador. Es decir: #<sep>#<sep> etc.
        *Al finalizar una fila, se realizará un salto de línea.
    Si el archivo contiene cualquier otro tipo de información (en vez de números) o no tiene el formato correspondiente, el script arrojará datos erróneos.

.LINK
    Versión 1.0 

#>

Param
(
    [Parameter(Position =1, Mandatory = $true)][String]$separador, 
    [Parameter(Mandatory = $true)]$origenPath
)

$caractPath = [System.IO.Path]::GetInvalidPathChars()
$alerta = $true
[String []]$matriz = @() #Si la matriz es Fila, tomará el contenido como una cadena de caracteres y no como array.

# ---VALIDACIONES---
if( -NOT[string]::IsNullOrWhiteSpace($origenPath) -AND 
    $origenPath.GetType().FullName -EQ "System.String"){

    for($i = 0; $i -LT $caractPath.Count;  $i++){
        if($origenPath.Contains($caractPath[$i])){
            $alerta = $false
            break
        }
    }
    if($alerta -AND (Test-Path $origenPath)){
        $matriz = Get-Content $origenPath -ErrorAction SilentlyContinue -ErrorVariable errores
        if($errores){
            $Host.UI.WriteErrorLine("El path de origen no arroja un archivo de texto válido.")
            Exit
        }
    }        
    else{
        $Host.UI.WriteErrorLine("El path de origen no es válido.")
        Exit
    }
}
else{
    $Host.UI.WriteErrorLine("El parámetro de ruta de origen no es un string válido.")
    Exit
}
# ---SI TODO ES CORRECTO, SE PROCEDE CON EL OBJETIVO DEL SCRIPT---

$cantCol = ($matriz[0].Split($separador)).Count #Cuento la cantidad de columnas haciendo un split de la primer fila por el separador.

$esIdentidad = $esNula = $true #Flags

for($i = 1; $i -LE ($matriz.count) - 1; $i++){
     $fila = $matriz[$i].Split($separador)#Por cada fila que pasa realiza un split (segun el separador) para poder analizar cada elemento de la misma
     for($j = 1; $j -LE $cantCol - 1; $j++){
        if($i -NE $j){
            if($fila[$j] -NE 0){
                $esIdentidad = $false
            }
        }
        else{
            if($fila[$j] -NE 1){
                $esIdentidad = $false
            }
        }
        if($fila[$j] -NE 0){
            $esNula = $false
        }    
    }
}
#>

#-A partir de aqui se devuelven los resultados del analisis por pantalla.
Write-Host "
-Salida:
"

if($matriz.Count -EQ 1){
    Write-Host "Matriz fila"
}
if($cantCol -EQ 1){
    Write-Host "Matriz columna"
}
if($matriz.Count -EQ $cantCol){
    Write-Host "Matriz cuadrada de orden" $matriz.Count
    if($esIdentidad){
        Write-Host "Matriz identidad"
    }
}
else{
    Write-Host "Matriz rectangular"
}
if($esNula){
    Write-Host "Matriz nula"
}

<#
    FIN DE ARCHIVO
#>