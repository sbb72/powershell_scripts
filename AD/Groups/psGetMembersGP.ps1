#Needs Testing

Import-Module ActiveDirectory
$short_date = Get-Date -uformat "%Y%m%d"
$Path = "C:\Temp\GPs"
$OutPut=$Path+$short_date+".csv"

$Groups = (Get-AdGroup -filter * | Where {$_.name -like "**"} | select name -expandproperty name)

$GPData = @()
Foreach ($Group in $Groups) {
$Arrayofmembers = Get-ADGroupMember -identity $Group | select name,samaccountname
    Foreach ($Member in $Arrayofmembers) {
    $GPobject = New-Object PSObject
    $GPobject | Add-Member -membertype NoteProperty -name "Group" -Value $Group.Name
    $GPobject | Add-Member -membertype NoteProperty -name "UserName" -Value $Member.Name
    $GPobject | Add-Member -membertype NoteProperty -name "SAMAccountName" -Value $Member.SAMaccountname
    $GPData += $GPobject
    }
}
$GPData | Export-csv -Path $OutPut -Notype

