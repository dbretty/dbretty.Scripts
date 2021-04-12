# Determine where to do the logging
$logPS = "C:\Windows\Temp\install_storefront_pre_reqs.log"
 
# Set the start Date and Time
Write-Verbose "Setting Script Parameters" -Verbose
$StartDTM = (Get-Date)

# Start the transcript for the install
Start-Transcript $LogPS

# Install Citrix StoreFront Pre Reqs
Write-Verbose "Installing Citrix StoreFront Pre Reqs" -Verbose
Install-WindowsFeature -Name Web-Static-Content,Web-Default-Doc,Web-Http-Errors,Web-Http-Redirect,Web-Http-Logging,Web-Mgmt-Console,Web-Scripting-Tools,Web-Windows-Auth,Web-Basic-Auth,Web-AppInit,Web-Asp-Net45,Net-Wcf-Tcp-PortSharing45

# Stop Logging
Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript
