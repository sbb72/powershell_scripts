<#
.DESCRIPTION
Take ownership of a folder and reset permimission so the user has access
.INPUTS
  Change $Servers variable to the input file location
.OUTPUTS
 N\A
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  03-03-17
  Purpose/Change: Initial script  
.EXAMPLE
  N|A
#>

#Import location, this has user and folder name.
$csv = Import-CSV -Path "D:\Sbarker\ExportPro3.csv"

$argO1 = "takeown.exe /F D:\TSProf\"
$argO2 = " /R /A /D Y"

$argP1 = "cmd /c icacls.exe D:\TSProf\"
$argP2 = " /grant greenlnk\"
$argP3 = "':(OI)(CI)F'"

Foreach ($item in $csv){
##Takeownership of the directories
$test1 = $argO1 + $Item.Dir + $argO2
Write-Host $test1
Invoke-Expression $test1

###Set the permissions for the user
$runPerms = $argP1 + $item.Dir + $argP2 + $item.User + $argP3
Write-host $runPerms
Invoke-Expression $runPerms
}

