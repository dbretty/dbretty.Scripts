Param
(
    [parameter(ValueFromPipeline = $true)][String[]]$DNSServer,
    [parameter(ValueFromPipeline = $true)][String[]]$Gateway,
    [parameter(ValueFromPipeline = $true)]$ScopeName,
    [parameter(ValueFromPipeline = $true)]$ScopeNetwork,
    [parameter(ValueFromPipeline = $true)]$StartAddress,
    [parameter(ValueFromPipeline = $true)]$EndAddress,
    [parameter(ValueFromPipeline = $true)]$SubnetMask
)

Import-Module DHCPServer
$DNSName = $ENV:computername + "." + $ENV:userdnsdomain

Add-DHCPServerv4Scope -EndRange $EndAddress -Name $ScopeName -StartRange $StartAddress -SubnetMask $SubnetMask -State Active -ComputerName $ENV:computername
Set-DHCPServerv4OptionValue -ComputerName $DNSName -ScopeId $ScopeNetwork -DnsServer $DNSServer -DnsDomain $ENV:userdnsdomain -Router $Gateway
