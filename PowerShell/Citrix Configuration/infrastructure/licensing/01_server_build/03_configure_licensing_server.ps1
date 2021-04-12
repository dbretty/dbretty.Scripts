# Determine where to do the logging
$logPS = "C:\Windows\Temp\configure_licensing_server.log"
 
# Set the start Date and Time
Write-Verbose "Setting Script Parameters" -Verbose
$StartDTM = (Get-Date)

# Define Citrix Licensing Server Administrators Group
Write-Verbose "Defining Citrix Licensing Server Admin Group" -Verbose
$AdminAccount = "BRETTY\lic admins"

# Start the transcript for the install
Start-Transcript $LogPS

# Copy down License Files
Write-Verbose "Copy License Files" -Verbose
If (Test-Path $PSScriptRoot\custom\licensing) 
{
    Write-Verbose "File Found - Copying License File To Server" -Verbose
    Copy-Item -Path "$PSScriptRoot\custom\licensing\cvad.lic" -Destination "C:\Program Files (x86)\Citrix\Licensing\MyFiles\cvad.lic" -Recurse -Force
} 
Else 
{
    Write-Verbose "File Not Found - Skipped" -Verbose
}

# Copy down Certificate Files
Write-Verbose "Copy Certificate Files" -Verbose
If (Test-Path $PSScriptRoot\custom\licensing) 
{
    Write-Verbose "File Found - Copying Certificate Files To Server" -Verbose
    Copy-Item -Path "$PSScriptRoot\custom\licensing\server.crt" -Destination "C:\Program Files (x86)\Citrix\Licensing\LS\Conf\server.crt" -Recurse -Force
    Copy-Item -Path "$PSScriptRoot\custom\licensing\server.key" -Destination "C:\Program Files (x86)\Citrix\Licensing\LS\Conf\server.key" -Recurse -Force
    Copy-Item -Path "$PSScriptRoot\custom\licensing\server.crt" -Destination "C:\Program Files (x86)\Citrix\Licensing\WebServicesForLicensing\Apache\Conf\server.crt" -Recurse -Force
    Copy-Item -Path "$PSScriptRoot\custom\licensing\server.key" -Destination "C:\Program Files (x86)\Citrix\Licensing\WebServicesForLicensing\Apache\Conf\server.key" -Recurse -Force
} 
Else 
{
    Write-Verbose "File(s) Not Found - Skipped" -Verbose
}

# Restart Services
Write-Verbose "Restart Citrix Licensing Services" -Verbose
Restart-Service "Citrix Licensing"
Restart-Service "CitrixWebServicesForLicensing"

# Add Administrator Account
Write-Verbose "Add Administrator Account to License Server" -Verbose
add-pssnapin citrix*
$LicAddress = Get-LicLocation
$CertHash = Get-LicCertificate -AdminAddress $LicAddress
New-LicAdministrator -AdminAddress $LicAddress -Account $AdminAccount -Group -CertHash $CertHash.CertHash

# Disable CEIP
Write-Verbose "Disable CEIP" -Verbose
Set-LicCEIPOption -AdminAddress "https://localhost:8083" -CEIPOption "None" -CertHash $(Get-LicCertificate -AdminAddress "https://localhost:8083").CertHash

# Stop Logging
Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript
