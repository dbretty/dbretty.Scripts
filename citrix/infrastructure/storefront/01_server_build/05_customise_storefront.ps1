# Determine where to do the logging
$logPS = "C:\Windows\Temp\customise_storefront.log"

# Set the start Date and Time
Write-Verbose "Setting Script Parameters" -Verbose
$StartDTM = (Get-Date)

# Start the transcript for the install
Start-Transcript $LogPS

# Copy down Customisation Files
Write-Verbose "Copy Customisation Files" -Verbose
If (Test-Path $PSScriptRoot\custom\storefront) 
{
    Write-Verbose "File Found - Copying Customisation Files To Server" -Verbose
    Copy-Item -Path "$PSScriptRoot\custom\storefront\background.png" -Destination "C:\inetpub\wwwroot\Citrix\StoreWeb\custom\background.png" -Recurse -Force
    Copy-Item -Path "$PSScriptRoot\custom\storefront\login.png" -Destination "C:\inetpub\wwwroot\Citrix\StoreWeb\custom\login.png" -Recurse -Force
    Copy-Item -Path "$PSScriptRoot\custom\storefront\header.png" -Destination "C:\inetpub\wwwroot\Citrix\StoreWeb\custom\header.png" -Recurse -Force
    Copy-Item -Path "$PSScriptRoot\custom\storefront\strings.en" -Destination "C:\inetpub\wwwroot\Citrix\StoreWeb\custom\strings.en" -Recurse -Force
    Copy-Item -Path "$PSScriptRoot\custom\storefront\style.css" -Destination "C:\inetpub\wwwroot\Citrix\StoreWeb\custom\style.css" -Recurse -Force
} 
Else 
{
    Write-Verbose "File(s) Not Found - Skipped" -Verbose
}

# Disable Cert Revocation Checking
Write-Verbose "Disable Certificate Revocation Checking" -Verbose
set-ItemProperty -path "REGISTRY::\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing\" -name State -value 146944

# Stop Logging
Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript