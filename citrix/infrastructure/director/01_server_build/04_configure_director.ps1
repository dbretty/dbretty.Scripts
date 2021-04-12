# Determine where to do the logging
$logPS = "C:\Windows\Temp\configure_director.log"
# Set the start Date and Time
Write-Verbose "Setting Script Parameters" -Verbose
$StartDTM = (Get-Date)

# Read the settings in from the config file and set up variables
# Replace these if you are not using MDT
Write-Verbose "Reading Settings File" -Verbose
$MyConfigFileloc = ("$env:Settings\Applications\Settings.xml")
[xml]$MyConfigFile = (Get-Content $MyConfigFileLoc)

# Start the transcript for the install
Start-Transcript $LogPS

# Configure Script Variables
Write-Verbose "Configure Script Variables" -Verbose
$Broker = "director-proxy.bretty.me.uk"
$DomainName = "bretty.me.uk"
$SessionTimeout = "60"
$LogonASPXFile = "c:\inetpub\wwwroot\director\logon.aspx"

# Read each line of the file and pre-populate the domain name
$OldText = "TextBox ID=""Domain"" runat=""server"""
$NewText = "TextBox ID=""Domain"" runat=""server"" Text=""$DomainName"" readonly=""true"""
$Content = Get-Content $LogonASPXFile
$ContentNew = ""
Foreach ( $Line in $Content ) {
	$Line = ( $Line -replace $OldText, $NewText) + "`r`n"
	$ContentNew = $ContentNew + $Line
}
Set-Content $LogonASPXFile -value $ContentNew -Encoding UTF8
Write-Verbose "Set Up Default Domain" -Verbose

# Set the Director Broker
$xml = [xml](Get-Content "C:\inetpub\wwwroot\Director\web.config")
$node = $xml.configuration.appSettings.add
$nodeAddress = $node | where {$_.Key -eq 'Service.AutoDiscoveryAddresses'}
$nodeAddress.Value = $Broker
$xml.Save("C:\inetpub\wwwroot\Director\web.config")
Write-Verbose "Configured Director Proxy Broker" -Verbose

# Change the Session Timeout
$xml = [xml](Get-Content "C:\inetpub\wwwroot\Director\web.config")
$node = $xml.configuration."system.web".sessionState
$node.timeout = $SessionTimeOut
$xml.Save("C:\inetpub\wwwroot\Director\web.config")
Write-Verbose "Changed Session Timeout" -Verbose

# Disable SSL Check
$xml = [xml](Get-Content "C:\inetpub\wwwroot\Director\web.config")
$node = $xml.configuration.appSettings.add | where {$_.Key -eq 'UI.EnableSslCheck'}
$node.value = "false"
$xml.Save("C:\inetpub\wwwroot\Director\web.config")
Write-Verbose "Disabled SSL Check" -Verbose

# Stop Logging
Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript