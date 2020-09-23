$vCenterServer = "vcname"
$Snapshotdays =""

Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue 

Connect-VIServer $vCenterServer

$VMs = Get-VM | Select Name

if($VMs -and $VMs.Count -gt 0)
        {
            # Check for any VM snapshots            
            [Array]$Snapshots = Get-View -ViewType VirtualMachine -Filter @{"Snapshot"=""} -Server $vCenterServer
                foreach($Snapshot in $Snapshots)
                {
                    if($Snapshot.Snapshot.RootSnapshotList.CreateTime -lt (Get-Date).AddDays(-356))
                    {
                        Write-Host "Deleting $($Snapshot.Snapshot.RootSnapshotList.Name) for $($Snapshot.Name), created on $($Snapshot.Snapshot.RootSnapshotList.CreateTime), current size $([Math]::Round(($Snapshot.LayoutEx.File | Where-Object { $_.Name -match "-delta.vmdk" } | Measure-Object -Property Size -Sum).Sum/1MB,0))MB and power state $($Snapshot.Runtime.PowerState)"
                        get-vm -Name $($Snapshot.Name) | Get-Snapshot | Remove-Snapshot -Confirm:$false
                    }
                
                }
            
}

Disconnect-VIServer -Server $vCenter -Confirm:$false