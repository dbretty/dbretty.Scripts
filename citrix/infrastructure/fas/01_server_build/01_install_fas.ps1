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
$Product = "Federated Authentication Service"
$PackageName = "FederatedAuthenticationService_x64"
$InstallerType = "msi"
$Version = $MyConfigFile.Settings.Citrix.Version
$LogPS = "${env:SystemRoot}" + "\Temp\$Vendor $Product $Version PS Wrapper.log"
$LogApp = "${env:SystemRoot}" + "\Temp\$PackageName.log"
$UnattendedArgs = "/i $PackageName.$InstallerType ALLUSERS=1 /qn /liewa $LogApp"
$Destination = "$Version\x64\Federated Authentication Service\"
$Computer = "$env:computername" + "$"

# Start the transcript for the install
Start-Transcript $LogPS

# Change to the Citrix FAS Directory of the Media
If (Test-Path $Destination) 
{
    Write-Verbose "Changing to FAS Install Directory" -Verbose
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
If ((Start-Process msiexec.exe -ArgumentList $UnattendedArgs -Wait -Passthru).ExitCode -eq 0)
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

# Install the AD Management Powershell SDK
Write-Verbose "Install AD Management Powershell SDK" -Verbose
Add-WindowsFeature "RSAT-AD-Tools"

# Add the Server to the Enterprise Admins Group
Write-Verbose "Add the Server to the Enterprise Admins Group" -Verbose
ADD-ADGroupMember "Enterprise Admins" –members "$Computer"

# Stop Logging
Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript