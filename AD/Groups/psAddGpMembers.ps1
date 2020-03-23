Import-Module ActiveDirectory
$Group = "GroupName"
$Items = Get-Content ".\computers.txt"

ForEach ($item in $Items) {

    Write-host "Adding $Item to $Group"
    Add-ADGroupMember -Identity $Group -Members $Item -Confirm:$false
    if (-not $?) {
        write-warning "Someting went wrong"
    }
    else {
        write-host "$Item Added OK"
    }
}