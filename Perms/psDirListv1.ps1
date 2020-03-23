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
$items = Get-Childitem -path D:\Temp -Recurse -File

$ProExport = @()
Foreach ($item in $items) {
$ProData = "" | Select FullName, Extension,Directory, LastWriteTime,Length,LengthMB,LengthID

	$ProData.Fullname = $item.FullName
	Write-Host $item.FullName
    $ProData.Directory = $item.Directory
    $ProData.LastWriteTime = $item.LastWriteTime
    $ProData.Length = $item.Length
    $ProData.LengthMB = [Math]::Round($item.Length / 1MB)
    $ProData.Extension = $item.Extension
    If ($item.Length -eq "0"){
     $ProData.LengthID = "NoData"
     }
	
$ProExport += $ProData
}
#Rename path & file name if required
$ProExport | Select FullName, Extension,Directory, LastWriteTime,Length,LengthMB,LengthID | Export-CSV -Path C:\Temp\$short_date-ExportDirv1.csv -NoType	
