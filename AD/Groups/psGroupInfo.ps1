$GroupsStats= Import-Csv Path\OU_13-04-2022.csv
$GPFullResults = New-Object System.Collections.ArrayList

$GPLogFile = "Path\GPInfo_"+$($(Get-Date -Format dd-MM-yyy))+".csv"

Foreach ($Item in $GroupsStats) {
    
    If ($Item.GroupCount -gt 0) {

        $GPs = Get-ADGroup -filter * -SearchBase $Item.DistinguishedName -SearchScope OneLevel -Properties Name,description,DistinguishedName,whenChanged,GroupScope,GroupCategory
   
            ForEach ($GP in $GPs) {
                
                Write-Host "Checking Group $($GP.Name)" -ForegroundColor Green
                    $Results = [pscustomobject]@{
                    GroupName = $GP.Name
                    GP_Description = $GP.Description
                    DistinguishedName = $GP.DistinguishedName
                    LastModified = $GP.whenChanged
                    GroupScope = $GP.GroupScope
                    GroupCategory = $GP.GroupCategory
                    "NoOfUsers in Group" = (Get-ADGroup -Identity $Gp.Name -Properties members).members.count

                    }

                    $GPFullResults += $Results
            }
       
    }
}

$GPFullResults | Export-Csv -Path $GPLogFile -NoTypeInformation
