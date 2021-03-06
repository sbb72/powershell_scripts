$outarray = @()
$vcenters = ""

Add-PSSnapin VMware.VimAutomation.Core
foreach($vcenter in $vcenters){
       Write-Host $vcenter
    Connect-VIServer -Server $vcenter -User csc_mcs -Password P@ssw0rd -Force

    $hosts = Get-VMHost 
    foreach($esxhost in $hosts){
    $outarray += New-Object PsObject -property @{
    'VCenter' = $vcenter
    'ESX Host' = $esxhost.Name
    'ESX Ver' = $esxhost.ExtensionData.Config.Product.FullName
    'Server Manufacturer' = $esxhost.Manufacturer
    'Server Model' =  $esxhost.Model
    'Server BIOS Ver' = $esxhost.ExtensionData.Hardware.BiosInfo.BiosVersion
    'PowerState' = $esxhost.powerstate
    'NoOfPCores' = $esxhost.NumCpu
    'TotalMemGB' = $esxhost.MemoryTotalGB
	$allout += $outarray
        }
     }
    #export to .csv file
    $allout | export-csv C:\Temp\$vcenter.csv -NoTypeInformation
    $outarray.clear
    
}
