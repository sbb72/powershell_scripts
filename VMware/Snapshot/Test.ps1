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