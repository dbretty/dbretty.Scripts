<#
.SYNOPSIS
    Install and configure a DHCP Scope on the DHCP Server
.DESCRIPTION
    Install and configure a DHCP Scope on the DHCP Server
.PARAMETER dns_server
    The DNS Server you want to assign to the Server
.PARAMETER gateway
    The Gateway you want to assign to the Server
.PARAMETER scope_name
    The name you want to use for the DHCP Scope
.PARAMETER scope_network
    The overall Network for the DHCP Scope '192.168.10.0'
.PARAMETER start_address
    The Start Address for the DHCP Scope '192.168.10.100'
.PARAMETER end_address
    The End Address for the DHCP Scope '192.168.10.200'
.PARAMETER subnet_mask
    The Subnet Mask for the DHCP Scope '255.255.255.0'
.OUTPUTS
    Log File stored in C:\Windows\Temp
.NOTES
  Version:        1.0
  Author:         David Brett
  Creation Date:  30/03/2021
  Purpose/Change: Initial script development
  
.EXAMPLE
  ./configure_dhcp_scope.ps1 -dns_server 192.168.10.10 -gateway 192.168.10.1 -scope_name vlan_10 -scope_network 192.168.10.0 -start_address 192.168.10.100 -end_address 192.168.10.200 -subnet_mask 255.255.255.0
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
$sLogName = "configure_dhcp_scope.log"
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
    [parameter(ValueFromPipeline = $true,Mandatory=$True,HelpMessage="Enter and IP for a Gateway")]$gateway,
    [parameter(ValueFromPipeline = $true,Mandatory=$True,HelpMessage="Enter the Name for the DHCP Scope")]$scope_name,
    [parameter(ValueFromPipeline = $true,Mandatory=$True,HelpMessage="Enter the Overall Scope Network, eg 192.168.10.0")]$scope_network,
    [parameter(ValueFromPipeline = $true,Mandatory=$True,HelpMessage="Enter the Start Address, eg 192.168.10.100")]$start_address,
    [parameter(ValueFromPipeline = $true,Mandatory=$True,HelpMessage="Enter the End Address, eg 192.168.10.200")]$end_address,
    [parameter(ValueFromPipeline = $true,Mandatory=$True,HelpMessage="Enter the Subnet Mask, eg 255.255.255.0")]$subnet_mask
)

#-----------------------------------------------------------[Script]----------------------------------------------------------------

# Import DHCP Management Snappin
Write-Host "Import DHCP Server Snappin"
Import-Module DHCPServer

# Build FQDN
Write-Host "Build FQDN"
$DNSName = $ENV:computername + "." + $ENV:userdnsdomain

# Add DHCP Scope
Write-Host "Add DHCP Scope"
Add-DHCPServerv4Scope -EndRange $EndAddress -Name $ScopeName -StartRange $StartAddress -SubnetMask $SubnetMask -State Active -ComputerName $ENV:computername

# Assign DHCP Scope Options
Write-Host "Assign DHCP Scope Options"
Set-DHCPServerv4OptionValue -ComputerName $DNSName -ScopeId $ScopeNetwork -DnsServer $DNSServer -DnsDomain $ENV:userdnsdomain -Router $Gateway

#-----------------------------------------------------------[Clean]----------------------------------------------------------------
# Stop Logging
Write-Host "Stop logging"
$EndDTM = (Get-Date)
Write-Host "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds"
Write-Host "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes"
Stop-Transcript


