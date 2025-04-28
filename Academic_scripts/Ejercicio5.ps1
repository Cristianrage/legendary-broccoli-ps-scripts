<#
TRABAJO PRÁCTICO Nº1, EJERCICIO 5. ENTREGA.

#>

<#

.SYNOPSIS
    Realiza el backup de los archivos de una carpeta origen en formato zip y los guarda en una carpeta destino.

.DESCRIPTION
    El script pide al usuario que ingrese la carpeta origen que desea comprimir y la carpeta destino donde desea almacenar el archivo zip comprimido.
    Luego de validar los paths ingresados exitosamente comprime los archivos de la carpeta origen en un archivo zip cuyo nombre corresponde a la fecha actual del equipo.

    Si encuentra un archivo zip con el mismo nombre o la carpeta de destino se encuentra vacía, no realiza el backup.
    Si encuentra mas de tres archivos zip en la carpeta destino elimina el mas viejo.

.PARAMETER origenPath
	La carpeta origen de donde se desea comprimir archivos para realizar un backup. No tiene nada cargado por defecto.

.PARAMETER destinoPath
	La carpeta en donde se almacenara el archivo .zip correspondiente al backup. No tiene nada cargado por defecto.

.EXAMPLE
    PS C:\> .\Ejercicio5.ps1 -origenPath "C:\Users\Cristianrage\Desktop\Scripting" -destinoPath "C:\Users\Cristianrage\Desktop\Backup"
    Backup realizado correctamente.

    Al finalizar la ejecución correctamente notifica al usuario que el Backup se realizo correctamente.

.EXAMPLE
    PS C:\> .\Ejercicio5.ps1
    cmdlet Ejercicio5.ps1 at command pipeline position 1
    Supply values for the following parameters:
    origenPath: a
    destinoPath: C:\Users\Cristianrage\Desktop\Backup
    El path de origen no es válido.

    Si el usuario ingresa incorrectamente alguno, o ambos paths, se le notifica y el script no realiza otra acción.

.INPUTS
    Se debe insertar el path de origen y luego el path destino.

.OUTPUTS
    Se notifica que el Backup fue realizado, o que el path es incorrecto.
    Si corresponde se crea un archivo zipeado como backup de los archivos contenidos en el directorio origen.

.NOTES
    La compresión de la carpeta indicada se realiza tanto de los archivos contenidos en ella como las subcarpetas y sus correspondientes archivos.

.LINK
    Versión 1.0 

#>
Param
(
    [Parameter(Position = 1, HelpMessage = "Ruta de la carpeta a realizar backup")] $origenPath,
    [Parameter(Position = 2, HelpMessage = "Ruta donde se guardará el .ZIP")] $destinoPath
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
    $existeOrigen = $existeDestino = $true

    if( -NOT[string]::IsNullOrWhiteSpace($origenPath) -AND 
        $origenPath.GetType().FullName -EQ "System.String"){

        for($i = 0; $i -LT $caractPath.Count;  $i++){
            if($origenPath.Contains($caractPath[$i])){
                $existeOrigen = $false
                break
            }
        }
        if(-NOT$existeOrigen){
            $Host.UI.WriteErrorLine("El path de origen no es válido.")
            Exit
        }
        if(-NOT (Test-Path $origenPath)){
            $Host.UI.WriteErrorLine("El path de origen no existe.")
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
                $existeDestino = $false
                break
            }
        }
        if(-NOT$existeDestino){
            $Host.UI.WriteErrorLine("El path de destino no es válido.")
            Exit
        }
        if(-NOT (Test-Path $destinoPath)){
            $Host.UI.WriteErrorLine("El path de destino no existe.")
            Exit
        }
    }
    else{
        $Host.UI.WriteErrorLine("El parámetro de ruta de origen no es un string válido.")
        Exit
    }

    $cantArch = (Get-ChildItem $origenPath -File | Measure-Object).Count
    if($cantArch -EQ 0){
        Write-Host "La carpeta a realizar backup se encuentra vacía. No se ha realizado el backup de la misma."
        exit
    }

    # ---SI TODO ES CORRECTO, SE PROCEDE CON EL OBJETIVO DEL SCRIPT---

    Add-Type -AssemblyName "System.IO.Compression.FileSystem"
    $backup = "$destinoPath\$(Get-Date -Format yyyyMMdd).zip"
    $archLista = Get-ChildItem $destinoPath -File -Filter "*.zip"

    try{
        [System.IO.Compression.ZipFile]::CreateFromDirectory($origenPath , $backup, [System.IO.Compression.CompressionLevel]::Optimal, $false)
    }#Comprime incluso las carpetas que se encuentren dentro del Directorio de origen.
    catch{
        $Host.UI.WriteErrorLine("El archivo $backup ya existe. No se ha realizado el backup.")
        exit
    }

    if(($archLista | Measure-Object).Count -GT 3){
        $archLista = $archLista | Sort-Object LastWriteTime
        $archLista[0] | Remove-Item -ErrorAction SilentlyContinue -ErrorVariable errores
        foreach($e in $errores){
            if ($e.Exception -NE $null){
                $Host.UI.WriteErrorLine("Error $($archLista[0]): $($e.Exception.Message) No se removerá.")
            }
        }
    }

    Write-Host "Backup realizado correctamente."
}

<#
	FIN DE ARCHIVO
#>