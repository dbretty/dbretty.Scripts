<#
.SYNOPSIS
    Configure DNS on a Domain Controller
.DESCRIPTION
    Configure DNS on a Domain Controller
.PARAMETER forwarder
    The DNS Forwarder you would like to configure
.PARAMETER subnets_full
    The comma delimited list of Subnets you want to add for reverse lookup Domains '192.168.100.0/24,192.168.101.0/24,192.168.1.0/24,192.168.0.0/24'
.OUTPUTS
    Log File stored in C:\Windows\Temp
.NOTES
  Version:        1.0
  Author:         David Brett
  Creation Date:  31/03/2021
  Purpose/Change: Initial script development
  
.EXAMPLE
  ./configure_dns.ps1 -forwarder 8.8.8.8 -subnets_full 192.168.100.0/24,192.168.101.0/24,192.168.1.0/24,192.168.0.0/24
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Set the start Date and Time
Write-Host "Setting Script Parameters"
$StartDTM = (Get-Date)

# Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Script Version
$sScriptVersion = "1.0"

# Log File Info
$sLogPath = "C:\Windows\Temp"
$sLogName = "configure_dns.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName
Write-Host "Setting Log File to $sLogFile"

# Start the transcript for the script
Start-Transcript $sLogFile
Write-Host "Started Transcript"

#----------------------------------------------------------[Parameters]------------------------------------------------------------

Param
(
    [parameter(ValueFromPipeline = $true,Mandatory=$True,HelpMessage="Enter an IP for the DNS Forwarder")]$forwarder,
    [parameter(ValueFromPipeline = $true,Mandatory=$True,HelpMessage="Enter The Subnets for Reverse Lookup Domains e.g 192.168.1.0/24,192.168.2.0/24")]$subnets_full
)

#-----------------------------------------------------------[Script]----------------------------------------------------------------

# Add the DNS Forwarder to the DNS Server
Write-Host "Adding DNS Forwarder"
Add-DnsServerForwarder -IPAddress $Forwarder

# Add the Subnets as Reverse Lookup Domains on the DNS Server
Write-Host "Adding Reverse Lookup Zones"
$Subnets = ($SubnetsFull).Split(",")
foreach ($Subnet in $Subnets)
{
    Add-DnsServerPrimaryZone -NetworkID $Subnet -ReplicationScope Domain
}

#-----------------------------------------------------------[Clean]----------------------------------------------------------------
# Stop Logging
Write-Host "Stop logging"
$EndDTM = (Get-Date)
Write-Host "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds"
Write-Host "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes"
Stop-Transcript
