# Set the start Date and Time
Write-Verbose "Setting Script Parameters" -Verbose
$StartDTM = (Get-Date)

# Configure Script Variables
Write-Verbose "Configure Variables" -Verbose
$Vendor = "Microsoft"
$Product = "SQL Server"
$Version = "2017"
$PackageName = "setup"
$InstallerType = "exe"
$LogPS = "${env:SystemRoot}" + "\Temp\$Vendor $Product $Version PS Wrapper.log"

# Start the transcript for the install
Start-Transcript $LogPS

Write-Verbose "Setting Options" -Verbose
$OPTIONS = ""
$OPTIONS += " /Q"
$OPTIONS += " /ACTION=`"Install`""
$OPTIONS += " /FEATURES=`"SQL`"" 
$OPTIONS += " /INSTANCENAME=`"MSSQLSERVER`""
$OPTIONS += " /SQLSVCACCOUNT=`"NT AUTHORITY\NETWORK SERVICE`""
$OPTIONS += " /SQLSYSADMINACCOUNTS=`"$env:userdnsdomain\sql admins`" `"BUILTIN\Administrators`""
$OPTIONS += " /AGTSVCACCOUNT=`"NT AUTHORITY\NETWORK SERVICE`""
$OPTIONS += " /BROWSERSVCSTARTUPTYPE=`"Automatic`""
$OPTIONS += " /IACCEPTSQLSERVERLICENSETERMS"
Write-Host $Options

# Change to the SQL Directory of the Media
If (Test-Path $Version) 
{
    Write-Verbose "Changing to SQL Install Directory" -Verbose
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
If ((Start-Process "$PackageName.$InstallerType" $Options -Wait -Passthru).ExitCode -eq 0)
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