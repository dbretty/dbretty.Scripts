<#
.SYNOPSIS
    Configure WinRM to Enable Terraform
.DESCRIPTION
    Configure WinRM to Enable Terraform
.OUTPUTS
    Log File stored in C:\Windows\Temp
.NOTES
  Version:        1.0
  Author:         David Brett
  Creation Date:  31/03/2021
  Purpose/Change: Initial script development
  
.EXAMPLE
  ./configure_winrm_for_terraform.ps1
#>

#----------------------------------------------------------[Parameters]------------------------------------------------------------

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Set the start Date and Time
Write-Host "Setting Script Parameters"
$StartDTM = (Get-Date)

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Log File Info
$sLogPath = "C:\Windows\Temp"
$sLogName = "configure_winrm_for_terraform.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName
Write-Host "Setting Log File to $sLogFile"

# Start the transcript for the script
Start-Transcript $sLogFile
Write-Host "Started Transcript"

#-----------------------------------------------------------[Script]----------------------------------------------------------------

# Remove HTTP listener
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse

$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "packer"
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force

# WinRM
write-host "Setting up WinRM"

cmd.exe /c winrm quickconfig -q
cmd.exe /c winrm set "winrm/config" '@{MaxTimeoutms="1800000"}'
cmd.exe /c winrm set "winrm/config/winrs" '@{MaxMemoryPerShellMB="1024"}'
cmd.exe /c winrm set "winrm/config/service" '@{AllowUnencrypted="true"}'
cmd.exe /c winrm set "winrm/config/client" '@{AllowUnencrypted="true"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/client/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{CredSSP="true"}'
cmd.exe /c winrm set "winrm/config/listener?Address=*+Transport=HTTPS" "@{Port=`"5986`";Hostname=`"packer`";CertificateThumbprint=`"$($Cert.Thumbprint)`"}"
cmd.exe /c netsh advfirewall firewall set rule group="remote administration" new enable=yes
cmd.exe /c netsh firewall add portopening TCP 5986 "Port 5986"
cmd.exe /c net stop winrm
cmd.exe /c sc config winrm start= auto
cmd.exe /c net start winrm

#-----------------------------------------------------------[Clean]----------------------------------------------------------------
# Stop Logging
Write-Host "Stop logging"
$EndDTM = (Get-Date)
Write-Host "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds"
Write-Host "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes"
Stop-Transcript