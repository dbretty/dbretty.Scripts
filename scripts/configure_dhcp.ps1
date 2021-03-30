#requires -version 2
<#
.SYNOPSIS
  <Overview of script>
.DESCRIPTION
  <Brief description of script>
.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>
.INPUTS
  <Inputs if any, otherwise state None>
.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>
.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Set the start Date and Time
Write-Verbose "Setting Script Parameters"
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
Write-Verbose "Setting Log File to $sLogFile"

# Server Name and IP Info
$DNSName = $ENV:computername + "." + $ENV:userdnsdomain
$ServerIP = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne "127.0.0.1"} | Select-Object IPAddress

# Start the transcript for the script
Start-Transcript $sLogFile
Write-Verbose "Started Transcript"

#----------------------------------------------------------[Parameters]------------------------------------------------------------

Param
(
    [parameter(ValueFromPipeline = $true)][String[]]$dns_server,
    [parameter(ValueFromPipeline = $true)][String[]]$gateway
)

#-----------------------------------------------------------[Script]----------------------------------------------------------------

if($null -eq $dns_server){
    Write-Verbose "You have to eter a DNS Server to continue"
} else {
    if($null -eq $gateway){
        Write-Verbose "You have to eter a Gateway Server to continue"
    } else {
        Write-Verbose "Parameters verified, runnning DHCP Configuration"
        # Check for the status of the DHCP Installation
        $Status = Get-WindowsFeature -Name DHCP

        if($Status.installed -eq $True){
            # DHCP is already installed
            Write-Verbose "DHCP Server is already installed"
            $DHCPInstalled = $True
        } else {
            # DHCP is not installed, install it now
            Write-Verbose "DHCP Server not installed, installing now"
            $Result = Add-WindowsFeature -Name DHCP
            if($result.success -eq $True){
                Write-Verbose "DHCP Server installed"
                $DHCPInstalled = $True
            } else {
                Write-Verbose "DHCP Server install failed"
                $DHCPInstalled = $False
            }
        }
        
        # Validate DHCP was installed successfully
        if($DHCPInstalled -eq $true){
            # Import DHCP Management Snappin
            Write-Verbose "Import DHCP Server Snappin"
            Import-Module DHCPServer

            Write-Verbose "Authorising DHCP Server in Domain"
            Add-DhcpServerInDC -DnsName $DNSName -IPAddress $ServerIP.IPAddress

            Write-Verbose "Setting DHCP Server options"
            Set-DHCPServerv4OptionValue -ComputerName $DNSName -DnsServer $DNSServer -DnsDomain $ENV:userdnsdomain -Router $Gateway
        } else {
            Write-Verbose "There was a problem installing the DHCP server, please check the logs for more information"
        }
    }
}


#-----------------------------------------------------------[Clean]----------------------------------------------------------------
# Stop Logging
Write-Verbose "Stop logging"
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds"
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes"
Stop-Transcript