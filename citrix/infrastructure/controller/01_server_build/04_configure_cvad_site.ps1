# Set the start Date and Time
Write-Verbose "Setting Script Parameters" -Verbose
$StartDTM = (Get-Date)

# Read the settings in from the config file and set up variables
# Replace these if you are not using MDT
Write-Verbose "Reading Settings File" -Verbose
$MyConfigFileloc = ("$env:Settings\Applications\Settings.xml")
[xml]$MyConfigFile = (Get-Content $MyConfigFileLoc)

# Configure Script Variables
Write-Verbose "Configure Variables" -Verbose
$Vendor = "Citrix"
$Product = "XenDesktop"
$Version = $MyConfigFile.Settings.Citrix.Version
$LogPS = "${env:SystemRoot}" + "\Temp\Configure $Vendor $Product $Version Site PS Wrapper.log"

$SiteName = $MyConfigFile.Settings.Citrix.SiteName
$FullAdminGroup = $MyConfigFile.Settings.Citrix.DomainAdminGroup
$LicenseServer = $MyConfigFile.Settings.Citrix.LicenseServer
$LicensingModel = $MyConfigFile.Settings.Citrix.LicensingModel
$ProductCode = $MyConfigFile.Settings.Citrix.ProductCode
$ProductEdition = $MyConfigFile.Settings.Citrix.ProductEdition
$Port = $MyConfigFile.Settings.Citrix.Port
$AddressType = $MyConfigFile.Settings.Citrix.AddressType
$ZoneName = "Liphook"
$XDC01 = $MyConfigFile.Settings.Citrix.XDC01
$StoreFrontURL = "https://workspace.bretty.me.uk/Citrix/StoreWeb"

$DatabaseServer = $MyConfigFile.Settings.Microsoft.DatabaseServer
$DatabaseUser = $MyConfigFile.Settings.Microsoft.DatabaseUser
$DatabasePassword = $MyConfigFile.Settings.Microsoft.DatabasePassword
$DatabaseName_Site = "$SiteName" + "_" + "site"
$DatabaseName_Logging = "$SiteName" + "_" + "logging"
$DatabaseName_Monitor = "$SiteName" + "_" + "monitor"

$DatabasePassword = $DatabasePassword | ConvertTo-SecureString -asPlainText -Force
$Database_CredObject = New-Object System.Management.Automation.PSCredential($DatabaseUser,$DatabasePassword)

$CVM = $MyConfigFile.Settings.Nutanix.CVM
$User = $MyConfigFile.Settings.Nutanix.User
$Pwd = $MyConfigFile.Settings.Nutanix.Pwd
$NetName = "vlan_100"
$ConnectionName = "nutanix_ahv"
$ResourceName = "$NetName"
$Pwd = $Pwd | ConvertTo-SecureString -asPlainText -Force
$RootPath = "XDHyp:\Connections\$ConnectionName\"
$NetworkPath = "$RootPath" + "$Netname.network"

# Start the transcript for the install
Start-Transcript $LogPS

# Import Citrix Powershell Module
Write-Verbose "Import PowerShell Module" -Verbose
Add-PSSnapin Citrix.*

Write-Verbose "Creating $SiteName Site and Databases" -Verbose  
New-XDDatabase -AdminAddress $env:COMPUTERNAME -SiteName $SiteName -DataStore Site -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName_site -DatabaseCredentials $Database_CredObject 
New-XDDatabase -AdminAddress $env:COMPUTERNAME -SiteName $SiteName -DataStore Logging -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName_logging -DatabaseCredentials $Database_CredObject 
New-XDDatabase -AdminAddress $env:COMPUTERNAME -SiteName $SiteName -DataStore Monitor -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName_monitor -DatabaseCredentials $Database_CredObject
New-XDSite -AdminAddress $env:COMPUTERNAME -SiteName $SiteName -DatabaseServer $DatabaseServer -LoggingDatabaseName $DatabaseName_logging -MonitorDatabaseName $DatabaseName_monitor -SiteDatabaseName $DatabaseName_site

Write-Verbose "Setting up Licensing Server" -Verbose  
Set-ConfigSite -AdminAddress $env:COMPUTERNAME -LicenseServerName $LicenseServer -LicenseServerPort $Port -LicensingModel $LicensingModel -ProductCode $ProductCode -ProductEdition $ProductEdition
$LicenseServer_AdminAddress = Get-LicLocation -AddressType $AddressType -LicenseServerAddress $LicenseServer -LicenseServerPort $Port
$LicenseServer_CertificateHash = $(Get-LicCertificate  -AdminAddress $LicenseServer_AdminAddress).CertHash
Set-ConfigSiteMetadata -AdminAddress $env:COMPUTERNAME -Name "CertificateHash" -Value $LicenseServer_CertificateHash

# Trust XML Requests
Write-Verbose "Trust Requests to the XML Port" -Verbose
Set-BrokerSite -TrustRequestsSentToTheXmlServicePort $true

# Configure Admin Group for Site
Write-Verbose "Configure Admin Group" -Verbose
New-AdminAdministrator -AdminAddress $env:COMPUTERNAME -Name $FullAdminGroup
Add-AdminRight -AdminAddress $env:COMPUTERNAME -Administrator $FullAdminGroup -Role 'Full Administrator' -All

# Rename the Config Zone
Write-Verbose "Rename the Config Zone" -Verbose
Rename-ConfigZone -Name 'Primary' -NewName $ZoneName

# Adding StoreFront Configuration
Write-Verbose "Adding StoreFront Configuration" -Verbose
$configuration = New-SfStorefrontAddress -Url $StoreFrontURL -Description "Citrix StoreFront Services" -Name "Citrix StoreFront" -Enabled $true
Get-SfStorefrontAddress -ByteArray $configuration
$Config = Get-BrokerConfigurationSlot | where-object {$_.Name -eq "RS"}
$SlotID = $Config.Uid
New-BrokerMachineConfiguration -AdminAddress $env:COMPUTERNAME -ConfigurationSlotUid $SlotID -LeafName 1 -Policy $configuration

# Adding Nutanix Connection
Write-Verbose "Adding Nutanix Configuration" -Verbose
Set-HypAdminConnection -AdminAddress "$XDC01:443"
New-Item -ConnectionType "Custom" -CustomProperties "" -HypervisorAddress @("$CVM") -Path @("$RootPath") -Persist -PluginId "AcropolisFactory" -Scope @() -SecurePassword $Pwd -UserName $User
$Hyp = Get-ChildItem -Path @('XDHyp:\Connections')
$HypGUID = $Hyp.HypervisorConnectionUid.Guid
New-BrokerHypervisorConnection -AdminAddress "$XDC01:443" -HypHypervisorConnectionUid "$HypGUID"
$job = [Guid]::NewGuid()
New-Item -HypervisorConnectionName $ConnectionName -JobGroup $job -NetworkPath @("$NetworkPath") -Path @("XDHyp:\HostingUnits\$ResourceName") -PersonalvDiskStoragePath @() -RootPath $RootPath -StoragePath @()

Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript
