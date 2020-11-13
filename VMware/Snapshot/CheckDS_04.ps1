$strDate = Get-date -f "dd-MM-yyyy"
$strTime = Get-date -f "HH:mm"
$Datastore = "dsName"

$outputfile = "D:\path\Datastore04.csv"

$vCenterServer = "vcname"

Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue 

Connect-VIServer $vCenterServer


$logdata = @()

$DSData = New-Object PSObject -Property @{
    Datastore = $Datastore
    Time = $strTime
    Date = $strDate
    CapacityGB= ""
    FreeSpaceGB= ""}


$ds_Data = Get-Datastore -Name $Datastore

$DSData.CapacityGB = [math]::round($ds_Data.CapacityGB,2)
$DSData.FreeSpaceGB = [math]::round($ds_Data.FreeSpaceGB,2)

$emailBody = $Datastore + " Has Free Space=" + $DSData.FreeSpaceGB +" GB"

$logdata += $DSData


$logdata | Select-Object Datastore,Time,Date,CapacityGB,FreeSpaceGB | Export-csv $outputfile -notypeinformation -Append

Send-MailMessage -To "","" -From  -Subject "" -SmtpServer "" -Body $emailBody -Attachments $outputfile 