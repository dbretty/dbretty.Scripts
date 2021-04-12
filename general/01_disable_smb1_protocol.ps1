# Determine where to do the logging
$logPS = "C:\Windows\Temp\disable_smb1_protocol.log"
 
# Set the start Date and Time
Write-Verbose "Setting Script Parameters" -Verbose
$StartDTM = (Get-Date)

# Start the transcript for the install
Start-Transcript $LogPS

# Disable SMB1
try 
{
    Write-Verbose "Disabling SMB 1" -Verbose
    Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol
    Write-Verbose "SMB 1 Disabled" -Verbose
}
catch 
{
    Write-Verbose "There was a problem disabling SMB 1 - Please check the logs for more information" -Verbose
}

# Stop Logging
Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript
