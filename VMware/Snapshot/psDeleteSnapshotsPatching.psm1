function CreateSnapshot {
    param (
        [switch]$CreateSnapshot = $null,
        [switch]$DeleteSnapshot = $null,
        [Switch]$ServerList,
        [string]$User = $env:USERNAME,

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