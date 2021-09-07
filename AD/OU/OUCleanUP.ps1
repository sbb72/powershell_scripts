$OUs = Get-ADOrganizationalUnit -Filter * -Properties CanonicalName,Name,DistinguishedName, Created, Description, whenChanged, gplink | Select CanonicalName,Name,DistinguishedName, Created, Description, whenChanged, gplink

$LogFile = "F:\SBarker\Clean-up\"+(Get-Date -Format dd_MM_yyy)+"_OUInfo.csv"
$FullResults =@()

ForEach ($OU in $OUs) {

If ("$($OU.gplink)") {$GPlink = "YES"} ELSE {$GPlink = "NO"}

    $Results = [pscustomobject]@{

    Name = $OU.Name
    CanonicalName = $OU.CanonicalName
    DistinguishedName = $OU.DistinguishedName
    Created = $OU.Created
    Description = $OU.Description
    whenChanged = $OU.whenChanged
    UserCount = (Get-Aduser -Filter * -SearchBase $OU.DistinguishedName -SearchScope OneLevel | Measure-Object).count
    ComputerCount = (Get-ADComputer -Filter * -SearchBase $OU.DistinguishedName -SearchScope OneLevel | Measure-Object).Count
    GroupCount = (Get-AdGroup -filter * -searchbase $OU.DistinguishedName | Measure-Object).Count
    GPOLinked = $GPlink

    }

$FullResults += $Results

#$OU.gplink = ""

Remove-Variable -Name GPlink
}


$FullResults | Export-Csv -Path $LogFile -NoTypeInformation
