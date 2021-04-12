# Determine where to do the logging
$logPS = "C:\Windows\Temp\install_director_pre_reqs.log"
 
# Set the start Date and Time
Write-Verbose "Setting Script Parameters" -Verbose
$StartDTM = (Get-Date)

# Start the transcript for the install
Start-Transcript $LogPS

# Install Citrix StoreFront Pre Reqs
Write-Verbose "Installing Citrix Director Pre Reqs" -Verbose
Install-WindowsFeature NET-Framework-45-Core,GPMC,RSAT-ADDS-Tools,RDS-Licensing-UI,WAS,Telnet-Client

# Stop Logging
Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript
