function Get-Services
{
    
    $servicesCollection = Get-WmiObject win32_service | Select-Object Caption, Name, State, StartMode
    
    $ArrayOfServices = @()

    ForEach ($individualService in $servicesCollection)
    {
        $ServiceItem = New-Object -TypeName PSObject -Property @{
        
            Caption = $individualService.Caption
            Name = $individualService.Name
            State = $individualService.State
            StartMode = $individualService.StartMode
        }
        $ArrayOfServices += $ServiceItem
    
    }
    return $ArrayOfServices | Select-Object Caption, Name, State, StartMode | Sort-Object Caption
} 