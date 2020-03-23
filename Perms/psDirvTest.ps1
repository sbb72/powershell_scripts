<#
.DESCRIPTION
Export directories with path and owner.  This was used to for Profiles share and gets a string from the folder name used for permissions.
.INPUTS
  Change share path file location
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

#Get date for log file
$short_date = Get-Date -uformat "%Y%m%d"

#Path to share \ Directory
$items = Get-Childitem -path D:\TsProf

$ProExport = @()
Foreach ($item in $items) {
$ProData = "" | Select Dir,User,Owner,Perms

	If ($item.attributes -eq "Directory"){
	$ProData.Dir = $item.name
	Write-Host $item.name
	$Users = $item.name
	$User = $Users.replace(".GREENLNK.V2","")
	$ProData.User = $User
	$ProData.Owner = (Get-Acl D:\TSProf\$item).Owner
		If ($ProData.Owner -eq "BUILTIN\Administrators"){
		Write-host "Perms OK"
		$ProData.Perms = "YES"
		}
		ELSE
		{Write-host "No Perms"
		$ProData.Perms = "NO"
		}
	}
$ProExport += $ProData
}
#Rename path & file name if required
$ProExport | Select Dir,User,Owner,Perms | Export-CSV -Path D:\Sbarker\$short_date-ExportData.csv -NoType	