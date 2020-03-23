<########
.DESCRIPTION
Remove a vmdk files that have been idenfied as orphaned (this script doesn't identify them).
1.The script will check the file exists, export the size, namd and last write time.
2. The script will rename the vmdk
.INPUTS
A text file that contains full path to the file you want to query, example below:  
"vCenterDatacenter/Datacentername/FolderName/vmdkname.vmdk"
This data comes from the RVTools report
.OUTPUTS
  Log file stored $Output variable, change the location in the variable if required.
  The script writes to the output after each line due to the time it took to finish the script 
.NOTES
  Version:        1.1
  Author:         SBarker
  Creation Date:  09-03-2018
  Purpose/Change: Initial script  
Version 1.0
Purpose/Change: Initial script  
Version 1.1
Added substing to remove VimDatastore for rename script ($vmdkdata.PSParentPath.Substring(67).
#>

$short_date = Get-Date -uformat "%Y%m%d"
$OutputRN = "C:\Temp\Sbarker\vmdk\Rename_$short_date.csv"
$vmdks = Get-Content "C:\Temp\Sbarker\vmdk\DS.txt"
$allvmdk = @()
#Add the snap-in
Add-PSSnapin VMware.VimAutomation.Core -erroraction SilentlyContinue

Connect-VIServer BASXTSPRDVCW01

CD vmstore:

ForEach ($vmdk in $vmdks) {
$vmdkobject = New-Object –TypeName PSObject
    If (Test-Path $vmdk) {
        Write-Host "Checking $vmdkdata.Name"
        $vmdkdata = Get-Item $vmdk | Select-Object Name, Length, lastwritetime, PSParentPath
        $vmdkobject | Add-Member –MemberType NoteProperty –Name "File Path" –Value $vmdk
        $vmdkobject | Add-Member –MemberType NoteProperty –Name "VMDK Name" –Value $vmdkdata.Name
        $vmdkobject | Add-Member –MemberType NoteProperty –Name "Exists" –Value "Yes"
        $vmdkobject | Add-Member –MemberType NoteProperty –Name "Size" –Value $vmdkdata.Length
        $vmdkobject | Add-Member –MemberType NoteProperty –Name "FullFolderPath" –Value $vmdkdata.PSParentPath
        $vmdkobject | Add-Member –MemberType NoteProperty –Name "FolderPath" –Value $vmdkdata.PSParentPath.Substring(67)
        $vmdkobject | Add-Member –MemberType NoteProperty –Name "LastWriteTime" –Value $vmdkdata.LastWriteTime.ToString("dd/MM/yyyy")
        }
        ELSE {
        Write-host "$vmdkdata.Name Doesn't exist!"
        $vmdkobject | Add-Member –MemberType NoteProperty –Name "File Path" –Value $vmdk
        $vmdkobject | Add-Member –MemberType NoteProperty –Name "Exists" –Value "No"
        }
    $allvmdk += $vmdkobject
}
	
$allvmdk | Export-Csv $OutputRN -NoTypeInformation