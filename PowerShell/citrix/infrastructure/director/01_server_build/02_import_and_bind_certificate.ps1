# Determine where to do the logging
$logPS = "C:\Windows\Temp\import_and_bind_director_certificate.log"
 
# Set the start Date and Time
Write-Verbose "Setting Script Parameters" -Verbose
$StartDTM = (Get-Date)

# Setting up script variables
Write-Verbose "Setting up script variables" -Verbose
$Passphrase = "password"
$CertificateFileName = "storefront_and_director.pfx"
$SecurePassphrase = ConvertTo-SecureString $Passphrase -AsPlainText -Force

# Start the transcript for the install
Start-Transcript $LogPS

# Import Certificate
Write-Verbose "Import Certificate" -Verbose
If (Test-Path $PSScriptRoot\custom\storefront) 
{
    Write-Verbose "File Found - Importing Certificate File To Server" -Verbose
    $Certificate = Import-PfxCertificate -FilePath $PSScriptRoot\custom\director\$CertificateFileName -CertStoreLocation Cert:\LocalMachine\My -Password $SecurePassphrase
} 
Else 
{
    Write-Verbose "File(s) Not Found - Skipped" -Verbose
}

# Import the web administration module
Write-Verbose "Import Web Administration Module" -Verbose
import-module WebAdministration

# Bind the certificate to IIS
Write-Verbose "Binding the certificate to the IIS Default Web Site" -Verbose
Push-Location IIS:
Set-Location SslBindings
New-webBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https
$Thumb = $Certificate.Thumbprint
get-item cert:\LocalMachine\MY\$Thumb | new-item 0.0.0.0!443
Pop-Location

# Stop Logging
Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript