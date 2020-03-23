<########
.DESCRIPTION
Script that copies H Drives using Robocopy.
.INPUTS
  N\A
.OUTPUTS
  
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  0
  Purpose/Change: Initial script  
#>



#Source and destination variables 
$short_date = Get-Date -uformat "%d%m%Y"
$SourceDir = "\\ServerPath\Home$"
$DestDir = "\\ServerPath\Data$\" 
#HDrives = Get-Content -Path ".\AllUsers.txt"
$RobocopyLog = "\path\$short_date"
$User = "TestUser"
$cmdArgs     = "$SourceDir $DestDir $RobocopySwitches $RobocopyLogFile"
$RobocopySwitches = "/COPYALL /e /NP /R:0 /W:0"
$RobocopyLogFile = "/LOG:$RobocopyLog-$User.log" 

$LogData =@()
$HDriveCopy = New-Object psobject -Property @{
FolderSize_Before =""
FolderSize_After =""
}
function GetFolderSize ([string]$Check) {
    If (Test-Path $SourceDir){
        $params = New-Object System.Collections.Arraylist
        $params.AddRange(@("/L","/S","/NJH","/BYTES","/FP","/NC","/NDL","/TS","/XJ","/R:0","/W:0"))
        $countPattern = "^\s{3}Files\s:\s+(?<Count>\d+).*"
        $sizePattern = "^\s{3}Bytes\s:\s+(?<Size>\d+(?:\.?\d+)).*"
        $return = robocopy $SourceDir NULL $params
        If ($return[-5] -match $countPattern) {
            $Count = $matches.Count
        }
        If ($Count -gt 0) {
            If ($return[-4] -match $sizePattern) {
                $Size = $matches.Size
            }
        } Else {
            $Size = 0
        }
        $Size = ([math]::Round($Size,2))
        $SizeMB = "{0:N2}" -f ($size /1MB)
        $SizeGB = "{0:N2}" -f ($size /1GB)
            If ($Check -eq "BeforeCopy") {
            Write-Host  "$Check folder $SourceDir is $SizeMB MB in size" 
            $HDriveCopy.FolderSize_Before = "$Check folder $SourceDir is $SizeMB MB in size"
            }
            ELSE {
            Write-Host  "$Check folder $SourceDir is $SizeMB MB in size"  
            $HDriveCopy.FolderSize_After = "$Check folder $SourceDir is $SizeMB MB in size" 
            }
    $Size=$Null
    }
    ELSE {
    $Error = "Not_Found"
    Write-Host "$SourceDir Doesn't exist!"
    } 
}
<#Test
$SourceDir = "C:\Temp"
$Check = "AfterCopy"
GetFolderSize -Check $Check
$LogData += $HDriveCopy

$LogData | Select-Object FolderSize_Before,FolderPath,FolderSize_After | Export-CSV -Path C:\Temp\Results.csv -NoType
#>

#Main Script
ForEach ($User in $HDrives) {
$HDriveCopy.FolderPath = $User
$Check = "BeforeCopy"
GetFolderSize -Check $Check
Write-Host "Checking $User folder size"

Write-Host "Robocopying $User folder"
Robocopy.exe $cmdArgs	
$cmdArgs
}

$LogData += $HDriveCopy

$LogData | Select-Object FolderSize_Before | Export-CSV -Path C:\Temp\Results.csv -NoType
