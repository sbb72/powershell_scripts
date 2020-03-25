Function Get-InstalledUpdates {
    $updatesCollection = Get-HotFix | Select-Object HotFixID, InstalledOn, InstalledBy, Description
    $arrayOfUpdates = @()

    ForEach ($individualUpdate in $updatesCollection) {
        $UpdateItem = New-Object -TypeName PSObject -Property @{
        
            HotFixID    = $individualUpdate.HotFixID
            InstalledOn = $individualUpdate.InstalledOn
            InstalledBy = $individualUpdate.InstalledBy
            Description = $individualUpdate.Description
        }
        #write-host $evtEntryInfo
        $arrayOfUpdates += $UpdateItem
    }
    return $arrayOfUpdates | sort-order -Property HotFixID -Descending
}