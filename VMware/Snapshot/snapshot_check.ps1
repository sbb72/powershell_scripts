$strDate = Get-date -f "dd-MM-yyyy"
$strTime = Get-date -f "HH:mm"
$ServerName = "servername"

$outputfile = "D:\path\Servername_snapshot.csv"

$vCenterServer = "vcname"

Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue 

Connect-VIServer $vCenterServer


$logdata = @()

$SnapData = New-Object PSObject -Property @{
    Server = $ServerName
    Time = $strTime
    Date = $strDate
    SnapsizeGB= ""
    SnapsizeMB= ""}


$snap3266v = Get-VM -Name $ServerName | Get-Snapshot

$SnapData.SnapsizeGB = [math]::round($snap3266v.SizeGB,2)
$SnapData.SnapsizeMB = [math]::round($snap3266v.SizeMB,2)

$emailBody = " snapshot is " +$SnapData.SnapsizeMB+ "MB "+ $SnapData.SnapsizeGB +"GB"

$logdata += $SnapData


$logdata | Select-Object Server,Time,Date,SnapsizeGB,SnapsizeMB | Export-csv $outputfile -notypeinformation -Append

Send-MailMessage -To "","" -From  -Subject "" -SmtpServer "" -Body $emailBody  -Attachments $outputfile

#Get-VM -Name "VMName" | Ft Name, @{label="Snapshot_SizeMB";Expression={[math]::round((Get-Snapshot -VM $_ | Measure-object -sum SizeMB).sum, 2)}}, @{label="Snapshot_SizeGB";Expression={[Math]::Round((Get-Snapshot -VM $_ | Measure-object -sum SizeGB).sum,2)}}