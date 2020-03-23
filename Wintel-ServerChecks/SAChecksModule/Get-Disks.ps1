function Get-Disks
{
    $disksCollection = Get-WmiObject Win32_LogicalDisk
  
    $ArrayOfDiskInfo = @{}

    ForEach ($individualDisk in $disksCollection)

    {
        $diskInfo = New-Object -TypeName PSObject -Property @{

            Size = [math]::Round((($individualDisk.Size) /1GB))
            DriveType = if($individualDisk.DriveType -eq 3){"Local"}else{"Network"}
            DeviceID = $individualDisk.DeviceID
            VolumeName = $individualDisk.VolumeName
        }
    
        $ArrayOfDiskInfo += @{$diskInfo.DeviceID = $diskInfo}

    }      
    return $ArrayOfDiskInfo
}   

Get-Disks
