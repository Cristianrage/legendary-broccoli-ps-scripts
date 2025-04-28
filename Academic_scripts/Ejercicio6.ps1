<#
TRABAJO PRÁCTICO Nº1, EJERCICIO 6. ENTREGA.
#>

<#
.SYNOPSIS
    Muestra información sobre la PC en donde se está ejecutando el script (local computer).

.DESCRIPTION
    El script muestra la siguiente información sobre la PC:
        *Modelo de CPU;
        *Cantidad de Memoria RAM total (si tiene más de un banco utilizándose);
        *Placas de Red;
        *Versión del Sistema Operativo;

.EXAMPLE
    PS C:\datosPC.ps1
    
    Modelo de CPU                  Intel(R) Core(TM) i5-3550S CPU @ 3.00GHz
    Placas de Red                  {Microsoft Kernel Debug Network Adapter, Realtek PCIe GBE Family Controller}
    Versión SO                     Microsoft Windows 10 Pro 10.0.10240
    Memoria RAM                    8 GB

    Al finalizar la ejecución, se muestran la información correspondiente.

.INPUTS
    No hay entrada. No recibe ningún parámetro.

.OUTPUTS
    Muestra por pantalla información sobre la PC en donde se ejecutó.

.NOTES
    

.LINK
    Versión 1.0 

#>

#No se verifican la cantidad de parámetros ya que al no tener, no afectará el rendimiento del sript.
Process{
    # ---MEMORIA RAM---
    $gb = $false
    $mem = ((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1mb)
    if($mem -GE 1024){
        $mem = $mem / 1024
        $gb = $true
    }
    $mem = [math]::Round($mem)
    if($gb){
        $mem = $mem.ToString() + " GB"
    }
    else{
        $mem = $mem.ToString() + " MB"
    }

    $datos = @{"Modelo de CPU" = (Get-WmiObject -class win32_processor).Name;
                "Memoria RAM" = $mem;
                "Placas de Red" = (Get-WmiObject -Class Win32_NetworkAdapter).Name;
                "Versión SO" = ((Get-WmiObject Win32_OperatingSystem).Caption + " " + 
                                (Get-WmiObject Win32_OperatingSystem).Version )}
    $datos | Format-Table -HideTableHeaders 
    }

<#
	FIN DE ARCHIVO
#>