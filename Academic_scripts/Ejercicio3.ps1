<#
    TRABAJO PRÁCTICO Nº1, EJERCICIO 3. ENTREGA.

#>

<# 
        
.SYNOPSIS
    Lee un archivo de texto de backup con cierto formato y lo almacena en un archivo con formato .CSV.

.DESCRIPTION
    El script lee un archivo de texto compuesto de cierta cantidad de registros que se componen de la misma cantidad de campos (backup de una base de datos).
    Cada campo tiene su valor. El script almacena la información en un archivo .CSV.

    El archivo de texto de backup deberá tener un formato predefinido:
        *Por cada línea 1 (un) campo con su valor.
        *Para finalizar un registro, se almacena en una línea 3 (tres) asteriscos: "***"
        *La línea se compondrá con el nombre del campo, seguido de un = (igual) y a continuación el valor del campo de cualquier tipo de dato.
    No se realizará verificación de si los campos tienen diferente tipo de dato entre sí, pero sí se verificará que la cantidad y el nombre de los campos en cada registro sea igual a cada uno de ellos.

    El Script almacena en un archivo de salida con extensión .CSV los registros obtenidos de la entrada que se guardarán en el path de salida predefinido.

.PARAMETER origenPath
    Parámetro obligatorio: Ruta de origen del archivo de texto de backup.

.PARAMETER destinoPath
    Parámetro obligatorio: Ruta de destino del archivo .CSV si el script finaliza su ejecución correctamente.

.EXAMPLE
    PS C:\>txtACsv.ps1 -origenPath C:\ -destinoPath C:\
    Script finalizado correctamente

    El Script muestra un mensaje de creación del archivo de salida CSV satisfactorio.

.EXAMPLE

    PS C:\>txtACsv.ps1  C:\ C:\
    Script finalizado correctamente

    El Script muestra un mensaje de creación del archivo de salida CSV satisfactorio.

.INPUTS
    Se debe insertar 2 rutas de archivo válidas: una de entrada (archivo de texto de backup) y otra de salida.

.OUTPUTS
    Salida por pantalla de un mensaje (correcto o error) y creación de archivo CSV si corresponde.
    
.NOTES
    

.LINK
    Versión 1.0 

#>

Param
(
    [parameter(Position = 1, HelpMessage = "Ruta del archivo de texto de backup")] 
    [String] $origenPath,
    [parameter(Position = 2, HelpMessage = "Ruta del directorio de salida para el archivo CSV")]
    [String] $destinoPath
)

Begin{
    $cant = $psboundparameters.Count + $args.Count
	if($cant -NE 2) {
		$Host.UI.WriteErrorLine("Error en la cantidad de parámetros.")
		Exit
	}
}

Process{
    # ---VALIDACIONES---

    $caractPath = [System.IO.Path]::GetInvalidPathChars()
    $alerta = $true

    if( -NOT[string]::IsNullOrWhiteSpace($origenPath) -AND 
        $origenPath.GetType().FullName -EQ "System.String"){

        for($i = 0; $i -LT $caractPath.Count;  $i++){
            if($origenPath.Contains($caractPath[$i])){
                $alerta = $false
                Break
            }
        }
        if($alerta -AND (Test-Path $origenPath)){
            $lineas = Get-Content $origenPath -ErrorAction SilentlyContinue -ErrorVariable errores
            if($errores.Count -GT 0){
                $Host.UI.WriteErrorLine("El path de origen no es válido.")
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

    if( -NOT[string]::IsNullOrWhiteSpace($destinoPath) -AND 
        $destinoPath.GetType().FullName -EQ "System.String"){

        for($i = 0; $i -LT $caractPath.Count;  $i++){
            if($destinoPath.Contains($caractPath[$i])){
                $alerta = $false
                Break
            }
        }
        if(-NOT$alerta ){
            $Host.UI.WriteErrorLine("El path de destino no es válido.")
            Exit
        }
        if(-NOT (Test-Path $destinoPath)){
            $Host.UI.WriteErrorLine("El path de destino no existe.")
            Exit
        }
    }
    else{
        $Host.UI.WriteErrorLine("El parámetro de ruta de destino no es un string válido.")
        Exit
    }

    $campoYValor = @()
    $separator = "="

    foreach($l in $lineas){
    # ---SI TODO ES CORRECTO, SE PROCEDE CON EL OBJETIVO DEL SCRIPT---
        if($l -NE '***'){
            if(([regex]::Matches($l, $separator)).Count -GT 1){
                $campoYValor += $l -Split $separator, 2
            }
            elseif( (([regex]::Matches($l, $separator)).Count -EQ 1)){
                    $campoYValor += $l -Split $separator
                    if([string]::IsNullOrWhiteSpace(($l -Split $separator)[0])){
                        $Host.UI.WriteErrorLine("Error en la lectura del Archivo de Backup. Los campos no pueden ser NULL.")
                        Exit
                    }#Caso extremo en el cual no haya caracteres previos a un = (igual).
                }
                else{
                    $Host.UI.WriteErrorLine("Error en la lectura del Archivo de Backup. Líneas no reconocidas")
                    Exit
                }
            }
        else{
            $campoYValor += $l
        }
    }#Parseo entre Campos y Valores

    $i = 0
    $titulos = @()

    while($campoYValor[$i] -NE '***'){
    # ---GUARDADO DE CADA UNO DE LOS TÍTULOS DE LOS CAMPOS---
        $titulos += $campoYValor[$i]
        $i += 2
    }

    $i = $j = $h = 0
    $nReg = [math]::Truncate($( $campoYValor.Count / ($titulos.Count * 2)))
    $soloValor = New-Object system.Array[] $nReg
    # Matriz dónde se almacenarán los N registros.

    while($campoYValor[$i]){
        while($campoYValor[$i] -AND ($campoYValor[$i] -EQ $titulos[$j])){
            $soloValor[$h] += $campoYValor[$i + 1]
            $i += 2
            $j++
        }
        if($campoYValor[$i] -EQ '***'){
            $i++
            $j = 0
            $h++
        }
    
        elseif($campoYValor[$i]){
            $Host.UI.WriteErrorLine("Error en la lectura del Archivo de Backup. Los registros no son compatibles entre sí.")
            Exit
        }
    }# Guardado de valores de cada campo por registro.

    $psArray = @()

    for($i = 1; $i -LE $soloValor.Count; $i++){
        $j = 0
        $psSalida = New-Object psobject
        foreach($t in $titulos){
            Add-Member -InputObject $psSalida -MemberType noteproperty -Name $t -Value $soloValor[$i - 1][$j]
            $j++
        }
        $psArray += $psSalida
    }# Custom Object para la salida a un .CSV.
    $psArray
    try{
        $psArray | Export-Csv $destinoPath\csvfile.csv -Delimiter ';' -NoTypeInformation
        Write-Host "Script finalizado correctamente"
    }
    catch{
        $Host.UI.WriteErrorLine("No se pudo guardar el archivo. La ruta de salida se encuentra bloqueada.")
    }
}

<#
        FIN DE ARCHIVO
#>