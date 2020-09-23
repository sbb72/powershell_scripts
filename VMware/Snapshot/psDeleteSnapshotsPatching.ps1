try
{ $vCenterConnection = Connect-VIServer $ComputerName -WarningVariable vCenterConnectWarnings -ErrorVariable vCenterConnectErrors }
catch
{        
    Write-Verbose "$([Datetime]::Now.ToShortDateString()) $([Datetime]::Now.ToString("HH:mm:ss")) Connection failed"
    # If the connection fails report a failure with Connet-VIServer
    $vCenterResponse.Component = "Connectivity"
    $vCenterResponse.Message = "Failed to connect to vCenter"
    $vCenterResponse.Detail = "Failed to connect to vCenter, error message: $($_.Exception.Message)"
    return $vCenterResponse
}
$ErrorActionPreference = $OriginalErrorActionPreference

# If the connection fails report a failure with Connet-VIServer
if(($vCenterConnection -and $vCenterConnection.IsConnected -eq $false) -or !$vCenterConnection)
{
    Write-Verbose "$([Datetime]::Now.ToShortDateString()) $([Datetime]::Now.ToString("HH:mm:ss")) Connection failed"
    $vCenterResponse.Component = "Connectivity"
    $vCenterResponse.Message = "Failed to connect to vCenter"
    if($vCenterConnectErrors)
    { $vCenterResponse.Detail = "Failed to connect to vCenter, error message: $($vCenterConnectErrors[0].Exception.Message)" }
    else
    { $vCenterResponse.Detail = "Failed to connect to vCenter" }
    return $vCenterResponse
}




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
