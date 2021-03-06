<#
.DESCRIPTION
Take ownership of a folder and reset permimission so the user has access
.INPUTS
  Change the import location of the csv file
.OUTPUTS
 N\A
.NOTES
  Version:        1.1
  Author:         SBarker
  Creation Date:  03-03-17
  Purpose/Change: Initial script  
	Added /t on the icacls command
.EXAMPLE
  N|A
#>

#Import location, this has user and folder name.
$csv = Import-CSV -Path "D:\Sbarker\ExportPro6.csv"

$argO1 = "takeown.exe /F D:\TSProf\"
$argO2 = " /R /A /D Y"

$argP1 = "cmd /c icacls.exe D:\TSProf\"
$argP2 = " /grant greenlnk\"
$argP3 = "':(OI)(CI)F' /t"

Foreach ($item in $csv){
##Takeownership of the directories
$takeo = $argO1 + $Item.Dir + $argO2
Write-Host $takeo
Invoke-Expression $takeo

###Set the permissions for the user
$runPerms = $argP1 + $item.Dir + $argP2 + $item.User + $argP3
Write-host $runPerms
Invoke-Expression $runPerms
}

