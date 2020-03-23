<########
.DESCRIPTION
Remove a vmdk files that have been idenfied as orphaned (this script doesn't identify them).
1.The script will check the file exists, export the size, namd and last write time.
2. The script will rename the vmdk
.INPUTS
  N\A
.OUTPUTS
  Log file stored $Output variable, change the location in the variable if required.
  The script writes to the output after each line due to the time it took to finish the script 
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  09-03-2018
  Purpose/Change: Initial script  
Version 1.0
Purpose/Change: Initial script  
#>

$short_date = Get-Date -uformat "%Y%m%d"
$OutputRN = "C:\Temp\Sbarker\vmdk\Rename_$short_date.csv"
$vmdks = Import-Csv -Path "C:\Temp\Sbarker\vmdk\RenameDataTest.csv"
$allvmdk = @()
#Add the snap-in
Add-PSSnapin VMware.VimAutomation.Core -erroraction SilentlyContinue

Connect-VIServer BASXTSPRDVCW01

ForEach ($vmdk in $vmdks) {
$vmdkobject = New-Object –TypeName PSObject
CD vmstore:
    If (Test-Path $($vmdk.FullPath)) {
        $vmdkobject | Add-Member –MemberType NoteProperty –Name "File" –Value $($vmdk.FullPath)
        $vmdkobject | Add-Member –MemberType NoteProperty –Name "Exists" –Value "Yes"
        Write-Host "Renaming $($vmdk.File)"
        $vmdknewname = $vmdk.File+"OLD"
        CD vmstore: 
        CD $($vmdk.FolderPath)
        Rename-Item $($vmdk.File) $vmdknewname -erroraction SilentlyContinue -ErrorVariable ErrorRename
          If ($ErrorRename) {
          $vmdkobject | Add-Member –MemberType NoteProperty –Name "Rename" –Value "Rename Error"
          Write-host "Error"}
          ELSE {
          Write-host "Rename OK"
          $vmdkobject | Add-Member –MemberType NoteProperty –Name "Rename" –Value "OK"}
    }
    ELSE {
    Write-host "$($vmdk.File) Doesn't exist!"
    $vmdkobject | Add-Member –MemberType NoteProperty –Name "File" –Value $($vmdk.FullPath)
    $vmdkobject | Add-Member –MemberType NoteProperty –Name "Exists" –Value "No"
    }
    $allvmdk += $vmdkobject
}
	
$allvmdk | Export-Csv $OutputRN -NoTypeInformation