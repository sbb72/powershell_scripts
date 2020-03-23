<########
.DESCRIPTION
Remove vmdk files that have been idenfied as orphaned (this script doesn't identify them).
The script will Delete the vmdk after it was renamed in anothetr script
.INPUTS
  CSV file thats has the file name and full path to the datastore to remove the vmdk.
  Specified in $vmdks
.OUTPUTS
  Log file stored $Output variable, change the location in the variable if required.
  The script writes to the output after each line due to the time it took to finish the script.
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  09-03-2018
  Purpose/Change: Initial script  
Version 1.0
Purpose/Change: Initial script  
#>

$short_date = Get-Date -uformat "%Y%m%d"
$Output = "C:\Temp\Sbarker\vmdk\Deletevmdks_$short_date.txt"
$vmdks = Import-Csv -Path "C:\Temp\Sbarker\vmdk\DeleteDataTest.csv"
#Add the snap-in
Add-PSSnapin VMware.VimAutomation.Core -erroraction SilentlyContinue

Connect-VIServer BASXTSPRDVCW01
$StartedScript = (Get-Date)
"Full Path;File Exists;Deleted File;File Name" | Out-File $Output -Append
ForEach ($vmdk in $vmdks) {
CD vmstore:
    If (Test-Path $($vmdk.FullPath+"OLD")) {
        Write-Host "Deleting $($vmdk.File+"OLD")"
        #$delvmdk = $vmdk.FullPath+"OLD"
        Remove-Item $($vmdk.FullPath+"OLD") -erroraction SilentlyContinue -ErrorVariable ErrorDelete
          If ($ErrorDelete) {
          $($vmdk.FullPath+"OLD")+";"+"Yes"+";"+"Error"+";"+$vmdk.File+"OLD" | Out-File $Output -Append
          Write-host "Some Error Deleting "}
          ELSE {
          Write-host "Delete OK"
          $($vmdk.FullPath+"OLD")+";"+"Yes"+";"+"OK"+";"+$vmdk.File+"OLD" | Out-File $Output -Append}
    }
    ELSE {
    Write-host "$($vmdk.File) Doesn't exist!"
    $($vmdk.FullPath+"OLD")+"OLD"+";"+"No"+";"+"No"+";"+$vmdk.File+"OLD" | Out-File $Output -Append}
}

$EndScript = (Get-Date)
$TimeToRun = New-Timespan -start $StartedScript -End $EndScript
"##################################################" | Out-File $Output -Append
"Script took "+$TimeToRun.Minutes+ " Minutes and "+$TimeToRun.Hours+" hours to run" | Out-File $Output -Append
"##################################################" | Out-File $Output -Append