<#
.SYNOPSIS
    Configure a base OU Structure for Active Directory
.DESCRIPTION
    Configure a base OU Structure for Active Directory
.PARAMETER root_ou
    The root OU you want to build your structure from
.PARAMETER lab_name
    The top level OU for the lab name
.OUTPUTS
    Log File stored in C:\Windows\Temp
.NOTES
  Version:        1.0
  Author:         David Brett
  Creation Date:  31/03/2021
  Purpose/Change: Initial script development
  
.EXAMPLE
  ./configure_ou_structure.ps1 -root_ou "DC=bretty,DC=lab" -lab_name "bretty"
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Set the start Date and Time
Write-Host "Setting Script Parameters"
$StartDTM = (Get-Date)

# Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Script Version
$sScriptVersion = "1.0"

# Log File Info
$sLogPath = "C:\Windows\Temp"
$sLogName = "configure_ou_structure.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName
Write-Host "Setting Log File to $sLogFile"

# Start the transcript for the script
Start-Transcript $sLogFile
Write-Host "Started Transcript"

#----------------------------------------------------------[Parameters]------------------------------------------------------------

Param
(
    [parameter(ValueFromPipeline = $true,Mandatory=$True)]$root_ou,
    [parameter(ValueFromPipeline = $true,Mandatory=$True)]$lab_name
)

#-----------------------------------------------------------[Script]----------------------------------------------------------------

# Create Top Level OU and Build Root Lab OU
Write-Host "Create Top Level Lab OU"
Write-Host $root_ou
Write-Host $lab_name
New-ADOrganizationalUnit -Path $root_ou -Name $lab_name -Verbose
$root_lab_ou = "OU=" + $lab_name + "," + $root_ou

# Create Function Specific OU's
Write-Host "Create Function Specific OU's"
New-ADOrganizationalUnit -Path $root_lab_ou -Name 'Groups' -Verbose
New-ADOrganizationalUnit -Path $root_lab_ou -Name 'Users' -Verbose
New-ADOrganizationalUnit -Path $root_lab_ou -Name 'Servers' -Verbose
New-ADOrganizationalUnit -Path $root_lab_ou -Name 'Workstaions' -Verbose
New-ADOrganizationalUnit -Path $root_lab_ou -Name 'VDA' -Verbose

# Create Group Specific OU's
Write-Host "Create Group Specific OU's"
$root_group_ou = "OU=Groups," + $root_lab_ou + "OU=" + $lab_name + "," + $root_ou
New-ADOrganizationalUnit -Path $root_group_ou -Name 'User' -Verbose
New-ADOrganizationalUnit -Path $root_group_ou -Name 'Admin' -Verbose
New-ADOrganizationalUnit -Path $root_group_ou -Name 'App' -Verbose
New-ADOrganizationalUnit -Path $root_group_ou -Name 'General' -Verbose

# Create User Specific OU's
Write-Host "Create User Specific OU's"
$root_user_ou = "OU=Users," + $root_lab_ou + "OU=" + $lab_name + "," + $root_ou
New-ADOrganizationalUnit -Path $root_user_ou -Name 'Service' -Verbose
New-ADOrganizationalUnit -Path $root_user_ou -Name 'Standard' -Verbose
New-ADOrganizationalUnit -Path $root_user_ou -Name 'Admin' -Verbose
New-ADOrganizationalUnit -Path $root_user_ou -Name 'External' -Verbose

