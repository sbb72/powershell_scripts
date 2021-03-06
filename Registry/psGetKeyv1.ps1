
$serverdetails = @()

$Servers = Get-Content -Path C:\Scripts\Sb\Servers.txt

ForEach ($Server in $Servers) {
	$RegStat = "" | Select ServerName, RegValue
	$RegStat.ServerName = $Server

	$w32reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$Server)
	$KeyPath = 'SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters'
	$TokenSize = $w32reg.OpenSubKey($KeyPath)
	$TokenSizeValue = $TokenSize.GetValue('MaxTokenSize')

	$RegStat.RegValue = $TokenSizeValue

	$serverdetails += $RegStat
	$Server
	$TokenSizeValue = $NULL
}

$serverdetails | Select ServerName, RegValue | Export-CSV -Path C:\Scripts\sb\results.csv -NoType
