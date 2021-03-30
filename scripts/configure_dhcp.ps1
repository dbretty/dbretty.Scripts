Param
(
    [parameter(ValueFromPipeline = $true)][String[]]$DNSServer,
    [parameter(ValueFromPipeline = $true)][String[]]$Gateway
)

Add-WindowsFeature -Name DHCP
Import-Module DHCPServer
$DNSName = $ENV:computername + "." + $ENV:userdnsdomain
$ServerIP = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne "127.0.0.1"} | Select-Object IPAddress
Add-DhcpServerInDC -DnsName $DNSName -IPAddress $ServerIP.IPAddress
Set-DHCPServerv4OptionValue -ComputerName $DNSName -DnsServer $DNSServer -DnsDomain $ENV:userdnsdomain -Router $Gateway
