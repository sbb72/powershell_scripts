#Extract Report from snow to get all INC number to resolve
#Cache SNOW Creds alsoing Write-SavedCredential

Import-Module "D:\Data\git-repo-work\iSolve-Powershell-Module\DXC-iSolve"

$Incidents = Get-Content D:\Data\git-repo\powershell-scripts\Snow\inc_numbers.txt

Foreach ($inc in $Incidents) {

sleep 2

#Update-SnowIncident -Url csc.service-now.com -Number $inc -Resolve -CloseCode 'Cancelled' -CloseNotes 'resolved' -Verbose
#Update-SnowIncident -Url cscqa.service-now.com -Number $inc -Resolve -CloseCode 'Cancelled' -CloseNotes 'resolved' -Verbose 
Update-SnowIncident -Url cscqa.service-now.com -CredentialFor 'Snow-Set-csc.service-now.com' -Number $Inc -Resolve -CloseCode 'Cancelled' -CloseNotes 'Resolved - Duplicate' -Verbose -ErrorAction SilentlyContinue

}​​​​​

#-CredentialFor 'Snow-Set-cscqa.service-now.com'

write-savedcredential -for Snow-Set-csc.service-now.com -user zziaction.bot@csc.com

$snowcreds = Read-SavedCredential -For Snow-Set-csc.service-now.com
$Password = $snowcreds.GetNetworkCredential().Password

write-savedcredential -for Snow-Set-csc.service-now.com -user zzServer.Decommissioning@dxc.com

User id: zzServer.Decommissioning@dxc.com
Default Password: XHJxDw^RMUCQqB)k


Function Get-SNOWInc {
Param (

[int]$LastDays = 30,
[string]$CI = "glkas3045v",
[string]$active = "true"

)

#Import-Module DXC-iSolve

Get-SnowIncident -Url "cscqa.service-now.com" -CollectionPeriod (60*24*$LastDays) -First 999 -Company "BAE Systems" -OpenedBy "" -AssignmentGroups "*" -States "*" -ShortDescriptionContains:$CI -CollectUpdated:$false -CollectUnresolvedOlderThan:$false -CredentialFor "Snow-Set-csc.service-now.com" #| Where-Object -Property "active" -eq $active 
Get-SnowIncident -Url "csc.service-now.com" -CollectionPeriod (60*24*$LastDays) -First 999 -Company "BAE Systems" -OpenedBy "" -AssignmentGroups "*" -States "*" -FullDescriptionContains:$CI -CollectUpdated:$false -CollectUnresolvedOlderThan:$false -CredentialFor "Snow-Set-csc.service-now.com " #| Where-Object -Property "active" -eq $active
Get-SnowIncident -Url "cscqa.service-now.com" -CollectionPeriod (60*24*$LastDays) -First 999 -Company "BAE Systems" -OpenedBy "" -AssignmentGroups "*" -States "*" -CollectUpdated:$false -CollectUnresolvedOlderThan:$false -CredentialFor "Snow-Set-csc.service-now.com"

}

Get-SNOWInc -LastDays 30 -CI glkas3045v 
$Company =  "BAE Systems"
$CompanyId = Get-ServiceNowTableEntry -Table "core_company" -MatchExact @{name=$Company} -ErrorAction Stop | Select-Object -ExpandProperty sys_id
$CompanyQuery = @{company=$CompanyId}


Get-SnowIncident -Url 'csc.service-now.com' -Numbers 'INC25794240' -CredentialFor 'Snow-Set-csc.service-now.com' -Verbose

Get-SnowIncident -Url 'cscqa.service-now.com' -Numbers 'INC6712715' -CredentialFor 'Snow-Set-csc.service-now.com' -Verbose

Get-SnowIncident -Url 'csc.service-now.com' -Numbers 'INC25797537' -CredentialFor 'Snow-Set-csc.service-now.com' -Verbose
Get-SnowIncident -Url "csc.service-now.com" -CollectionPeriod (60*24*30) -First 999 -Company "BAE Systems" -OpenedBy "" -AssignmentGroups "*" -States "*" -ShortDescriptionContains:$CI -CollectUpdated:$false -CollectUnresolvedOlderThan:$false -CredentialFor 'Snow-Set-csc.service-now.com'

###################################################################
#Update RITMS
Import-Module "D:\Data\git-repo-work\iSolve-Powershell-Module\DXC-iSolve"

$Credential = Read-SavedCredential -For "Snow-Set-csc.service-now.com"

Set-ServiceNowAuth -Url "csc.service-now.com" -Credentials $Credential

$RITMRef = "RITM3611811"

$Query = @{
    "number" = "$RITMRef"
}
#"active" = "true"
$ritm = Get-ServiceNowTableEntry -Table sc_req_item -MatchExact $Query 

$Update = @{
    "comments" = "Test Automation SB"
}

Update-ServiceNowTableEntry -SysId "$($ritm.sys_id)" -Table "sc_req_item" -Values $Update

$ritm.comments


zziaction.bot@csc.com

Router121#