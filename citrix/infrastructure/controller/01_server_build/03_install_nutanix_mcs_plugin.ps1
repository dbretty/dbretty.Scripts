# Set the start Date and Time
Write-Verbose "Setting Script Parameters" -Verbose
$StartDTM = (Get-Date)

# Configure Script Variables
Write-Verbose "Configure Variables" -Verbose
$Vendor = "Nutanix"
$Product = "MCS Plugin"
$Version = "2.3.0.0"
$PackageName = "NutanixAHV_Citrix_Plugin"
$InstallerType = "msi"
$LogPS = "${env:SystemRoot}" + "\Temp\$Vendor $Product $Version PS Wrapper.log"
$LogApp = "${env:SystemRoot}" + "\Temp\$PackageName.log"
$UnattendedArgs = "/i $PackageName.$InstallerType ALLUSERS=1 ISCITRIXMCSINSTALL=""C:\Program Files\Common Files\Citrix\HCLPlugins\CitrixMachineCreation\v1.0.0.0\"" PLUGININSTALLPATH=""C:\Program Files\Common Files\Citrix\HCLPlugins\CitrixMachineCreation\v1.0.0.0\"" INSTALLFOLDER=""C:\Program Files\Common Files\Citrix\HCLPlugins\CitrixMachineCreation\v1.0.0.0\NutanixAcropolis\"" PVSINSTALLFOLDER=""C:\Program Files\Common Files\Citrix\HCLPlugins\CitrixMachineCreation\v1.0.0.0\NutanixAHV\"" REGISTERPLUGINSTOREPATH=""C:\Program Files\Common Files\Citrix\HCLPlugins\CitrixMachineCreation\v1.0.0.0\"" ADDLOCAL=F7_9_INSTALLFOLDER REMOVE=PVS_F7_14_INSTALLFOLDER,F7_9_CWA_INSTALLFOLDER /qn /liewa $LogApp"

# Start the transcript for the install
Start-Transcript $LogPS

# Change to the Citrix Controller Directory of the Media
If (Test-Path $Version) 
{
    Write-Verbose "Changing to Nutanix MCS Plugin Directory Install Directory" -Verbose
    Set-Location $Version
} Else {
    Write-Verbose "Stop logging" -Verbose
    $EndDTM = (Get-Date)
    Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
    Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
    Stop-Transcript
    Write-Warning "Failed to find or verify $Version"
    Throw "Could not find directory $Version"
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

# Stop Logging
Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript
