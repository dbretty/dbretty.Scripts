<#
.SYNOPSIS
    Install and configure the base settings of a DHCP Server
.DESCRIPTION
    Install and configure the base settings of a DHCP Server
.PARAMETER dns_server
    The DNS Server you want to assign to the Server
.PARAMETER gateway
    The Gateway you want to assign to the Server
.OUTPUTS
    Log File stored in C:\Windows\Temp
.NOTES
  Version:        1.0
  Author:         David Brett
  Creation Date:  30/03/2021
  Purpose/Change: Initial script development
  
.EXAMPLE
  ./configure_dhcp.ps1 -dns_server 192.168.10.10 -gateway 192.168.10.1
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
$sLogName = "configure_dhcp.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName
Write-Host "Setting Log File to $sLogFile"

# Server Name and IP Info
$DNSName = $ENV:computername + "." + $ENV:userdnsdomain
$ServerIP = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne "127.0.0.1"} | Select-Object IPAddress

# Start the transcript for the script
Start-Transcript $sLogFile
Write-Host "Started Transcript"

#----------------------------------------------------------[Parameters]------------------------------------------------------------

Param
(
    [parameter(ValueFromPipeline = $true,Mandatory=$True,HelpMessage="Enter and IP for a DNS Server")]$dns_server,
    [parameter(ValueFromPipeline = $true,Mandatory=$True,HelpMessage="Enter an IP for a Gateway")]$gateway
)

#-----------------------------------------------------------[Script]----------------------------------------------------------------

# Check for the status of the DHCP Installation
$Status = Get-WindowsFeature -Name DHCP

if($Status.installed -eq $True){
    # DHCP is already installed
    Write-Host "DHCP Server is already installed"
    $DHCPInstalled = $True
} else {
    # DHCP is not installed, install it now
    Write-Host "DHCP Server not installed, installing now"
    $Result = Add-WindowsFeature -Name DHCP
    if($result.success -eq $True){
        Write-Host "DHCP Server installed"
        $DHCPInstalled = $True
    } else {
        Write-Host "DHCP Server install failed"
        $DHCPInstalled = $False
    }
}

# Validate DHCP was installed successfully
if($DHCPInstalled -eq $true){
    # Import DHCP Management Snappin
    Write-Host "Import DHCP Server Snappin"
    Import-Module DHCPServer

    # Authorize DHCP Server
    Write-Host "Authorising DHCP Server in Domain"
    Add-DhcpServerInDC -DnsName $DNSName -IPAddress $ServerIP.IPAddress

    # Set DHCP Server Options
    Write-Host "Setting DHCP Server options"
    Set-DHCPServerv4OptionValue -ComputerName $DNSName -DnsServer $DNSServer -DnsDomain $ENV:userdnsdomain -Router $Gateway
} else {
    Write-Host "There was a problem installing the DHCP server, please check the logs for more information"
}


#-----------------------------------------------------------[Clean]----------------------------------------------------------------
# Stop Logging
Write-Host "Stop logging"
$EndDTM = (Get-Date)
Write-Host "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds"
Write-Host "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes"
Stop-Transcript