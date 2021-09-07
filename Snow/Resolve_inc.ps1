#Extract Report from snow to get all INC number to resolve
#Cache SNOW Creds alsoing Write-SavedCredential

Import-Module "D:\Data\git-repo-work\iSolve-Powershell-Module\DXC-iSolve"

$Incidents = Get-Content D:\Data\temp\tickets.txt
Foreach ($inc in $Incidents) {

sleep 2

Update-SnowIncident -Url cscqa.service-now.com -Number $inc -Resolve -CloseCode 'Cancelled' -CloseNotes 'resolved' -Verbose

}​​​​​