# Create Server Specific OU's
Write-Host "Create Server Specific OU's"
$root_server_ou = "OU=Servers," + $root_lab_ou + "OU=" + $lab_name + "," + $root_ou
New-ADOrganizationalUnit -Path $root_server_ou -Name 'Infrastructure' -Verbose
New-ADOrganizationalUnit -Path $root_server_ou -Name 'General' -Verbose
$root_infrastructure_ou = "OU=Infrastructure,OU=Servers," + $root_lab_ou + "OU=" + $lab_name + "," + $root_ou
New-ADOrganizationalUnit -Path $root_infrastructure_ou -Name 'Microsoft' -Verbose
New-ADOrganizationalUnit -Path $root_infrastructure_ou -Name 'Citrix' -Verbose
New-ADOrganizationalUnit -Path $root_infrastructure_ou -Name 'VMware' -Verbose
New-ADOrganizationalUnit -Path $root_infrastructure_ou -Name 'General' -Verbose
$root_microsoft_ou = "OU=Microsoft,OU=Infrastructure,OU=Servers," + $root_lab_ou + "OU=" + $lab_name + "," + $root_ou
New-ADOrganizationalUnit -Path $root_microsoft_ou -Name 'SQL' -Verbose
New-ADOrganizationalUnit -Path $root_microsoft_ou -Name 'File' -Verbose
New-ADOrganizationalUnit -Path $root_microsoft_ou -Name 'Print' -Verbose
New-ADOrganizationalUnit -Path $root_microsoft_ou -Name 'ADFS' -Verbose
$root_citrix_ou = "OU=Citrix,OU=Infrastructure,OU=Servers," + $root_lab_ou + "OU=" + $lab_name + "," + $root_ou
New-ADOrganizationalUnit -Path $root_citrix_ou -Name 'Licensing' -Verbose
New-ADOrganizationalUnit -Path $root_citrix_ou -Name 'StoreFront' -Verbose
New-ADOrganizationalUnit -Path $root_citrix_ou -Name 'WEM' -Verbose
New-ADOrganizationalUnit -Path $root_citrix_ou -Name 'PVS' -Verbose
New-ADOrganizationalUnit -Path $root_citrix_ou -Name 'FAS' -Verbose
New-ADOrganizationalUnit -Path $root_citrix_ou -Name 'Controllers' -Verbose
New-ADOrganizationalUnit -Path $root_citrix_ou -Name 'Cloud Connectors' -Verbose
New-ADOrganizationalUnit -Path $root_citrix_ou -Name 'Session Recording' -Verbose

# Create Workstation Specific OU's
Write-Host "Create Workstatiob Specific OU's"
$root_workstation_ou = "OU=Workstaions," + $root_lab_ou + "OU=" + $lab_name + "," + $root_ou
New-ADOrganizationalUnit -Path $root_workstation_ou -Name 'Windows 10' -Verbose
New-ADOrganizationalUnit -Path $root_workstation_ou -Name 'Windows 7' -Verbose

# Create VDA Specific OU's
Write-Host "Create VDA SPecific OU's"
$root_vda_ou = "OU=VDA," + $root_lab_ou + "OU=" + $lab_name + "," + $root_ou
New-ADOrganizationalUnit -Path $root_vda_ou -Name 'Citrix' -Verbose
New-ADOrganizationalUnit -Path $root_vda_ou -Name 'VMware' -Verbose
$root_citrix_vda_ou = "OU=Citrix,OU=VDA," + $root_lab_ou + "OU=" + $lab_name + "," + $root_ou
New-ADOrganizationalUnit -Path $root_citrix_vda_ou -Name 'PVS' -Verbose
New-ADOrganizationalUnit -Path $root_citrix_vda_ou -Name 'MCS' -Verbose
New-ADOrganizationalUnit -Path $root_citrix_vda_ou -Name 'Automated' -Verbose
$root_citrix_vda_pvs_ou = "OU=PVS,OU=Citrix,OU=VDA," + $root_lab_ou + "OU=" + $lab_name + "," + $root_ou
New-ADOrganizationalUnit -Path $root_citrix_vda_pvs_ou -Name 'Master' -Verbose
New-ADOrganizationalUnit -Path $root_citrix_vda_pvs_ou -Name 'Windows 10' -Verbose
New-ADOrganizationalUnit -Path $root_citrix_vda_pvs_ou -Name 'Server 2016' -Verbose
New-ADOrganizationalUnit -Path $root_citrix_vda_pvs_ou -Name 'Server 2019' -Verbose
$root_citrix_vda_mcs_ou = "OU=MCS,OU=Citrix,OU=VDA," + $root_lab_ou + "OU=" + $lab_name + "," + $root_ou
New-ADOrganizationalUnit -Path $root_citrix_vda_mcs_ou -Name 'Master' -Verbose
New-ADOrganizationalUnit -Path $root_citrix_vda_mcs_ou -Name 'Windows 10' -Verbose
New-ADOrganizationalUnit -Path $root_citrix_vda_mcs_ou -Name 'Server 2016' -Verbose
New-ADOrganizationalUnit -Path $root_citrix_vda_mcs_ou -Name 'Server 2019' -Verbose

#-----------------------------------------------------------[Clean]----------------------------------------------------------------
# Stop Logging
Write-Host "Stop logging"
$EndDTM = (Get-Date)
Write-Host "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds"
Write-Host "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes"
Stop-Transcript

