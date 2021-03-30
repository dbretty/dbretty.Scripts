Param
(
    [parameter(ValueFromPipeline = $true)][String[]]$Forwarder,
    [parameter(ValueFromPipeline = $true)][String[]]$SubnetsFull
)

if($null -eq $Forwarder){
    Write-host "No DNS Forwarder Passed in, skipping"
} else {
    Write-Host "Adding DNS Forwarder"
    try {
        Add-DnsServerForwarder -IPAddress $Forwarder
    } catch {
        write-host "DNS Forwarder already exists or there was an error adding it"
    }
}

if($null -eq $SubnetsFull){
    Write-host "No Reverse Lookup Subnets Passed in, skipping"
} else {
    Write-Host "Adding Reverse Lookup Zones"
    $Subnets = ($SubnetsFull).Split(",")
    foreach ($Subnet in $Subnets)
    {
        try {
            Add-DnsServerPrimaryZone -NetworkID "192.168.1.0/24" -ReplicationScope Domain
        } catch {
            write-host "Reverse Lookup Zone already exists or there was an error adding it"
        }
    }
}