# Determine where to do the logging
$logPS = "C:\Windows\Temp\configure_wem_infrastructure.log"
 
# Set the start Date and Time
Write-Verbose "Setting Script Parameters" -Verbose
$StartDTM = (Get-Date)

# Start the transcript for the install
Start-Transcript $LogPS

# Import WEM SDK
Write-Verbose "Importing WEM SDK" -Verbose
Import-Module ‘C:\Program Files (x86)\Norskale\Norskale Infrastructure Services\SDK\WemInfrastructureServiceConfiguration\WemInfrastructureServiceConfiguration.psd1’

#Configure Script Variables
Write-Verbose "Configure Script Variables" -Verbose
$passwd = ConvertTo-SecureString "password" –AsPlainText –Force;
$wemsqlpasswd = ConvertTo-SecureString "password" –AsPlainText –Force;
$cred = New-Object System.Management.Automation.PSCredential("bretty\svc_wem", $passwd);
$WEM_ISServer = "wem.bretty.me.uk"
$WEM_LicenceServer = "licensing.bretty.me.uk"
$DBServer = "sql"
$DBname = "bretty_wem"
$DebugMode = "Enable"

# Create Configuration Object for new WEM Database
Write-Verbose "Create new Configuration for WEM Infrastructure" -Verbose
Set-WemInfrastructureServiceConfiguration –InfrastructureServer $WEM_ISServer –InfrastructureServiceAccountCredential $cred –DatabaseServerInstance $DBServer –DatabaseName $DBname –DebugMode $DebugMode –SqlUserSpecificPassword $wemsqlpasswd –EnableInfrastructureServiceAccountCredential Enable –EnableScheduledMaintenance Enable –PSDebugMode Enable –GlobalLicenseServerOverride Enable –LicenseServerName $WEM_LicenceServer –LicenseServerPort $WEM_LicenceServerPort –SendGoogleAnalytics Disable –UseCacheEvenIfOnline Disable –SetSqlUserSpecificPassword Enable

# Stop Logging
Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript
