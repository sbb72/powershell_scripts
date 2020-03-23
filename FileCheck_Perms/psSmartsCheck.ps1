$strFile = ".log"
$Servers = Get-Content C:\Temp\Servers.txt
$LogData = @()

ForEach ($Server in $Servers){
$LogStat = "" | Select-Object ServerName,Worked,SStart,SEnd
$LogStat.ServerName = $Server

$strServer = "\\"+$Server+"\"
$strPath=$strServer+$strFile
$Server
$strPath

$strTestPath = Test-Path $strPath
    If ($strTestPath) {
    $strWorked ="OK" 
    $LogStat.Worked = $strWorked
    $strWorked

    $strFirstFull = Get-Content $strPath -First 1
    $strFirst = $strFirstFull.substring(0,19)
    $LogStat.SStart = $strFirst

    $strLastFull = Get-Content $strPath -Last 1
    $strLast = $strLastFull.substring(0,19)
    $LogStat.SEnd = $strLast

    }
    ELSE{
    $strWorked = "ERROR"
    $LogStat.Worked = $strWorked
    $strWorked
    }
$LogData += $LogStat
}
$LogData | Select-Object ServerName,Worked,SStart,SEnd | Export-CSV -Path C:\Temp\Results.csv -NoType