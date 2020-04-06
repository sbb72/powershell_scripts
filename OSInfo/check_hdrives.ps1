$Computers = ""
$short_date = Get-Date -uformat "%d%m%Y"
$output = ".\drives_Weekly.csv"
$LogData = @()
foreach ($Server in $Computers) {
    Write-Host "Checking $Server"
    $disks = Get-WmiObject win32_logicaldisk -ComputerName $Server | Where-Object { $_.DriveType -eq "3" }
    foreach ($Item in $Disks) {
        $drivesout = New-Object PSObject -Property @{
            Server       = ""
            Date         = $short_date
            Drive        = ""
            Size_GB      = ""
            Freespace_GB = ""
            Percent_Free = ""
        }
        $drivesout.Server = $Server
        $drivesout.drive = $Item.deviceID
        $size = [System.Math]::Round($Item.Size / 1GB)
        $drivesout.Size_GB = [System.Math]::Round($Item.Size / 1GB)
        $freespace = [System.Math]::Round($Item.FreeSpace / 1GB)
        $drivesout.Freespace_GB = [System.Math]::Round($Item.FreeSpace / 1GB)
        $PreFree = [Math]::Round(($freespace / 1MB) / ($Size / 1MB) * 100)
        $drivesout.Percent_Free = [Math]::Round(($freespace / 1MB) / ($Size / 1MB) * 100)
    
        $LogData += $drivesout
    }
}
$LogData | Select Server, Date, Drive, Size_GB, Freespace_GB, Percent_Free | Export-Csv -Append $output -NoTypeInformation
