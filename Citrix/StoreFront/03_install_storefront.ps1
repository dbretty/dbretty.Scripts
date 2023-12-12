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
$Product = "StoreFront"
$Version = $MyConfigFile.Settings.Citrix.Version
$LogPS = "${env:SystemRoot}" + "\Temp\$Vendor $Product $Version PS Wrapper.log"
$UnattendedArgs = '/quiet /configure_firewall /COMPONENTS STOREFRONT /nosql /noreboot'
$Destination = "$Version\x64\XenDesktop Setup\"

# Start the transcript for the install
Start-Transcript $LogPS

# Change to the Citrix StoreFront Directory of the Media
If (Test-Path $Destination) 
{
    Write-Verbose "Changing to StoreFront Install Directory" -Verbose
    Set-Location $Destination
} Else {
    Write-Verbose "Stop logging" -Verbose
    $EndDTM = (Get-Date)
    Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
    Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
    Stop-Transcript
    Write-Warning "Failed to find or verify $Destination"
    Throw "Could not find directory $Destination"
}

# Install the software
Write-Verbose "Starting Installation of $Vendor $Product $Version" -Verbose  
If ((Start-Process -FilePath "XenDesktopServerSetup.exe" -ArgumentList $unattendedArgs -Wait -Passthru).ExitCode -eq 0)
{
    Write-Verbose "Successfully Installed $Vendor $Product $Version" -Verbose  
}
else
{
    Write-Verbose "Stop logging" -Verbose
    $EndDTM = (Get-Date)
    Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
    Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
    Stop-Transcript
    Write-Warning "Could not install $Vendor $Product $Version"
    Throw "Could not install $Vendor $Product $Version"
}

# Stop Logging
Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript