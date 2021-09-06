Function DeleteSnapshots {

<#
        .SYNOPSIS
        A function to delete snapshots.

        .DESCRIPTION
        The function establishes a connection to vCenter then deletes snaphost based on switches set.
        of vSphere, VMs and ESXi hosts (including their hardware).

        .PARAMETER vCenterServer
        Name of the vCenter to manage the snapshots.
        
        .PARAMETER IgnoreSnapshot
        This switch will ignore the snapshot based on the name of the snapshot.
        By default it will check if '#Keep#' is in the name of the snapshot, if true it will skip past that snapshot and move on.

        .PARAMETER IgnoreVM
        This switch will ignore the snapshot based on the name of the VM or VMs in the switch.
        By default it will check if all snapshots.

        .PARAMETER maxJobs
        This switch will only delete the predefined number of snapshots at once.
        By default it will only remove 5 concurrent snapshots.

        .PARAMETER SnapshotAge
        This switch defines the max age of the snaphot.
        By default it's 3 days, so any snapshot older than 3 days will be deleted.

        .Example
        DeleteSnapshots -vCenterServer "vCenter01" -IgnoreSnapshot "Bobs snapshot" -IgnoreVM @("Server01","Server02") -verbose
        The example below will start a transscript, import the module and then stop the transscript:
        Start-Transcript -Path  "Path_to_log_file\$(Get-Date -Format dd-MM-yyyy)_DeleteSnapshots.log";Import-Module Path_to_module\Delete_Snapshots.psm1;DeleteSnapshots -vCenterServer "vCenter01" -verbose;Stop-Transcript

        
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$vCenterServer,    
    
    [Parameter(Mandatory=$false)]
    [String]$IgnoreSnapshot ="#Keep#",
       
    [Parameter(Mandatory=$false)]
    [String[]]$IgnoreVM,
    
    [Parameter(Mandatory=$false)]
    [int]$maxJobs = 5,

    [Parameter(Mandatory=$false)]
    [ValidateRange(1,14)]
    [Int]$SnapshotAge = -3
)

 Write-Verbose "$([Datetime]::Now.ToShortDateString()) $([Datetime]::Now.ToString("HH:mm:ss")) Loading PowerCLI"
# Load the VMWare PowerShell snap-in, disable the certificate revocation check and then re-enable it as otherwise it's slow (about 1 minute)
# Check if the VMware.PowerCLI module is available and, if so, load it.  Otherwise try loading the VMware.VimAutomation.Core Powershell snappin

Remove-Variable -Name ModuleCheck -Force -ErrorAction SilentlyContinue
$ModuleCheck = Get-Module -ListAvailable -Name VMware.VimAutomation.Core
if($ModuleCheck)
{ Import-Module -Name VMware.VimAutomation.Core -Force }
else
{
    Set-ItemProperty -Path "REGISTRY::\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing" -Name State -Value 146944
    try
    { Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue }
    catch
    {
        Set-ItemProperty -Path "REGISTRY::\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing" -Name State -Value 146432
        Write-Verbose "Unable to find/load the VMware PowerCLI module or Powershell Snappin, error message: $($_.Exception.Message)"
    }
    Set-ItemProperty -Path "REGISTRY::\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing" -Name State -Value 146432
}

#Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue 
Write-Verbose "$([Datetime]::Now.ToShortDateString()) $([Datetime]::Now.ToString("HH:mm:ss")) Connecting to vCenter"
# Login to the vCenter server
$ErrorActionPreference = "Stop"

Try {
    $vCenterConnection = Connect-VIServer $vCenterServer
    }
catch {        
    Write-Verbose "$([Datetime]::Now.ToShortDateString()) $([Datetime]::Now.ToString("HH:mm:ss")) Connection failed"
    Write-Verbose "Failed to connect to vCenter, error message: $($_.Exception.Message)"
    return "Failed to connect to vCenter, error message: $($_.Exception.Message)"
    }

#Try and get a list of active snapshots
Try {
    $Snapshots = Get-vm | Get-Snapshot | Select-Object -Property Vm, Name, created,description,@{label="TotalSizeMB";Expression={"{0:N0} MB" -f ($_.SizeMB)}}, PowerState -ErrorAction stop
    }
Catch {
    Write-Verbose "Failed to retrieve a list of snapshots, error message: $($_.Exception.Message)"
    return "Failed to retrieve a list of snapshots, error message: $($_.Exception.Message)"
    }

#If command gt -0
$($Snapshots | Measure-Object).Count

Write-Verbose "Current active Snapshots $(($Snapshots | Measure-Object).Count)"

Write-Verbose "List of VMs in the IgnoreVM List $IgnoreVM"
    If (($Snapshots | Measure-Object).Count -gt 0) {

        Foreach ($VM in $Snapshots) {
            
            If ($VM.VM.Name -notin $IgnoreVM) {
            Write-Verbose "Checking $($VM.VM.Name) Snapshot name $($VM.Name) Created $($VM.Created)."
            Write-Verbose "$($VM.VM.Name) is not in IgnoreList"

                if($($VM.Created) -lt [datetime]::Now.AddDays($SnapshotAge)) {
                
                    Write-Verbose "$($VM.VM.Name) Active snapshot....checking if in ignored switch"
                
                        If ($($VM.Name) -match $IgnoreSnapshot) {
                
                            Write-Verbose "Skipping.....$($VM.VM.Name) Snapshot name has '$IgnoreSnapshot' entered"
                    
                        }

                        ELSE {
                    
                            Write-Verbose "Deleting snapshot for VM $($VM.VM.Name)"
                    
                            Get-Snapshot $($VM.VM.Name) | Remove-Snapshot -Confirm:$false -RunAsync #-WhatIf
                    
                            $current = Get-Task | where {'RemoveSnapshot_Task' -and 'Running','Queued' -contains $_.State}
                    
                                while ($current.count -gt $maxJobs) {
                                sleep 5
                                $current = Get-Task | where {'RemoveSnapshot_Task' -and 'Running','Queued' -contains $_.State}
                                }
                        }

                }
                    
                ELSE {
                
                    Write-Verbose "Skipping...snapshot less than $SnapshotAge days old, VM is $($VM.VM.Name), Created $($VM.Created), snapshot name $($VM.Name)"
                
                }
        
        }

            ELSE {
            
                Write-Verbose "Skipping......$($VM.vm.name) is in the IgnoreVM list"
            }
        }
    Disconnect-VIServer $vCenterServer -Force -Confirm:$false
    }
}
