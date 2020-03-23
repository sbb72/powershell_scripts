<########
.DESCRIPTION
This script checks the size of users H Drives using data from AD and the home directory attribute in the User object.
Uses robocopy to get the size due to the 256 character path issue, requires Robocopy.
.INPUTS
  N\A
.OUTPUTS
  Log file stored $HDriveLog variable, change the location in the variable if required.
  The script writes to the output after each H Drive check due to the time it took to finish the script with a large user base.
  The script writes how long in hours the script took to run.
.NOTES
  Version:        1.1
  Author:         SBarker
  Creation Date:  15-02-2018
  Purpose/Change: Initial script  
Version 1.0
Purpose/Change: Initial script  
Version 1.1
Purpose/Change: Removed Array capturing the data it now writes data to a log file after each H drive check. This was changed due the time it took to check 30K home drives.
#>

$short_date = Get-Date -uformat "%Y%m%d"
$HDriveLog = "path\UsersHDrives_$short_date.txt"
"UserName;Home Directory;Size MB;Size GB;Error" | Out-File $HDriveLog -Append

$UserData = Get-Aduser -Filter {(HomeDirectory -Like "*")} -Properties SamAccountName ,HomeDirectory, Enabled,PasswordLastSet, DistinguishedName | Sort-Object
$StartedScript = (Get-Date)

ForEach ($item in $UserData) {
Write-Host "Checking" $item.SamAccountName 
    If (Test-Path $Item.HomeDirectory){
        $params = New-Object System.Collections.Arraylist
        $params.AddRange(@("/L","/S","/NJH","/BYTES","/FP","/NC","/NDL","/TS","/XJ","/R:0","/W:0"))
        $countPattern = "^\s{3}Files\s:\s+(?<Count>\d+).*"
        $sizePattern = "^\s{3}Bytes\s:\s+(?<Size>\d+(?:\.?\d+)).*"
        $return = robocopy $Item.HomeDirectory NULL $params
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

        Write-Host  $item.SamAccountName "HDrive Size" $SizeMB 
    $Size=$Null
    }
    ELSE {
    Write-Host $Item.SamAccountName "HDrive Deleted?"
    } 
$item.SamAccountName+";"+$item.HomeDirectory+";"+$SizeMB+";"+$SizeGB | Out-File $HDriveLog -Append
}

$EndScript = (Get-Date)
$TimeToRun = New-Timespan -start $StartedScript -End $EndScript

"############################################################################" | Out-File $HDriveLog -Append
"## Script took "+$TimeToRun.days+" Days,"+$TimeToRun.Hours+" Hours to run ##" | Out-File $HDriveLog -Append
"############################################################################" | Out-File $HDriveLog -Append