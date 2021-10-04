<#
.SYNOPSIS
    Add Computer To Domain
.DESCRIPTION
    Add Computer To Domain
.OUTPUTS
    Log File stored in C:\Windows\Temp
.NOTES
    Version:        1.0
    Author:         David Brett
    Creation Date:  14/04/2021
    Purpose/Change: Initial script development
  
.EXAMPLE
    ./Add-Domain.ps1
#>

#----------------------------------------------------------[Parameters]------------------------------------------------------------

Param
(
        [parameter(Mandatory=$true)][string]$DomainName,
        [parameter(Mandatory=$false)][string]$OU,
        [parameter(Mandatory=$true)][string]$Username,
        [parameter(Mandatory=$true)][string]$Password
)

#----------------------------------------------------------[Functions]------------------------------------------------------------
function JoinToDomain {

    [CmdletBinding()]

    Param(
        [parameter(Mandatory=$true)][string]$DomainName,
        [parameter(Mandatory=$false)][string]$OU,
        [parameter(Mandatory=$true)][string]$Username,
        [parameter(Mandatory=$true)][string]$Password
    )

    If ($env:computername -eq $env:userdomain) {
        Write-Output "Not in domain"
        $adminname = "$DomainName\$Username"
        $adminpassword = ConvertTo-SecureString -asPlainText -Force -String "$Password"
        $credential = New-Object System.Management.Automation.PSCredential($adminname,$adminpassword)
        Add-computer -DomainName $DomainName -Credential $credential -OUPath $OU -Force -PassThru -ErrorAction Stop
    } 
    Else 
    {
        Write-Output "Already in domain"
    }
}

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Set the start Date and Time
Write-Output "Setting Script Parameters"
$StartDTM = (Get-Date)

# Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Log File Info
$sLogPath = "C:\Windows\Temp"
$sLogName = "Add-Domain.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName
Write-Output "Setting Log File to $sLogFile"

# Start the transcript for the script
Start-Transcript $sLogFile
Write-Output "Started Transcript"

#-----------------------------------------------------------[Script]----------------------------------------------------------------

# Adding Computer To Domain and Add Local Administrators
JoinToDomain -DomainName $DomainName -Username $Username -Password $Password -OU $OU

Restart-Computer -Force -AsJob

#-----------------------------------------------------------[Clean]----------------------------------------------------------------

# Stop Logging
Write-Output "Stop logging"
$EndDTM = (Get-Date)
Write-Output "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds"
Write-Output "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes"
Stop-Transcript
