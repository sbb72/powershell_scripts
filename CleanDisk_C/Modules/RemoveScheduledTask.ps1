function Remove-ScheduledTask {
    [CmdletBinding()]
    param (
        $ComputerName
    )
    

    schtasks /s $ComputerName /delete /TN 'at1' /F

    # $tasks = (schtasks /s $ComputerName /query /fo csv).ForEach({$_.Split(',')[0].trimstart('\"').trimend('"')}).where({$_ -like 'at1*'})
    # if($tasks.count -ne 0)
    # {
    #     $Tasks.ForEach({schtasks /s $ComputerName /delete /TN $_  /F})
    # }

}


