$vcenters = ""
$filepath = ".\VM-Scripts"
Add-PSSnapin VMware.VimAutomation.Core

foreach ($vcenter in $vcenters) {
    Write-Host $vcenter
    Connect-VIServer -Server $vcenter -User  -Password -Force
    get-vm | get-snapshot | select vm, name, created, description | export-csv -path $filepath"\"$vcenter-Snaps.csv -NoTypeInformation
  
}