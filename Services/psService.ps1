#Date Variable
$strLogDate = Get-Date -f dd-MM-yyyy
#Log file
$LogFile = ".\$strLogDate-ServiceCheck.csv"
#Service to check
$strService = 'AcSvc'
#List of VMs
$Servers = Get-Content "D:\Temp\Servers.txt"

$LogData = @()
ForEach ($Item in $Servers) {

#Ping Test before tries to connect to server
$LogStat = "" | Select Server,Ping,Service,Status
$LogStat.Server = $Item
    If (Test-Connection -computername $Item -count 1 -quiet) {
    $LogStat.Ping = "PingOK"
    Write-Output "$Item is pinging"

    $CheckServcie = Get-Service -Computername $Item | Where-Object {$_.Name -eq $strService} -ErrorAction Continue
    $LogStat.Service = $strService
    $LogStat.Status = $CheckServcie.Status
}
ELSE
    {
    $LogStat.Ping = "NoConnectivity"
    Write-Output "$Item not Pinging"
    }
$LogData += $LogStat
}#END

$LogData | Select Server,Ping,Service,Status | Export-CSV -Path $LogFile -NoType
