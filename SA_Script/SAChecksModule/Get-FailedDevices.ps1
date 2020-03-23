Function Get-FailedDevices
{
    
    $devicesCollection = Get-WmiObject Win32_PNPEntity | Where-Object {$_.status -notlike 'OK' -and $_.status -notlike $null } | Select-Object Name, Status, ConfigManagerErrorCode
    
    $ArrayOfDevices = @()

    ForEach ($individualEvtEntry in $devicesCollection)
    {
        $DeviceItem = New-Object -TypeName PSObject -Property @{
        
            Name = $individualEvtEntry.Name
            Status = $individualEvtEntry.Status
            ConfigManagerErrorCode = $individualEvtEntry.ConfigManagerErrorCode
 
        }
        #write-host $evtEntryInfo
        $ArrayOfDevices += $DeviceItem
    
    }
    return $ArrayOfDevices
}  