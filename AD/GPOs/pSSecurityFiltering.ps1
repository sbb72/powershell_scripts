#Get-GPPermissions -Name "GPO_Name" -all | Select Trustee FT

#Add to Security Filtering
$Computers = Get-Content .\Computers.txt
ForEach ($Computer in $Computers){
Write-Host "Adding $Computer"
Set-GPPermissions -Name "GPO_Name" -TargetName $Computer -PermissionLevel GpoApply -TargetType Computer

}


Set-GPPermissions -Name "GPO_Name" -TargetName 2FA_Server_Activation -PermissionLevel GpoApply -TargetType Group

Get-GPPermissions "GPO_Name" -All | Where {$_.Trustee -eq "Computer_Name"} | Select Trustee

#Remove to Security Filtering
$Computers = Get-Content G:\SBarker\Scripts\GPO\Computers.txt
ForEach ($Computer in $Computers){
Write-Host "Removing $Computer"
Set-GPPermissions -Name "GPO_Name" -Replace -PermissionLevel None -TargetName $Computer -TargetType Computer

}