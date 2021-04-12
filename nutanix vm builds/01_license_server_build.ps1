Write-Verbose "Setting Arguments" -Verbose
$StartDTM = (Get-Date)

$MyConfigFileloc = ("$env:Settings\Applications\Settings.xml")
[xml]$MyConfigFile = (Get-Content $MyConfigFileLoc)

$CVM = $MyConfigFile.Settings.Nutanix.CVM
$User = $MyConfigFile.Settings.Nutanix.User
$Pwd = $MyConfigFile.Settings.Nutanix.Pwd
$Password = ConvertTo-SecureString $Pwd -AsPlainText -Force
$Network = $MyConfigFile.Settings.Nutanix.NetName
$ISO = $MyConfigFile.Settings.Nutanix.ISO
$Container = $MyConfigFile.Settings.Nutanix.Container

Write-Verbose "Connecting to CVM" -Verbose

cd "C:\Program Files (x86)\Nutanix Inc\NutanixCmdlets\powershell\import_modules"
./ImportModules.ps1
Add-PSSnapin nutanixcmdletspssnapin
connect-ntnxcluster -server $CVM -username $User -password $Password -AcceptInvalidSSLCerts -ForcedConnection
get-ntnxcluster

# Licensing Server

$VMName = "lic"
$MAC = "50:6b:8d:2d:15:7f"
$VRAM = 2048
$VCPU = 1

New-NTNXVirtualMachine -Name $VMName -NumVcpus $VCPU -MemoryMb $VRAM

## Disk Creation - Setting the SCSI disk of 50GB on Containner ID 1025 (get-ntnxcontainer -> ContainerId)
$diskCreateSpec = New-NTNXObject -Name VmDiskSpecCreateDTO
$diskcreatespec.containerName = $Container
$diskcreatespec.sizeMb = 61440
 
Start-Sleep -s 5

# Get the VmID of the VM
$vminfo = Get-NTNXVM | where {$_.vmName -eq $VMName}
$vmId = ($vminfo.vmid.split(":"))[2]

# Set NIC for VM on default vlan (Get-NTNXNetwork -> NetworkUuid)
$nic = New-NTNXObject -Name VMNicSpecDTO
$nic.networkUuid = $Network
$nic.macAddress = $MAC

Add-NTNXVMNic -Vmid $vmId -SpecList $nic

# Creating the Disk
$vmDisk =  New-NTNXObject -Name VMDiskDTO
$vmDisk.vmDiskCreate = $diskCreateSpec
 
# Mount ISO Image
$diskCloneSpec = New-NTNXObject -Name VMDiskSpecCloneDTO
$ISOImage = (Get-NTNXImage | ?{$_.name -eq $ISO})
$diskCloneSpec.vmDiskUuid = $ISOImage.vmDiskId
#setup the new ISO disk from the Cloned Image
$vmISODisk = New-NTNXObject -Name VMDiskDTO
#specify that this is a Cdrom
$vmISODisk.isCdrom = $true
$vmISODisk.vmDiskClone = $diskCloneSpec
$vmDisk = @($vmDisk)
$vmDisk += $vmISODisk

# Adding the Disk ^ ISO to the VM
Add-NTNXVMDisk -Vmid $vmId -Disks $vmDisk

# Power On the VM
Set-NTNXVMPowerOn -Vmid $VMid
