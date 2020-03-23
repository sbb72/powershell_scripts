
$dfsfolder = Get-DfsnFolder "\\DFSPath\Folder\*"

$dfstree = $dfsfolder.Path

$LogData = @()

Foreach ($folder in $dfstree) {
$LogStat = "" | Select Path,TargetPath
write-host "Checking $folder"

$folder = Get-DfsnFolderTarget $Folder | Select Path, TargetPath

$LogStat.Path = $folder.path
$LogStat.TargetPath = $folder.TargetPath

$LogData += $LogStat

}
$LogData | Select Path, TargetPath | Export-CSV F:\Temp\DFSLinks.csv -NoType
