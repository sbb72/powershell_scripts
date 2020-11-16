function CreateSnapshot {
    param (
        [switch]$CreateSnapshot = $null,
        [switch]$DeleteSnapshot = $null,
        [Switch]$ServerList,
        [string]$User = $env:USERNAME,
        [switch]$Snapshotdetails = "$env:USERNAME-Created Snapshot",
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Switch]$vCenterServer,

        [int]$SnapshotAge = 7
    )
    $PatchingDate = Get-date -f dd-MM-yyyy_HH:mm
    
    Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue 
   
    try {
        Connect-VIServer $vCenterServer -WarningVariable vCenterConnectWarnings -ErrorVariable vCenterConnectErrors
    }
    catch {        
        Write-Verbose "Failed to connect to vCenter, error message: $($_.Exception.Message)"
    }
    ForEach ($Server in $ServerList) {
        $NewSnapshot = New-Snapshot -VM $Server -Name "#Patching# on $PatchingDate" -Description "Created by $User 24/7 Team $PatchingDate"
        If ($NewSnapshot) {
            Return "Snapshot $Snapshot created."
        }
        else {
            Return "Error occured during snapshot creation."
        }
        
    }  
}

<#
function activesnapshots {

    $VMs = Get-VM | Select-Object Name
    # Check for any VM snapshots            
    [Array]$Snapshots = Get-View -ViewType VirtualMachine -Filter @{"Snapshot" = "" } -Server $vCenterServer
    foreach ($Snapshot in $Snapshots) {
        if ($Snapshot.Snapshot.RootSnapshotList.CreateTime -lt (Get-Date).AddDays($Snapshotdays) -and ) {
            Write-Host "Deleting $($Snapshot.Snapshot.RootSnapshotList.Name) for $($Snapshot.Name), created on $($Snapshot.Snapshot.RootSnapshotList.CreateTime), current size $([Math]::Round(($Snapshot.LayoutEx.File | Where-Object { $_.Name -match "-delta.vmdk" } | Measure-Object -Property Size -Sum).Sum/1MB,0))MB and power state $($Snapshot.Runtime.PowerState)"
            get-vm -Name $($Snapshot.Name) | Get-Snapshot | Remove-Snapshot -Confirm:$false
        }
    }

}
#>

<#
function deletesnapshots {
    param (
      
    )
    $AllNamedSnapshots = Get-cluster NonProductionCluster | Get-Snapshot | Where Name -eq "PreToolsandHardware20180310"
    $SnapshotRemaining = $AllNamedSnapshots.count
    $Tasks = @{}
     
    While ($SnapshotRemaining -gt 0){
        $RemoveSnapshotTasks = $AllNamedSnapshots | Select -First 15
        foreach($SnapShottobeRemoved in $RemoveSnapshotTasks){
            $Tasks[(Remove-Snapshot $SnapShottobeRemoved -RunAsync -Confirm:$false).id] = $SnapShottobeRemoved
        }
        $RunningTasks = $Tasks.count
        While ($RunningTasks -gt 0){
            Get-Task | % {
                If($tasks.containskey($_.id) -and $_.state -eq "Success"){
                    $tasks.Remove($_.Id)
                    $RunningTasks--
                    $SnapshotRemaining--
                }
            }
            Start-Sleep -Seconds 10
            Write-host "There are still $RunningTasks task(s) running" -BackgroundColor Black -ForegroundColor Yellow
        }
        $AllNamedSnapshots = Get-cluster NonProductionCluster | Get-Snapshot | Where Name -eq "PreToolsandHardware20180310"
    }
}

#>