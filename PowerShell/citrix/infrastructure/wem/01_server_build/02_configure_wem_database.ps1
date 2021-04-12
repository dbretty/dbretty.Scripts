# Determine where to do the logging
$logPS = "C:\Windows\Temp\configure_wem_database.log"
 
# Set the start Date and Time
Write-Verbose "Setting Script Parameters" -Verbose
$StartDTM = (Get-Date)

# Start the transcript for the install
Start-Transcript $LogPS

# Import WEM SDK
Write-Verbose "Importing WEM SDK" -Verbose
Import-Module 'C:\Program Files (x86)\Norskale\Norskale Infrastructure Services\SDK\WemDatabaseConfiguration\WemDatabaseConfiguration.psd1'

#Configure Script Variables
Write-Verbose "Configure Script Variables" -Verbose
$fileFolder = "C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\";
$DBname = "bretty_wem";
$SQLServer = "sql"
$Admins = "bretty\wem admins"
$ServiceAccount = "bretty\svc_wem"
$VUEMPassword = ConvertTo-SecureString "password" –AsPlainText –Force

# Create Configuration Object for new WEM Database
Write-Verbose "Create new Configuration Object for WEM Database" -Verbose
$cfg = New-Object Citrix.WEM.SDK.Configuration.Database.SDKNewDatabaseConfiguration;
$cfg.DatabaseServerInstance = $SQLServer;
$cfg.DatabaseName = $DBname;
$cfg.DataFilePath = ($fileFolder+$DBname+“_Data.mdf”);
$cfg.LogFilePath = ($fileFolder+$DBname+“_Log.ldf”) ;
$cfg.DefaultAdministratorsGroup = $Admins
$cfg.WindowsAccount = $ServiceAccount;
$cfg.VuemUserSqlPassword = $VUEMPassword;

# Create new WEM Database
Write-Verbose "Create new WEM Database" -Verbose
New-WemDatabase –Configuration $cfg;

# Stop Logging
Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript