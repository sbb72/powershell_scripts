Import-Module ".\Modules\Cleardisk.psm1" -Force
$servers = @()
$Logfilename = (Get-date -Format 'dd.MM.yyyy_hh_mm_ss') + '.log'
$Logfile =  ".\Logs\$Logfilename"
$response =  Read-host "Run for a single computer or a list of computer (Single/List)" 
switch ($response) {
    'Single' { $servers += Read-Host "Enter servername" }
    'List' { $file  = Get-FileName  -initialDirectory (Get-Location).ToString().Replace('Microsoft.PowerShell.Core\FileSystem::','') -title "Provide CSV file path containing list of servers"
            $servers = gc $file 
    }
    Default { write-log "No valid selection detected 'Single/List'" -Path $Logfile -Level Info}
}

if (Test-path ".\Directories.csv") {
    $Directories = Import-csv ".\Directories.csv" 
    [array]$DeleteDirectories = $Directories | where {$_.Delete -eq 'yes'}  | select -ExpandProperty Path
    [array]$CompressDirectories  = $Directories | where {$_.Compress -eq 'yes'}  | select -ExpandProperty Path
    [array]$GetSizeDirectories  = $Directories | where {$_.GetSize -eq 'yes'}  | select -ExpandProperty Path
}

$hashtable   = @{
    ServerName      = ""
    DiskSizeGB      = ""
    DiskSizeMB = ""
    FreeSpaceBeforeCleanMB    = ""
    FreeSpaceAfterCleanMB = ""
    FreeSpaceAfterCleanPercent = ""
    ClaimedSpaceMB = ""
    PageFile = ""
    FolderSizes = @()
    isOnline = $True

}

$DiskObjectCol = @()
foreach ($srv in $servers) {

    $isOnline = Test-Connection $srv -Count 1 -Quiet
    if(-not $isOnline) {
        Write-log "$srv is offline. Skipping this server" -Path $Logfile -Level Warn
        continue 
    }

    $Disk = Get-WmiObject -computername $srv Win32_LogicalDisk -Filter "DeviceID='C:'"
    $PagefileSize = Get-WmiObject Win32_PageFileSetting -ComputerName $srv
    $OS = Get-WmiObject -Computername $srv win32_operatingsystem

    $DiskObject = New-Object PSObject -Property $hashtable
    $DiskObject.ServerName = $srv
    $DiskObject.FreeSpaceBeforeCleanMB = [Math]::Round($Disk.Freespace / 1MB)
    $DiskObject.DiskSizeGB  = [Math]::Round($Disk.Size / 1GB)
    $DiskObject.DiskSizeMB  = [Math]::Round($Disk.Size / 1MB)
    [string]$DiskObject.PageFile = $PagefileSize | foreach {$_.Name + ':'+ $_.MaximumSize.tostring()+ 'MB'}

    foreach ($dir in $GetSizeDirectories) {
        $path = $dir.Replace('C:',"\\$srv\c$")
        if (test-path $path) {
            $path = $dir.Replace('C:',"\\$srv\c$")
            $DiskObject.FolderSizes  += Get-FolderSize -Path $path
        }
        else{
            Write-log "Unable to obtain folder size: $path doesnt exist" -Path $Logfile -Level Warn
        }

    }

    Write-log "Clearing BixFix cache" -Path $Logfile -Level Info
    Clear-BixFixCache -computername $srv -Architecture $OS.OSArchitecture

    Write-log "Clearing directories" -Path $Logfile -Level Info
    Clear-Directories -COMPUTERNAME $srv -DirectoryList $DeleteDirectories -LogFilePath $Logfile

    Write-log "Compressing directories" -Path $Logfile -Level Info
    try {
        Compress-Directories -ComputerName $srv -ListofDirectories $CompressDirectories 
    }
    catch {
        $msg = "Error occured comprression directories: " + $_.exception.message
        Write-log  $msg  -Path $Logfile -Level Warn
    }
    

 #   Write-log "Removing scheduled task" -Path $Logfile -Level Info
 #   Remove-ScheduledTask -ComputerName $srv

    Write-log "Clearing profiles" -Path $Logfile -Level Info
    Clear-Profiles -Computername $srv -DelProfExeLocation ".\DelProf2.exe" -LogFilePath $Logfile
    $Disk = Get-WmiObject -computername $srv Win32_LogicalDisk -Filter "DeviceID='C:'"

    $DiskObject.FreeSpaceAfterCleanMB = [Math]::Round($Disk.Freespace / 1MB)
    $DiskObject.ClaimedSpaceMB = $DiskObject.FreeSpaceAfterCleanMB - $DiskObject.FreeSpaceBeforeCleanMB 
    [string]$DiskObject.FolderSizes  =  $DiskObject.FolderSizes | ForEach-Object {$_.FolderName+ ':'+ $_.FolderSize.tostring()+ 'MB'}
    $DiskObject.FreeSpaceAfterCleanPercent =  [Math]::Round((($DiskObjectCol.FreeSpaceAfterCleanMB  / $DiskObjectCol.DiskSizeMB ) * 100))
    $DiskObjectCol +=  $DiskObject


}

if ($DiskObjectCol.count -gt 0) {
    $savereport   = Save-FileAs  -Title "Save the report"
    $DiskObjectCol | select ServerName, DiskSizeGB ,FreeSpaceBeforeCleanMB, FreeSpaceAfterCleanMB,FreeSpaceAfterCleanPercent, ClaimedSpaceMB, PageFile, FolderSizes  | export-csv $savereport[1] -NoTypeInformation
}
else{
    Write-Log "Nothing to report" -Path $Logfile -Level Warn
}


