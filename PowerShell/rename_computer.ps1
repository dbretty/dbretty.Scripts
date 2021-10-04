<#
.SYNOPSIS
    Rename Computer
.DESCRIPTION
    Rename Computer
.OUTPUTS
    Log File stored in C:\Windows\Temp
.NOTES
    Version:        1.0
    Author:         David Brett
    Creation Date:  14/04/2021
    Purpose/Change: Initial script development
  
.EXAMPLE
    ./rename_computer.ps1
#>

#----------------------------------------------------------[Parameters]------------------------------------------------------------

Param
(
    [parameter(Mandatory=$true)][string]$Hostname
)

#----------------------------------------------------------[Functions]------------------------------------------------------------
function Set-Hostname{
    [CmdletBinding()]

    Param(
        [parameter(Mandatory=$true)][string]$Hostname
    )

    If ($Hostname -eq  $(hostname)){
        Write-Output "Hostname is already the same as the value passed in"
    } 
    Else
    {
        Rename-Computer -NewName $Hostname -ErrorAction Stop
    }
}

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Set the start Date and Time
Write-Output "Setting Script Parameters"
$StartDTM = (Get-Date)

# Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Log File Info
$sLogPath = "C:\Windows\Temp"
$sLogName = "rename_computer.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName
Write-Output "Setting Log File to $sLogFile"

# Start the transcript for the script
Start-Transcript $sLogFile
Write-Output "Started Transcript"

#-----------------------------------------------------------[Script]----------------------------------------------------------------

# Rename Computer
Write-Output "Setting Hostname to @@{SERVER_NAME}@@"

Set-Hostname -Hostname "@@{SERVER_NAME}@@"

Restart-Computer -Force -AsJob

#-----------------------------------------------------------[Clean]----------------------------------------------------------------

# Stop Logging
Write-Output "Stop logging"
$EndDTM = (Get-Date)
Write-Output "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds"
Write-Output "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes"
Stop-Transcript
