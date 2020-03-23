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

$short_date = Get-Date -uformat "%Y%m%d"
$Output = "C:\Temp\DIRsize_$short_date.txt"
"Directory;Size MB;Size GB;Error" | Out-File $Output -Append
$DirToCheck = Get-Content -Path "C:\Temp\DirList.txt"
$StartedScript = (Get-Date)

ForEach ($item in $DirToCheck) {
Write-Host "Checking" $item
    If (Test-Path $Item){
        $params = New-Object System.Collections.Arraylist
        $params.AddRange(@("/L","/S","/NJH","/BYTES","/FP","/NC","/NDL","/TS","/XJ","/R:0","/W:0"))
        $countPattern = "^\s{3}Files\s:\s+(?<Count>\d+).*"
        $sizePattern = "^\s{3}Bytes\s:\s+(?<Size>\d+(?:\.?\d+)).*"
        $return = robocopy $Item NULL $params
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
        Write-Host  $item "Directory Size" $SizeMB 

    $Size=$Null
    }
    ELSE {
    $Error = "Not_Found"
    Write-Host $Item "Folder Deleted?"
    } 
$item+";"+$SizeMB+";"+$SizeGB+";"+$Error | Out-File $Output -Append
$Error.clear()
}

$EndScript = (Get-Date)
$TimeToRun = New-Timespan -start $StartedScript -End $EndScript
"Script took $($TimeToRun.Minutes) mins to run" | Out-File $Output -Append