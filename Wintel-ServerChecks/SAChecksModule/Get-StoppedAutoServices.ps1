function Get-StoppedAutoServices
{
    
    $servicesCollection = Get-WmiObject win32_service -Filter "startmode = 'auto' AND state != 'running' " | Select-Object Caption, Name, State, StartMode
    
    $ArrayOfServices = @()

    ForEach ($individualService in $servicesCollection)
    {
        $ServiceItem = New-Object -TypeName PSObject -Property @{
        
            Caption = $individualService.Caption
            Name = $individualService.Name
            State = $individualService.State
            StartMode = $individualService.StartMode
        }
        #write-host $evtEntryInfo
        $ArrayOfServices += $ServiceItem
    
    }
    return $ArrayOfServices
} 