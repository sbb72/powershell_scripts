Import-Module ActiveDirectory

$UserGps = Import-Csv ".\RemoveGps.csv"
$output = ".\RemoveLog.log"

ForEach ($item in $UserGps) {

    Write-host "Removing $($Item.user) from $($Item.group)"
    Remove-ADGroupMember -Identity $($Item.group) -Members $($Item.user) -Confirm:$false
    if (-not $?) {
        write-warning "Someting went wrong"
        "Removing $($Item.user) from $($Item.group), Someting went wrong" | Out-File $output -Append
    }
    else {
        write-host "Removed OK"
        "Removing $($Item.user) from $($Item.group) Removed OK" | Out-File $output -Append
    }
}