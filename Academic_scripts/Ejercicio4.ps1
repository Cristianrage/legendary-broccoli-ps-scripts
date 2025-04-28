<#
    TRABAJO PRÁCTICO Nº1, EJERCICIO 4. ENTREGA.

<# 
        
.SYNOPSIS
    Muestra la cantidad de ocurrencias de cada una de las palabra contenida en la entrada (parámetro).

.DESCRIPTION
    El script cuenta la cantidad de veces que aparece una palabra en el objeto enviado como entrada, pudiendo ser un archivo de texto, una cadena de caracteres o incluso un array de los mismos.
    El script no es 'case sensitive', es decir que no diferencia entre una palabra escrita en minúscula y otra en mayúscula (y las demás variaciones).

    No es necesario formatear el archivo o la cadena de caracteres de modo que se elimine los caracteres de puntuación y/o caracteres especiales.

    El Script muestra por pantalla, siempre que se haya encontrado al menos una palabra,  una tabla en donde se detalla la palabra y su cantidad de ocurrencias ordenas en forma ascendente.

.PARAMETER cadString
    Parámetro obligatorio: cadena de caracteres o archivo de texto a investigar.

.EXAMPLE
    PS C:\>palabras.ps1 -cadString "Hola. ¿Cómo estás?"
    
    Palabra # Ocurrencias
    ------- -------------
    Cómo                1
    estás               1
    Hola                1

    El Script muestra una tabla de 2 (dos) columnas en donde se detallan cada una de las palabras de la cadena "Hola. ¿Cómo estás?" ordenas en orden alfabético.

.EXAMPLE

    PS C:\>palabras.ps1 -cadString "-Hola. ¿Cómo estás?"
    >>> -Todo bien. ¿Y vos?
    >>> -Muy bien."

    Palabra   # Ocurrencias
    -------   -------------
    bien                  2
    Cómo                  1
    estásTodo             1
    Hola                  1
    vosMuy                1
    Y                     1

    El Script muestra una tabla de 2 (dos) columnas en donde se detallan cada una de las palabras del array de cadenas "Hola. ¿Cómo estás?..." ordenas en orden alfabético.

.EXAMPLE
    PS C:\>palabras.ps1 -cadString "C:\Archivo de prueba.txt"

    Palabra     # Ocurrencias
    -------     -------------
    acentos                 2
    aspecto                 3
    cada                    1
    caso                    3
    con                     2
    Cualquier               2
    de                     12
    del                     2
    el                      7
    ellas                   1
    En                      5
    es                      6
    esta                    1
    este                    4
    existen                 1
    la                      3
    las                     2
    latín                   1
    letra                   2
    letras                  3
    lo                      2
    los                     1
    no                      4
    o                       2
    para                    4
    pero                    2
    poco                    1
    por                     1
    posible                 2
    puntuación              1
    que                     8
    reemplazado             1
    repita                  1
    se                      4
    será                    2
    texto                   3
    tipo                    2
    todas                   2
    un                     11
    una                     4
    versión                 1
    visualizar              2
    web                     1
    y                       2

    El Script muestra una tabla de 2 (dos) columnas en donde se detallan cada una de las palabras contenidas en el archivo de texto ordenas en orden alfabético.

.INPUTS
    Se puede insertar un path de un archivo de texto o un array de cualquier tipo que será tomado como distintas cadenas de caracteres.

.OUTPUTS
    Salida por pantalla de cada una de las palabras que aparecen en la entrada junto a la cantidad de ocurrencias (formato tabla).
    
.NOTES
    Una palabra es considerada como tal cuando se encuentra entre 2 (dos) espacios y se compone únicamente de caracteres alfabéticos sin distinción entre maýusculas y minúsculas.
    Los caracteres numéricos, especiales y los no imprimibles no son considerados por el script.

.LINK
    Versión 1.0 
    Integrantes del grupo:
#>

[CmdletBinding()]
Param
(
    [Parameter(ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True, HelpMessage = "Ruta del archivo de texto o una cadena de caracteres válida")]
    $cadString #No se define el tipo de dato de este parámetro. Se verificará dentro del script con un mensaje correspondiente.
)

Begin{
    $cant = $psboundparameters.Count + $args.Count
	if($cant -NE 1) {
		$Host.UI.WriteErrorLine("Error en la cantidad de parámetros.")
		Exit
	}
}
Process{
    # ---VALIDACIONES---
    $caractPath = [System.IO.Path]::GetInvalidPathChars()
    $alerta = $true

    if( -NOT[string]::IsNullOrWhiteSpace($cadString) -AND 
        $cadString.GetType().FullName -EQ "System.String"){

        for($i = 0; $i -LT $caractPath.Count;  $i++){
            if($cadstring.Contains($caractPath[$i])){
                $alerta = $false
                Break
            }
        }
        if($alerta -AND (Test-Path $cadString)){
        # ---SI TODO ES CORRECTO, SE PROCEDE CON EL OBJETIVO DEL SCRIPT---
            $cadString = Get-Content $cadString -ErrorAction SilentlyContinue
        }#Silenciamos el error, ya que si no es un archivo de texto del que se pueda obtener contenido, se toma como una cadena de caracteres

        $patron = '[^a-zA-ZÁáÉéÍíÓóÚúÑñü ]'
        $cadString = $cadString -replace $patron, ''

        $cadString = $cadString.split(" ");

        $tablaHash = $null
        $tablaHash = @{}

        foreach ($c in $cadString){
            try{
                if($c){ 
                    $tablaHash.add($c, 1)
                }
            }
            catch [System.Management.Automation.MethodInvocationException]{
            #Incremento de la palabra encontrada (ocurrencia).
                $tablaHash[($tablaHash.GetEnumerator() | Where-Object{ $_.Key -EQ "$c" }).Key] += 1
            }
        }
        if($tablaHash.Count -GT 0){
        # --- Verificación de si el archivo/string tiene alguna palabra válida
            $tablaHash.GetEnumerator() | Sort  -Property Name |  Format-Table @{name = "Palabra"; expression = {$_.Key}}, `
                                                                              @{name = "# Ocurrencias"; expression = {$_.Value}} -AutoSize
        }
        else{
            $Host.UI.WriteErrorLine("El dato de entrada no contiene ninguna palabra.")
        }
    }
    else{
        $Host.UI.WriteErrorLine("El dato de entrada no es válido.")
    }
}

<#
        FIN DE ARCHIVO
#>