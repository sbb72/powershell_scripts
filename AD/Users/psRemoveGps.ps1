<#
.DESCRIPTION
Simple script to remove a user from a specified group
.INPUTS
The csv file has a user name and group name in columns
.OUTPUTS
Create a log file when with any errors 
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  03-11-2018
  Purpose/Change: Initial script  
Version 1.0
Purpose/Change: Initial script  
#>

Import-Module ActiveDirectory

$UserGps = Import-Csv "\.csv"
$output = "\.log"

ForEach ($item in $UserGps) {

Write-host "Removing $($Item.user) from $($Item.group)"
Remove-ADGroupMember -Identity $($Item.group) -Members $($Item.user) -Confirm:$false
    if (-not $?) {write-warning "Someting went wrong"
    "Removing $($Item.user) from $($Item.group), Someting went wrong" |  Out-File $output -Append}
    else {write-host "Removed OK"
     "Removing $($Item.user) from $($Item.group) Removed OK" |  Out-File $output -Append}
}