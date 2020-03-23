<#
.DESCRIPTION
Export directories with path and owner.  This was used to for Profiles share and gets a string from the folder name used for permissions.
.INPUTS
  Change share path file location
.OUTPUTS
 N\A
.NOTES
  Version:        1.1
  Author:         SBarker
  Creation Date:  03-03-17
  Change Date:    15/01/2017
  Purpose/Change: Initial script  
.EXAMPLE
  Changed Array.
  Added Size in MB column.
#>

#Get date for log file
$short_date = Get-Date -uformat "%Y%m%d"

#Path to share \ Directory
$DFSList = Get-Content "C:\Temp\Shares.txt"
#$items = Get-Childitem -path D:\Temp -Recurse -File

$FileArray = @()
ForEach ($DFS in $DFSList) {
$items = Get-Childitem -path $DFS -Recurse -File
    Foreach ($item in $Items) {
        $FileDataObject = New-Object PSObject
        Write-Host "Checking $item"
        $FileDataObject | Add-Member -Membertype NoteProperty -Name "File Name" -Value $Item
        $FileDataObject | Add-Member -Membertype NoteProperty -Name "FullPath" -Value $Item.FullName
        $FileDataObject | Add-Member -Membertype NoteProperty -Name "Directory" -Value $Item.Directory
	      $FileDataObject | Add-Member -Membertype NoteProperty -Name "Last Write Time" -Value $Item.LastWriteTime
        $FileDataObject | Add-Member -Membertype NoteProperty -Name "Size" -Value $item.Length
        $LengthMB = [Math]::Round($item.Length / 1MB)
        $FileDataObject | Add-Member -Membertype NoteProperty -Name "Size (MB)" -Value $LengthMB
        $FileDataObject | Add-Member -Membertype NoteProperty -Name "File Exentsion" -Value $item.Extension
	
        $FileArray +=  $FileDataObject
    }
}
#Rename path & file name if required
$FileArray | Export-CSV -Path C:\Temp\$short_date-TESTExportDirv1.csv -NoType	
