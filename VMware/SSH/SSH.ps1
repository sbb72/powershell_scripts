#Add date for file name
$short_date = Get-Date -uformat "%Y%m%d"

# Adds the powercli cmdlets
Add-PSSnapin VMware.VimAutomation.Core -erroraction SilentlyContinue

#Change virtual center servers here!
$vcenter = "vCenter"

# Disconnects from any viserver to stop potential false results in ouput
if ($global:DefaultVIServer -ne $null){
		write-host "Disconnecting from current vcenter(s)"
		disconnect-viserver * -confirm:$false
	}
else {
write-host "Not connected to any vCenter, continuing"
}
   
Connect-VIServer -Server $vcenter

$Servers = "ESX_HostName"
foreach($Item in $Servers){
    Write-host "Checking $Item"
    
#Get-VMHost basxtsprdesx33.xchanginghosting.com | Get-VMHostService | Where {$_.Key -eq "TSM-SSH"} | Select VMHost, Label, Running
Get-VMHost $Item | Get-VMHostService | Where {$_.Key -eq "TSM-SSH"} | Start-VMHostService
      
}