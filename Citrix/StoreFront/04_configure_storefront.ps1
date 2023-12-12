# Determine where to do the logging
$logPS = "C:\Windows\Temp\configure_storefront.log"
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
$Domain = $env:USERDOMAIN
$XDC01 = $MyConfigFile.Settings.Citrix.XDC01
 
# Configure Store Variables
Write-Verbose "Configure Store Variables" -Verbose
$baseurl = "https://workspace.bretty.me.uk"
$Farmname = "cvad"
$Port = "443"
$TransportType = "HTTPS"
$sslRelayPort = "443"
$Servers = "$XDC01"
$LoadBalance = $false
$FarmType = "XenDesktop"
$FriendlyName = "Store"
$SFPath = "/Citrix/Store"
$SFPathWeb = "/Citrix/StoreWeb"
$SFPathDA = "/Citrix/StoreDesktopAppliance"
$SiteID = 1
$GatewayAddress = "https://workspace.bretty.me.uk"
$InternalBeacon = "https://workspaceac.bretty.me.uk"
$ExternalBeacon1 = "https://workspace.bretty.me.uk"
$ExternalBeacon2 = "https://www.citrix.com"
$GatewayName = "workspace.bretty.me.uk"
$staservers = "https://$XDC01/scripts/ctxsta.dll"
$CallBackURL = "https://workspacecb.bretty.me.uk"
$AuthPath = "/Citrix/Authentication"
$DefaultDomain = $Domain


# Import the StoreFront SDK
Write-Verbose "Importing StoreFront SDK" -Verbose
import-module "C:\Program Files\Citrix\Receiver StoreFront\Scripts\ImportModules.ps1"

Write-Verbose "StoreFront Cluster Doesn't Exists - Creating" -Verbose
# Do the initial Config
Set-DSInitialConfiguration -hostBaseUrl $baseurl -farmName $Farmname -port $Port -transportType $TransportType -sslRelayPort $sslRelayPort -servers $Servers -loadBalance $LoadBalance -farmType $FarmType -StoreFriendlyName $FriendlyName -StoreVirtualPath $SFPath -WebReceiverVirtualPath $SFPathWeb -DesktopApplianceVirtualPath $SFPathDA

# Add NetScaler Gateway
$GatewayID = ([guid]::NewGuid()).ToString()
Add-DSGlobalV10Gateway -Id $GatewayID -Name $GatewayName -Address $GatewayAddress -CallbackUrl $CallBackURL -RequestTicketTwoSTA $false -Logon Domain -SessionReliability $true -SecureTicketAuthorityUrls $staservers -IsDefault $true

# Add Gateway to Store
$gateway = Get-DSGlobalGateway -GatewayId $GatewayID
$AuthService = Get-STFAuthenticationService -SiteID $SiteID -VirtualPath $AuthPath
Set-DSStoreGateways -SiteId $SiteID -VirtualPath $SFPath -Gateways $gateway
Set-DSStoreRemoteAccess -SiteId $SiteID -VirtualPath $SFPath -RemoteAccessType "StoresOnly"
Add-DSAuthenticationProtocolsDeployed -SiteId $SiteID -VirtualPath $AuthPath -Protocols CitrixAGBasic
Set-DSWebReceiverAuthenticationMethods -SiteId $SiteID -VirtualPath $SFPathWeb -AuthenticationMethods ExplicitForms,CitrixAGBasic
Enable-STFAuthenticationServiceProtocol -AuthenticationService $AuthService -Name CitrixAGBasic

# Add beacon External
Set-STFRoamingBeacon -internal $InternalBeacon -external $ExternalBeacon1,$ExternalBeacon2

# Enable Unified Experience
$Store = Get-STFStoreService -siteID $SiteID -VirtualPath $SFPath
$Rfw = Get-STFWebReceiverService -SiteId $SiteID -VirtualPath $SFPathWeb
Set-STFStoreService -StoreService $Store -UnifiedReceiver $Rfw -Confirm:$False

# Set the Default Site
Set-STFWebReceiverService -WebReceiverService $Rfw -DefaultIISSite:$True

# Configure Trusted Domains
Set-STFExplicitCommonOptions -AuthenticationService $AuthService -Domains $DefaultDomain -DefaultDomain $DefaultDomain -HideDomainField $True -AllowUserPasswordChange Always -ShowPasswordExpiryWarning Windows

# Enable the authentication methods
# Enable-STFAuthenticationServiceProtocol -AuthenticationService $AuthService -Name Forms-Saml,Certificate
Enable-STFAuthenticationServiceProtocol -AuthenticationService $AuthService -Name ExplicitForms

# Fully Delegate Cred Auth to NetScaler Gateway
Set-STFCitrixAGBasicOptions -AuthenticationService $AuthService -CredentialValidationMode Kerberos

# Create Featured App Groups1
$FeaturedGroup = New-STFWebReceiverFeaturedAppGroup `
    -Title "Office 365" `
    -Description "Office 365 Applications" `
    -TileId appBundle1 `
    -ContentType AppName `
    -Contents "Outlook 2016","Word 2016","Excel 2016","PowerPoint 2016","Access 2016","Publisher 2016"
Set-STFWebReceiverFeaturedAppGroups -WebReceiverService $Rfw -FeaturedAppGroup $FeaturedGroup

# Set Receiver for Web Auth Methods
Set-STFWebReceiverAuthenticationMethods -WebReceiverService $Rfw -AuthenticationMethods ExplicitForms,CitrixAGBasic

# Set Receiver Deployment Methods
Set-STFWebReceiverPluginAssistant -WebReceiverService $Rfw -Html5Enabled Fallback -enabled $false

# Enable PNAgent Services
Enable-STFStorePna -StoreService $store -DefaultPnaService:$True

# Set Session Timeout Options
Set-STFWebReceiverService -WebReceiverService $Rfw -SessionStateTimeout 60
Set-STFWebReceiverAuthenticationManager -WebReceiverService $Rfw -LoginFormTimeout 30

# Set the Workspace Control Settings
Set-STFWebReceiverUserInterface -WebReceiverService $Rfw -WorkspaceControlLogoffAction "None"
Set-STFWebReceiverUserInterface -WebReceiverService $Rfw -WorkspaceControlEnabled $True
Set-STFWebReceiverUserInterface -WebReceiverService $Rfw -WorkspaceControlAutoReconnectAtLogon $False
Set-STFWebReceiverUserInterface -WebReceiverService $Rfw -WorkspaceControlShowReconnectButton $True
Set-STFWebReceiverUserInterface -WebReceiverService $Rfw -WorkspaceControlShowDisconnectButton $True

# Enable Socket Pooling
Set-STFStoreFarmConfiguration -StoreService $Store -PooledSockets $True

# Set Client Interface Settings
Set-STFWebReceiverUserInterface -WebReceiverService $Rfw -AutoLaunchDesktop $False
Set-STFWebReceiverUserInterface -WebReceiverService $Rfw -ReceiverConfigurationEnabled $True

# Enable Loopback on HTTP
Set-DSLoopback -SiteId $SiteID -VirtualPath $SFPathWeb -Loopback On

# Enable STS
Set-STFWebReceiverStrictTransportSecurity -WebReceiverService $Rfw -Enabled $True

# Stop Logging
Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript