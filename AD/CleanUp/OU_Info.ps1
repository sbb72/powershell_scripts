$OUs = Get-ADOrganizationalUnit -Filter * -Properties CanonicalName,Name,DistinguishedName, Created, Description, whenChanged, gplink | Select CanonicalName,Name,DistinguishedName, Created, Description, whenChanged, gplink
$LogFile = "Path\OUCleanup_"+$($(Get-Date -Format dd-MM-yyy))+".csv"

$FullResults = New-Object System.Collections.ArrayList

ForEach ($OU in $OUs) {
    
    Write-host "Getting data for $($OU.Name)" -ForegroundColor Green

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

Remove-Variable -Name GPlink
} 

$FullResults | Export-Csv -Path $Logfile -NoTypeInformation