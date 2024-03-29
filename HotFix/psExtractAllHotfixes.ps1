$hofixdetails = @()

#$Servers = Get-Content -Path D:\Temp\Servers.txt

$Servers = "GB-PF0Y506L"
ForEach ($server in $servers) {

    $hofixdetails = Get-HotFix -Computername $server 
        ForEach ($patchitem in $hofixdetails) {
        
         $Patches = New-Object psobject -Property @{
                Servername = $Server
                Description = $($patchitem.description)
                HotFixID = $($patchitem.HotFixID)
                InstalledBy = $($patchitem.InstalledBy)
                InstalledOn = $($patchitem.InstalledOn)
                }
        
        }
 
	$hofixdetails += $Patches
 }

$hofixdetails | Select Servername,Description, HotFixID,InstalledBy,InstalledOn  | Export-CSV -Path .\HFresults.csv -NoType