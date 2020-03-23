function Get-Disks {
    $ArrayOfDiskInfo = @()
    $disks = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq "3"}

    $disks | Foreach {
        $diskInfo = New-Object -TypeName PSObject -Property @{
            Drive = $_.DeviceID
            "Volume Name" = $_.VolumeName
            "Size GB"= [math]::Round((($_.Size) /1GB))
            "Free Space GB" = [System.Math]::Round($_.FreeSpace/1GB)
            "Precent Free" = [Math]::Round(($_.freespace /1MB) / ($_.Size / 1MB) * 100)
        }
    
    $ArrayOfDiskInfo += $diskInfo
    } 
Return $ArrayOfDiskInfo    
}   