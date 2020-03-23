#$Shares = Get-Content "D:\Temp\Sbarker\folder.txt"
$OutFile = "D:\Temp\Sbarker\Perms-Home01.csv"

$Header = "Folder Path,IdentityReference,AccessControlType,IsInherited,InheritanceFlags,PropagationFlags"
Del $OutFile
Add-Content -Value $Header -Path $OutFile 

$RootPath = "\User"

$Folders = dir $RootPath | where {$_.psiscontainer -eq $true}

foreach ($Folder in $Folders){
	$ACLs = get-acl $Folder.fullname | ForEach-Object { $_.Access  }
	Foreach ($ACL in $ACLs){
	$OutInfo = $Folder.Fullname + "," + $ACL.IdentityReference  + "," + $ACL.AccessControlType + "," + $ACL.IsInherited + "," + $ACL.InheritanceFlags + "," + $ACL.PropagationFlags
	Add-Content -Value $OutInfo -Path $OutFile
	}
}
