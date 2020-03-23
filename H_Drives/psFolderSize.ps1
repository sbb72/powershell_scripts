<########
.DESCRIPTION
Script the checks the size of directories from a INPUT file.
Uses robocopy to get the size due to the 260 character path issue.
.INPUTS
 List of directories to check.
 $DirToCheck variable
.OUTPUTS
  Log file stored $Output variable, change the location in the variable if required.
  The script writes to the output after each line due to the time it took to finish the script 
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  02-01-2019
  Purpose/Change: Initial script  
Version 1.0
Purpose/Change: Initial script  
#>
$StartedScript = (Get-Date)
$LogData = @()
$short_date = Get-Date -uformat "%Y%m%d"
$Output = "C:\SUPPORT\Olympia_Report\Olympia_"+$env:computername+"_"+$short_date+".csv"
$Inputdir = "C:\SUPPORT\Olympia_Report\"+$env:computername+"_Dirs.csv"
If (Test-Path $Inputdir) {
$DirToCheck = Import-Csv -Path $Inputdir
}
ELSE {
$DirToCheck = Get-WmiObject -class win32_share | where {$_.Description -notlike "Default Share" -and $_.Description -notlike "Remote Admin" -and $_.Description -notlike "Remote IPC" -and $_.Description -notlike "Script_Ignore"}
}

ForEach ($item in $DirToCheck) {
$DirLog = New-Object psobject -Property @{
ShareName =""
Directory =""
Size_MB=""
Size_GB=""
Error =""
TimeTaken =""
}

Write-Host "Checking" $item.path
    If (Test-Path $item.path){
        $DirLog.Directory = $item.path
        $params = New-Object System.Collections.Arraylist
        $params.AddRange(@("/L","/S","/NJH","/BYTES","/FP","/NC","/NDL","/TS","/XJ","/R:0","/W:0","/MT:16"))
        $countPattern = "^\s{3}Files\s:\s+(?<Count>\d+).*"
        $sizePattern = "^\s{3}Bytes\s:\s+(?<Size>\d+(?:\.?\d+)).*"
        $return = robocopy $item.path NULL $params
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
        $DirLog.Size_MB = "{0:N2}" -f ($size /1MB)
        $SizeGB = "{0:N2}" -f ($size /1GB)
        $DirLog.Size_GB = "{0:N2}" -f ($size /1GB)
   
    $Size=$Null
    }
    ELSE {
    $Error = "Not_Found"
    } 
$Error.clear()
$LogData += $DirLog
}

$EndScript = (Get-Date)
$TimeToRun = New-Timespan -start $StartedScript -End $EndScript
$DirLog.TimeTaken = "Script took $($TimeToRun.Hours) hours and $($TimeToRun.Minutes) mins to run"

$LogData | Select Directory,Size_MB,Size_GB,Error, TimeTaken | Export-Csv $Output -NoTypeInformation