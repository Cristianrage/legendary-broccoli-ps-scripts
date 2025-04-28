<#
    TRABAJO PRÁCTICO Nº1, EJERCICIO 2. ENTREGA.
    Integrantes:
    
#>

<# 

.SYNOPSIS
    Se copian a la ruta indicada los archivos con extensión .TXT que contengan en su contenido la palabra o frase indicada de cierto directorio.

.DESCRIPTION
    Se realiza una búsqueda en el directorio indicado y sus subcarpetas de solamente archivos de texto que contengan la palabra o frase indicada por el usuario.
    Los mismos se copiarán en la ruta de salida del script junto a un archivo de log (.LOG) el cual indica los archivos copiados con cierta información.

    El script verifica tanto el path de destino como el de origen. Si no encuentra ningún archivo, devolverá un archivo de .LOG vacío a la ruta correspondiente.

    Si un archivo no se pudo copiar por algún error, no se mostrará en el archivo de .LOG.

.PARAMETER origenPath
    Parámetro obligatorio: Ruta de origen en donde se buscarán los archivos de texto coincidentes.

.PARAMETER destinoPath
    Parámetro obligatorio: Ruta de destino del archivo .LOG si el script finaliza su ejecución correctamente.


.PARAMETER cadena
    Parámetro obligatorio: String que contiene la palabra o frase a buscar en los archivos de texto.

.EXAMPLE
    PS C:\> C:\copiaArchivos.ps1
    cmdlet copiaArchivos.ps1 en la posición 1 de la canalización de comandos
    Proporcione valores para los parámetros siguientes:
    origenPath: C:\
    destinoPath: C:\CopiaCarpeta\
    cadena: "Frase que busco"

    El script finaliza correctamente creando el archivo de .log "ArchivosCopiados.log" en C:\CopiaCarpeta\ de los archivos que cumplen con la búsqueda.

.EXAMPLE
    PS C:\> C:\copiaArchivos.ps1
    cmdlet copiaArchivos.ps1 en la posición 1 de la canalización de comandos
    Proporcione valores para los parámetros siguientes:
    origenPath: C:\
    destinoPath: C:\CopiaCarpeta\
    Error: No se puede sobrescribir el elemento C:\Archivo1.txt consigo mismo.
    cadena: "Frase que busco"

    El script finaliza correctamente, pero con errores en la copia de un archivo.
    Se crea el archivo de .log "ArchivosCopiados.log" en C:\CopiaCarpeta\ de los archivos que cumplen con la búsqueda y se pudieron copiar.

.INPUTS
    Ruta de origen de la carpeta (y subcarpetas) en donde se realizará la búsqueda.
    Ruta de destino de la copia de los archivos que cumplan con la búsqueda.
    Palabra o frase a buscar en el contenido de los archivos de texto.

.OUTPUTS
    Salida por pantalla ante un error en la copia de archivos o parámetros incorrectos.
    Copia de archivos en el directorio correspondiente que cumplen con la búsqueda.
    Creación de archivo de .LOG de archivos copiados.

.NOTES
    

.LINK
    Versión 1.0 
    Integrantes del grupo:


#>

Param
(
[parameter(Position = 1, HelpMessage = "Ruta de la carpeta a buscar .TXTs")] [String] $origenPath,
[parameter(Position = 2, HelpMessage = "Ruta de la carpeta a copiar archivos y archivo .LOG")] [String] $destinoPath,
[parameter(Position = 3)] [String] $cadena
#Colocando parámetros obligatorios evito que se inserten parámetros por "Pipeline Input".
)

Begin{
    $cant = $psboundparameters.Count + $args.Count
	if($cant -NE 3) {
		$Host.UI.WriteErrorLine("Error en la cantidad de parámetros.")
		Exit
	}
}

# ---VALIDACIONES---
Process{
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
        if(-NOT$alerta){
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
                $alerta = $false
                Break
            }
        }
        if(-NOT$alerta){
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

    $tabla = @()

    Get-ChildItem $origenPath -Filter "*.txt" -Recurse | 
        Where-Object { $_.Attributes -NE "Directory"} | 
            ForEach-Object {
                $alerta = $true 
                if (Get-Content $_.FullName | Select-String -Pattern $cadena) 
                {
                    Copy-Item $_.FullName -Destination $destinoPath -errorAction SilentlyContinue -errorVariable errores
                    foreach($e in $errores){
                        if ($e.Exception -NE $null){
                            $Host.UI.WriteErrorLine("Error: $($e.Exception.Message)")
                            $alerta = $false
                        }
                    }
                }# Tratamiento de errores por copiado de archivo.
                if($alerta){
                    $tabla += New-Object PSObject -Property @{ 'Directorio de origen' = $($_.FullName);
                                                               'Tamaño kb' = ([math]::ceiling($($_.Length / 1kb)));
                                                               'Fecha de Modificación' = $($_.LastWriteTime)}
                }
          }

    try{
    $tabla | Format-Table 'Directorio de origen', 'Tamaño kb', 'Fecha de Modificación' -AutoSize >> $destinopath"\ArchivosCopiados.log"}
    catch{
        $Host.UI.WriteErrorLine("Error al escribir sobre el archivo de .LOG.")
        Exit
    }
    Write-Host "Script ejecutado correctamente."
}

<#
        FIN DE ARCHIVO
#>

