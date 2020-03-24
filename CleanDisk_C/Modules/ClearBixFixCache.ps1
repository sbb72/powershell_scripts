function Clear-BixFixCache {
    [CmdletBinding()]
    param (
       $computername,
       $Architecture 
    )
    If ($Architecture -like "*64*") {
        $BigfixCache = "C$\Program Files (x86)\BigFix Enterprise\BES Client\__BESData\__Global\__Cache\Downloads"
    }
    Else {
        $BigfixCache = "C$\Program Files\BigFix Enterprise\BES Client\__BESData\__Global\__Cache\Downloads"
    }
    Get-ChildItem "\\$computername\$BigfixCache" -Force | remove-item -Recurse -Force
}