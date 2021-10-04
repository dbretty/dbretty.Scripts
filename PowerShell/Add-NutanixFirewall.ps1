<#
.SYNOPSIS
    Add Nutanix Calm Firewall Rules
.DESCRIPTION
    Add Nutanix Calm Firewall Rules
.OUTPUTS
    Log File stored in C:\Windows\Temp
.NOTES
    Version:        1.0
    Author:         David Brett
    Creation Date:  14/04/2021
    Purpose/Change: Initial script development
  
.EXAMPLE
    ./Add-NutanixFirewall.ps1.ps1
#>

#----------------------------------------------------------[Parameters]------------------------------------------------------------

Param
()

#----------------------------------------------------------[Functions]------------------------------------------------------------

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Set the start Date and Time
Write-Output "Setting Script Parameters"
$StartDTM = (Get-Date)

# Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Log File Info
$sLogPath = "C:\Windows\Temp"
$sLogName = "Add-NutanixFirewall.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName
Write-Output "Setting Log File to $sLogFile"

# Start the transcript for the script
Start-Transcript $sLogFile
Write-Output "Started Transcript"

#-----------------------------------------------------------[Script]----------------------------------------------------------------

# Add Nutanix Calm Firewall Rules
Write-Output "Adding Nutanix Calm Firewall Rules"
New-NetFirewallRule -DisplayName 'NUTANIX_CALM' -Profile @('Domain', 'Private', 'Public') -Direction Inbound -Action Allow -Protocol TCP -LocalPort @('5986')

#-----------------------------------------------------------[Clean]----------------------------------------------------------------

# Stop Logging
Write-Output "Stop logging"
$EndDTM = (Get-Date)
Write-Output "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds"
Write-Output "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes"
Stop-Transcript
