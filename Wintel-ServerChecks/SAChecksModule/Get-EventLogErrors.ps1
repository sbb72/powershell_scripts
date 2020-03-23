Function Get-EventLogErrors
{
    
    $evtEntryCollection = Get-WinEvent @{logname='application','system';StartTime=(get-date)-(new-timespan -day 1);level=2} | Select-Object logname,timecreated,id,message
    #$evtEntryCollection = Get-WinEvent @{logname='application','system';StartTime=[datetime]::Today;level=2} | select logname,timecreated,id,message
    #$evtEntryCollection = Get-WMIobject Win32_NTLogEvent -filter "(logfile='system') OR (logfile='applcation') AND (type='error')" | Select-Object Logfile, Message, EventType, TimeGenerated -first 100
    
    $ArrayOfEvtEntries = @()

    ForEach ($individualEvtEntry in $evtEntryCollection)
    {
        $evtEntryInfo = New-Object -TypeName PSObject -Property @{
        
            TimeCreated = $individualEvtEntry.TimeCreated
            Message = $individualEvtEntry.Message
            ID = $individualEvtEntry.ID
            LogName = $individualEvtEntry.LogName
        
        }
        #write-host $evtEntryInfo
        $ArrayOfEvtEntries += $evtEntryInfo
    
    }
    return $ArrayOfEvtEntries | Sort-Object -Property TimeCreated -Descending
}  

