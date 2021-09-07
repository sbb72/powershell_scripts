Import-Module D:\Scripts\UsefulFunctionsv1.psm1
$ReportIPRemoved = "IPRemoved"

#Send Skype User Checks 
$SkypeUsers = Get-LatestfileToSend -PathtoCheck "D:\HealthChecks\Reports" -PartofFileName "skype-users_results"
$CheckIPRemoved = Get-ChildItem -Path $SkypeUsers | Where-Object {$_.name -match $ReportIPRemoved}

If (!$CheckIPRemoved) {
Get-RemoveIPsfromFile -PathtoFile $SkypeUsers
$CheckIPRemoved = Get-LatestfileToSend -PathtoCheck "D:\HealthChecks\Reports" -PartofFileName "skype-users_results"
}
Get-SecureSendMail -EmailAttachment $CheckIPRemoved -SubjectTitle "Skype Checks_183v" -Verbose
Write-Host "Sleeping for 5 Secs"
Sleep -Seconds 5


#Send Skype Performace Checks 
$SkypePerf = Get-LatestfileToSend -PathtoCheck "D:\HealthChecks\Reports" -PartofFileName "windows_server_performance_results"
$CheckIPRemoved = Get-ChildItem -Path $SkypePerf | Where-Object {$_.name -match $ReportIPRemoved}

If (!$CheckIPRemoved) {
Get-RemoveIPsfromFile -PathtoFile $SkypePerf
$CheckIPRemoved = Get-LatestfileToSend -PathtoCheck "D:\HealthChecks\Reports" -PartofFileName "windows_server_performance_results"
}
Get-SecureSendMail -EmailAttachment $CheckIPRemoved -SubjectTitle "Skype Checks_183v" -Verbose
Write-Host "Sleeping for 5 Secs"
Sleep -Seconds 5

#Send xHF Checks 
$xHFResults = Get-LatestfileToSend -PathtoCheck "D:\xHF\Results"
$CheckIPRemoved = Get-ChildItem -Path $xHFResults | Where-Object {$_.name -match $ReportIPRemoved}

If (!$CheckIPRemoved) {
Get-RemoveIPsfromFile -PathtoFile $xHFResults
$CheckIPRemoved = Get-LatestfileToSend -PathtoCheck "D:\xHF\Results"
}
Get-SecureSendMail -EmailAttachment $CheckIPRemoved  -SubjectTitle "xHF Report_183v" -Verbose
