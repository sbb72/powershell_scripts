$vCenterServer = "vcname"
$Snapshotdays = "-356"
$PatchingDate = Get-date -f dd-MM-yyyy
function DeleteSnapshots {
    param (
        OptionalParameters
    )
    
    Get-VM | Get-Snapshot | Where { $_.name -like "#Patching#*" -and $_.created -lt (get-date).addDays(-7) } | Remove-Shapshot -confirm:$false -whatif
}



function CreateSnapshot {
    param (
        [Switch]$ServerList,
        [Switch]$Server
    )
    ForEach ($Server in $ServerList) {
    
        $NewSnapshot = New-Snapshot -VM $Server -Name "#Patching# on $PatchingDate" -Description "Created by $env:USERNAME 24/7 Team $PatchingDate"
        If ($NewSnapshot) {
            Return "Snapshot $Snapshot created."
        }
        else {
            Return "Error occured during snapshot creation."
        }
        New-Snapshot -Name "#Patching# at $PatchingDate" -Description "Created by $env:USERNAME 24/7 Team $PatchingDate"
  
    }  
}



Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue 

Connect-VIServer $vCenterServer

try
{ $vCenterConnection = Connect-VIServer $ComputerName -WarningVariable vCenterConnectWarnings -ErrorVariable vCenterConnectErrors }
catch {        
    Write-Verbose "Failed to connect to vCenter, error message: $($_.Exception.Message)"
    $vCenterResponse.Detail = "Failed to connect to vCenter, error message: $($_.Exception.Message)"
}


$VMs = Get-VM | Select-Object Name

# Check for any VM snapshots            
[Array]$Snapshots = Get-View -ViewType VirtualMachine -Filter @{"Snapshot" = "" } -Server $vCenterServer
foreach ($Snapshot in $Snapshots) {
    if ($Snapshot.Snapshot.RootSnapshotList.CreateTime -lt (Get-Date).AddDays($Snapshotdays) -and ) {
        Write-Host "Deleting $($Snapshot.Snapshot.RootSnapshotList.Name) for $($Snapshot.Name), created on $($Snapshot.Snapshot.RootSnapshotList.CreateTime), current size $([Math]::Round(($Snapshot.LayoutEx.File | Where-Object { $_.Name -match "-delta.vmdk" } | Measure-Object -Property Size -Sum).Sum/1MB,0))MB and power state $($Snapshot.Runtime.PowerState)"
        get-vm -Name $($Snapshot.Name) | Get-Snapshot | Remove-Snapshot -Confirm:$false
    }
    
}



Disconnect-VIServer -Server $vCenter -Confirm:$false


#Connect to vSphere
$VIServer = Read-Host "Enter IP or Hostname for your VI Server"
$VIUser = Read-Host "Enter Username"
$VIPass = Read-Host "Enter Password"
Connect-VIServer -server $VIServer -user $VIUser -pass $VIPass

#Enumerate VMs and search for Protect Snapshots.  Red machines have snapshots to remove, green have no snapshots.
foreach ($vm in get-vm | sort Name) {
    $vmname = $vm.name
    $snaps = get-snapshot -vm $vm 
    foreach ($snap in $snaps) {
        $snapName = $snap.name
        if ($snapname -like "Protect Patch") {
            Write-Host "Found snapshot: $snapname on $vmname" -foregroundcolor red 
                                               
            remove-snapshot -snapshot $snap -confirm:$false
        }
        Else {
            Write-Host "No protect snapshot found on $vmname" -foregroundcolor green 
        }
    }
}
