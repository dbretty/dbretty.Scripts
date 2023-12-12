<#
.SYNOPSIS
    Install and Configure WSUS on a Server
.DESCRIPTION
    Install and Configure WSUS on a Server
.OUTPUTS
    Log File stored in C:\Windows\Temp
.NOTES
  Version:        1.0
  Author:         XenAppBlog
  Creation Date:  31/03/2021
  Purpose/Change: Initial Credit for Script goes to Eric at XenAppBlog - Edited to suit this install procedure
  
.EXAMPLE
  ./configure_wsus.ps1 -server_version "Windows Server 2019
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
$sLogName = "configure_wsus.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName
Write-Host "Setting Log File to $sLogFile"

# Start the transcript for the script
Start-Transcript $sLogFile
Write-Host "Started Transcript"

#----------------------------------------------------------[Parameters]------------------------------------------------------------

Param
()

#-----------------------------------------------------------[Script]----------------------------------------------------------------

# Check for the status of the WSUS Installation
$Status = Get-WindowsFeature -Name UpdateServices

if($Status.installed -eq $True){
    # WSUS is already installed
    Write-Host "WSUS is already installed"
    $WSUSInstalled = $True
} else {
    # WSUS is not installed, install it now
    Write-Host "WSUS not installed, installing now"
    $Result = Add-WindowsFeature -Name UpdateServices
    if($result.success -eq $True){
        Write-Host "WSUS installed"
        $WSUSInstalled = $True
    } else {
        Write-Host "WSUS install failed"
        $WSUSInstalled = $False
    }
}

# Validate DHCP was installed successfully
if($WSUSInstalled -eq $true){

    # Create WSUS Directory and point installation to it
    New-Item -Path C: -Name WSUS -ItemType Directory
    CD "C:\Program Files\Update Services\Tools"
    .\wsusutil.exe postinstall CONTENT_DIR=C:\WSUS

    # Create WSUS Directory and point installation to it
    Write-Host "Get WSUS Server Object" 
    $wsus = Get-WSUSServer
 
    # Create WSUS Directory and point installation to it
    Write-Host "Connect to WSUS server configuration" 
    $wsusConfig = $wsus.GetConfiguration()
    
    # Download from Microsoft
    Write-Host "Set to download updates from Microsoft Updates" 
    Set-WsusServerSynchronization -SyncFromMU
    
    # Set Updates to English
    Write-Host "Set Update Languages to English and save configuration settings" 
    $wsusConfig.AllUpdateLanguagesEnabled = $false           
    $wsusConfig.SetEnabledUpdateLanguages("en")           
    $wsusConfig.Save()
    
    # Initial Sync
    Write-Host "Get WSUS Subscription and perform initial synchronization to get latest categories" 
    $subscription = $wsus.GetSubscription()
    $subscription.StartSynchronizationForCategoryOnly()
    
    While ($subscription.GetSynchronizationStatus() -ne 'NotProcessing') {
        Write-Host "Initial WSUS Sync Running" 
        Start-Sleep -Seconds 5
    }
    
    Write-Host "Sync is Done" 
    
    # Disable Products
    Write-Host "Disable Products"
    Get-WsusServer | Get-WsusProduct | Where-Object -FilterScript { $_.product.title -match "Office" } | Set-WsusProduct -Disable
    Get-WsusServer | Get-WsusProduct | Where-Object -FilterScript { $_.product.title -match "Windows" } | Set-WsusProduct -Disable
    
    # Enable Products
    Write-Host "Enable Products" 
    Get-WsusServer | Get-WsusProduct | Where-Object -FilterScript { $_.product.title -match "Windows Server 2019" } | Set-WsusProduct
    
    # Disable Language Lacks
    Write-Host "Disable Language Packs" 
    Get-WsusServer | Get-WsusProduct | Where-Object -FilterScript { $_.product.title -match "Language Packs" } | Set-WsusProduct -Disable
    
    # Set Classifications
    Write-Host "Configure the Classifications" 
    Get-WsusClassification | Where-Object {
    $_.Classification.Title -in (
    'Critical Updates',
    'Definition Updates',
    'Feature Packs',
    'Security Updates',
    'Service Packs',
    'Update Rollups',
    'Updates')
    } | Set-WsusClassification
    
    # Configure Sync
    Write-Host "Configure Synchronizations" 
    $subscription.SynchronizeAutomatically=$true
    
    # Schedule Sync
    Write-Host "Set synchronization scheduled for midnight each night"
    $subscription.SynchronizeAutomaticallyTimeOfDay= (New-TimeSpan -Hours 0)
    $subscription.NumberOfSynchronizationsPerDay=1
    $subscription.Save()
    
    # Start Sync
    Write-Host "Kick Off Synchronization" 
    $subscription.StartSynchronization()
} else {
    Write-Host "There was a problem installing WSUS, please check the logs for more information"
}

#-----------------------------------------------------------[Clean]----------------------------------------------------------------
# Stop Logging
Write-Host "Stop logging"
$EndDTM = (Get-Date)
Write-Host "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds"
Write-Host "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes"
Stop-Transcript