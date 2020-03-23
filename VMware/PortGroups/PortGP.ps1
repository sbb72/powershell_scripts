# Adds the powercli cmdlets
Add-PSSnapin VMware.VimAutomation.Core -erroraction SilentlyContinue

$vcenter = "Servername"
Connect-VIServer -Server $vcenter

$PortGP = Import-CSV P:\Sbarker\Scripts\Vmware\PortGPs\BC01.csv
#$ClusterName = "VM_Cluster"
$VMHosts = "ESXServerName"
Foreach ($GP in $PortGP){
    $NewPortSwitch = $GP.Name
    $vSwitchName = $GP.VirtualSwitch
    $VLANID = $GP.VLanId

    Foreach ($VMHost in $VMHosts){
        IF (($VMHost | Get-VirtualPortGroup -name $NewPortSwitch -ErrorAction SilentlyContinue) -eq $null){
            Write-host "Creating $NewPortSwitch on VMhost $VMHost" -ForegroundColor Yellow
            $NEWPortGroup = Get-VirtualSwitch -VMHost $VMhost -Name $vSwitchName | New-VirtualPortGroup -Name $NewPortSwitch -VLanId $VLANID
        }
    }
}