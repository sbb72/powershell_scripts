$KBNumber = "KB982018"

$hofixdetails = @()

$Servers = Get-Content -Path D:\Temp\Servers.txt

ForEach ($server in $servers) {
	$Hoxfixstat = "" | Select ServerName,MSHotFix,Installon
	$Hoxfixstat.ServerName = $Server
    
    $MSDetails = Get-HotFix -Computername $server | Where {$_.HotfixID -eq $KBNumber}
    $Hoxfixstat.InstalledON = $MSDetails.Installedon
    $Hoxfixstat.MSHotFix = $MSDetails.HotfixID
 
	$hofixdetails += $Hoxfixstat
 }

$hofixdetails | Select ServerName,MSHotfix, InstalledOn  | Export-CSV -Path D:\Temp\HFresults.csv -NoType