# Determine where to do the logging
$logPS = "C:\Windows\Temp\secure_delivery_controller.log"
 
# Set the start Date and Time
Write-Verbose "Setting Script Parameters" -Verbose
$StartDTM = (Get-Date)

# Start the transcript for the install
Start-Transcript $LogPS

# Disable 8 Dot 3 File Name Generation
Write-Verbose "Successfully Installed $Vendor $Product $Version" -Verbose  
Start-Process -FilePath "fsutil.exe" -ArgumentList "8dot3name set 0" -Wait -Passthru

# Disable Remote PC Multiple Assignment
Write-Verbose "Disable Remote PC Multiple Assignment" -Verbose
set-ItemProperty -path "REGISTRY::\HKEY_LOCAL_MACHINE\Software\Citrix\DesktopServer\" -name AllowMultipleRemotePCAssignments -value 0

# Bind the Certificate to Port 443
Write-Verbose "Disable Remote PC Multiple Assignment" -Verbose
$Certificate = Get-ChildItem -path cert:\LocalMachine\My
$Thumb = $Certificate.Thumbprint
netsh http add sslcert ipport=0.0.0.0:443 certhash=$Thumb appid='{00112233-4455-6677-8899-AABBCCDDEEFF}'

# Force HTTPS XML Traffic and Disable HTTP Listener
Write-Verbose "Force HTTPS XML Traffic and Disable HTTP Listener" -Verbose
set-ItemProperty -path "REGISTRY::\HKEY_LOCAL_MACHINE\Software\Citrix\DesktopServer\" -name XmlServicesEnableNonSsl -value 0
Restart-Service "Citrix Broker Service"

# Disable Cert Revocation Checking
Write-Verbose "Disable Certificate Revocation Checking" -Verbose
set-ItemProperty -path "REGISTRY::\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing\" -name State -value 146944

# Stop Logging
Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript