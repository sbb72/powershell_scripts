$DFSData = Get-DfsnRoot -domain "domain.local"
#$DFSData = "\\path\dfsroot"
#$DFSData1= $DFSData.Path


Foreach ($Item in $DFSData) {

    $LogDFS = "" | Select Path, TargetPath
    Get-DfsnRootTarget -Path $Item.Path | Select Path, TargetPath | Export-Csv -Append -Path , \DFSRoots.csv -NoTypeInformation

    #$LogDFS.Path = $DFSStuff.Path
    #$LogDFS.TargetPath = $DFSStuff.TargetPath

    #$LogDFS += $DFSLog
}

#$DFSLog | Select Path, TargetPath | Export-CSV -Path .\DFSRoots.csv -NoTypeInformation

