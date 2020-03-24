function Get-Disks {
    $disksCollection = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" }
    $ArrayOfDiskInfo = @{ }
    ForEach ($individualDisk in $disksCollection) {
        $diskInfo = New-Object -TypeName PSObject -Property @{

            Size          = [math]::Round((($individualDisk.Size) / 1GB))
            DeviceID      = $individualDisk.DeviceID
            VolumeName    = $individualDisk.VolumeName
            "% FreeSpace" = [Math]::Round(($individualDisk.FreeSpace / 1MB) / ($individualDisk.Size / 1MB) * 100)
        }
    
        $ArrayOfDiskInfo += @{$diskInfo.DeviceID = $diskInfo }
    }      
    return $ArrayOfDiskInfo
}   

Get-Disks 
