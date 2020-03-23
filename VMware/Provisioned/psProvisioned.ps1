$vcenter = "vcentername"
$strCluster = "cluster name"
$strFolderPath = ".\Vmware"


# Adds the powercli cmdlets
Add-PSSnapin VMware.VimAutomation.Core -erroraction SilentlyContinue

# Disconnects from any viserver to stop potential false results in ouput
if ($global:DefaultVIServer -ne $null) {
	write-host "Disconnecting from current vcenter(s)"
	disconnect-viserver * -confirm:$false
}
else
{ write-host "Not connected to any vCenter, continuing" }

Connect-VIServer -Server $vcenter

#Get host CPU and Memory
Get-Cluster $strCluster | Get-VMHost | Sort Name | `
	Get-View | Select Name, Version, build, @{N = "Type"; E = { $_.Hardware.SystemInfo.Vendor + " " + $_.Hardware.SystemInfo.Model } }, `
@{N = "CPU"; E = { "PROC:" + $_.Hardware.CpuInfo.NumCpuPackages + " CORES:" + $_.Hardware.CpuInfo.NumCpuCores + " MHZ: " + `
			[math]::round($_.Hardware.CpuInfo.Hz / 1000000, 0) }
}, `
@{N = "MEM"; E = { "" + [math]::round($_.Hardware.MemorySize / 1GB, 0) + " GB" } } `
| Export-Csv "$strFolderPath\$strCluster.csv" -NoType

#List assigned CPU & Memory to VMs in the VMware cluster
Get-cluster $strCluster | Get-VM | Select Name, NumCPU, MemoryGB | Export-Csv "$strFolderPath\$strCluster-VMS.csv" -NoType

#List Datastore per Cluster
Get-Cluster $strCluster | Get-VMHost | Get-Datastore | Select Name, CapacityGB, FreeSpaceGB | Export-CSV "$strFolderPath\$strCluster-DS.csv" -Notype