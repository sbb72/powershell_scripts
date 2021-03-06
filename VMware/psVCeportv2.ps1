$allhosts = @()
$vcenters = ""
$filepath = "C:\Scott\VM-Scripts"

Add-PSSnapin VMware.VimAutomation.Core
foreach($vcenter in $vcenters){
    Write-Host $vcenter
    Connect-VIServer -Server $vcenter -User csc_mcs -Password P@ssw0rd -Force
    $hosts = Get-VMHost 
        foreach($esxhost in $hosts){
        $repdata = "" | Select VCenter, ESXHost, ESXVer, Manufacturer, Model, BIOS, PowerState, NoOfPCores, TotalMemGB
        $repdata.vcenter = $vcenter
        $repdata.ESXHost = $esxhost.Name
        $repdata.ESXVer = $esxhost.ExtensionData.Config.Product.FullName
        $repdata.Manufacturer = $esxhost.Manufacturer
        $repdata.Model =  $esxhost.Model
        $repdata.BIOS = $esxhost.ExtensionData.Hardware.BiosInfo.BiosVersion
        $repdata.PowerState = $esxhost.powerstate
        $repdata.NoOfPCores = $esxhost.NumCpu
        $repdata.TotalMemGB = $esxhost.MemoryTotalGB
    	$allhosts += $repdata
        }
        #export to .csv file
        $allhosts | export-csv -path $filepath"\"$vcenter.csv -NoTypeInformation  
}
