<#
.DESCRIPTION
Export directories with path and owner.  This was used to for Profiles share and gets a strnig from the folder name used for permissions.
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

#Path to share \ Directory
$items = Get-Childitem -path D:\TsProf

$ProExport = @()
Foreach ($item in $items) {
$ProData = "" | Select Dir,User,Owner

	If ($item.attributes -eq "Directory"){
	$ProData.Dir = $item.name
	Write-Host $item.name
	$Users = $item.name
	$User = $Users.replace(".GREENLNK.V2","")
	$ProData.User = $User
	$ProData.Owner = (Get-Acl D:\TSProf\$item).Owner
	}
$ProExport += $ProData
}
#Rename path & file name if required
$ProExport | Select Dir,User,Owner | Export-CSV -Path D:\Sbarker\ExportPro4.csv -NoType	