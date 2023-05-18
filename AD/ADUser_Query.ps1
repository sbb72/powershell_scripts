#-Server 'dc'
$GrabPeteUser = Get-ADuser -Filter * -Properties Name,extensionAttribute7, Department, Description, SAMAccountName,manager | Where {$_.Name -Like "z*"} | Select-Object Name,extensionAttribute7, Department, Description, SAMAccountName,manager

$Results = New-Object -TypeName System.Collections.ArrayList
ForEach ($Item in $GrabPeteUser) {
    
    If (([String]$Item.Name -like "*Mabbott*") -or ([String]$Item.extensionAttribute7 -like "*Mabbott*") -or ($($Item.Department) -like "*Mabbott*") -or ($($Item.Description) -like "*Mabbott*") -or ($($Item.SAMAccountName) -like "*Mabbott*") -or ($($Item.manager) -like "*Mabbott*")) {
     
        Write-Host "User $($Item.Name) Has petes name in it"
        $Result = New-Object -TypeName psobject
            Add-Member -InputObject $Result -MemberType NoteProperty -Name "Username" -Value $Item.Name
            Add-Member -InputObject $Result -MemberType NoteProperty -Name "extensionAttribute7" -Value $Item.extensionAttribute7
            Add-Member -InputObject $Result -MemberType NoteProperty -Name "Department" -Value $Item.Department
            Add-Member -InputObject $Result -MemberType NoteProperty -Name "Description" -Value $Item.Description
            Add-Member -InputObject $Result -MemberType NoteProperty -Name "SAMAccountName" -Value $Item.SAMAccountName
            Add-Member -InputObject $Result -MemberType NoteProperty -Name "manager" -Value $Item.manager
            $Results.Add($Result) | Out-Null
    }
    Else {
    
        #Write-Host "$($Item.Name) is OK"

    }
  
    #$Results += $Result
    #$Result = ""
    #$Item = ""
}

If ($Results) {
    
    Write-Host "$(($Results| Measure-Object).Count) entries, attempting to export to csv"
    Try {

        $Results | Select-Object -Property "Username","extensionAttribute7","Department", "Description","SAMAccountName","manager"| Export-Csv -Path "D:\UserFolders\sbarker23\temp\whtQueryPete_$(Get-date -Format 'dd_MM_yyy').csv" -NoTypeInformation -ErrorAction Stop
    
    }
    Catch {
    
        Write-Host "Something went wrong exporting data, error : $($_.Exception.Message)"

    }

}
Else {

    Write-Host "No Entries found"
}


