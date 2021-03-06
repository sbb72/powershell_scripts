#List of VCS
$VCSServerName = Get-Content ".\servers.txt"

Add-PSsnapin VMware.VimAutomation.Core
Foreach ($VCS in $VCSServerName) {

    Connect-VIServer $VCS
    $hosts = Get-VMHost
    foreach ($esxhost in $hosts) {
        $esxhost.Name, ",", `
            $esxhost.Manufacturer, $esxhost.Model, ",", `
            $esxhost.ExtensionData.Hardware.BiosInfo.BiosVersion, ",", `
            $esxhost.ExtensionData.Config.Product.FullName | Export-csv "F:\SBarker\Scripts\$VCS-HWinfo.csv"
    
    } 
}



$vCenter = Read-Host "Enter the vCenter server name"

Connect-VIServer $vCenter

$vmhosts = get-vmhost * 
$vmhosts | Sort Name -Descending | % { $server = $_ | get-view; `
        $server.Config.Product | select `
    @{ Name = "Server Name"; Expression = { $server.Name } }, `
        Name, Version, Build, FullName, ApiVersion }

Disconnect-VIServer -Confirm:$false