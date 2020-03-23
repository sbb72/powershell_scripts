<#
.DESCRIPTION
Export the Esxi Version, Build, Make, Model, CPU Type and Memory of ESX hots
.INPUTS
  Change $vCenter variable with a valid location of the text file containing the list of names to query
.OUTPUTS
   Change $LogName, the output will be written to the current folder.
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  02-01-2018
  Purpose/Change: Initial script  
Version 1.0
Created Script
#>

# Adds the powercli cmdlet
Add-PSSnapin VMware.VimAutomation.Core -erroraction SilentlyContinue

$strLogDate = Get-Date -f ddMMyyyy
#Log Name
$LogName = "Accountx"
#VC List
$vCenter = Get-Content "F:\sbarker\Scripts\VMware\VCs.txt"
#$vCenter ="Server1","Server2"
$serverdetails = @()

ForEach ($VC in $vCenter) {
connect-VIServer $VC

    ForEach ($Cluster in Get-Cluster){

        ForEach ($Item in ($Cluster | Get-VMHost)) {
        $ServerStat = "" | Select vCenter,ServerName,Make,Model,Cluster,ESXiVersion,ESXIBuild,CPUType,Processors,Cores,Memory
        $ServerStat.vCenter = $VC
        $vmhost_view = $Item | Get-View -Property Name, Config, Hardware
        Write-Host "Checking versions on $Item"

        $ServerStat.ServerName = $vmhost_view.Name
        $ServerStat.Cluster = $Cluster.Name
        $ServerStat.Make = $vmhost_view.Hardware.SystemInfo.Vendor
        $ServerStat.Model = $vmhost_view.Hardware.SystemInfo.Model

        $ServerStat.ESXiVersion = $vmhost_view.Config.Product.version
        $ServerStat.ESXiBuild = $vmhost_view.Config.Product.build
        $CPU = $vmhost_view.Hardware.CpuPKG[0].Description
        $ServerStat.CPUType = $CPU
        $ServerStat.Processors = $vmhost_view.Hardware.CpuInfo.NumCpuPackages
        $ServerStat.Cores = $vmhost_view.Hardware.CpuInfo.NumCpucores
        $ServerStat.Memory = ([math]::round($vmhost_view.Hardware.MemorySize / 1GB, 0))
        $serverdetails += $ServerStat
        }

    }
Disconnect-VIServer $VC -force -Confirm:$false
}
$serverdetails | Select vCenter,ServerName,Make,Model,ESXiVersion,ESXIBuild,CPUType,Processors,Cores,Memory | Export-csv -Path .\$LogName-$strLogDate.csv -Notype
