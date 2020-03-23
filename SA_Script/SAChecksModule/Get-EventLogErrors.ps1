Function Get-EventLogErrors {

    $evtEntryCollection = Get-WinEvent @{logname='application','system';StartTime=(get-date)-(new-timespan -day 1);level=2} | Select-Object logname,timecreated,id,message
    
    $ArrayOfEvtEntries = @()

    ForEach ($individualEvtEntry in $evtEntryCollection) {
        $evtEntryInfo = New-Object -TypeName PSObject -Property @{
        
            TimeCreated = $individualEvtEntry.TimeCreated
            Message = $individualEvtEntry.Message
            ID = $individualEvtEntry.ID
            LogName = $individualEvtEntry.LogName
        
        }
        $ArrayOfEvtEntries += $evtEntryInfo
    }
    return $ArrayOfEvtEntries | Sort-Object -Property TimeCreated -Descending
} 

