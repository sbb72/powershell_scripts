Add Objects from Security Filtering
import-csv c:\path | foreach {Set-GPPermissions -name GPOName -Permissionlevel gpoapply -TargetName $_.server -TargetType Computer}

Remove Objects from Security Filtering
import-csv c:\path | foreach {Set-GPPermissions -name GPOName -Permissionlevel none -TargetName $_.server -TargetType Computer}

List permissions
Get-GPPermissions -name GPOName -all | FT

