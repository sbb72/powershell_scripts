<#
.DESCRIPTION
Check LAPS is installed
.INPUTS
  Queries Ad to get a list of servers that are enabled but NOT Domain Controllers
.OUTPUTS
    N|A
.NOTES
  Version:        2.0
  Author:         SBarker
  Creation Date:  12-12-2017
  Purpose/Change: Initial script  
Version 1.0
  Purpose/Change: Initial script  
Version 2.0 - 15-05-2019
  Added TRY/Catch to log errors
  Changed the input data to query AD rather than a manual list.
#>

$strLogDate = Get-Date -f ddMMyyyy
$Resultscsv = "Drive:\Path\CheckLAPS-$strLogDate.csv"
$servers = Get-AdComputer -Filter {(OperatingSystem -like "*server*") -and (Enabled -eq "true") -and (name -notlike "DCNames*")} -properties Name, enabled | Select Name
#Array
$LogData = @()

Foreach ($server in $Servers) {
$LogStat = New-Object psobject -Property @{
ServerName=""
Ping=""
LAPSInstalled=""
UNCConnection=""
}
$LogStat.ServerName = $($Server.name)
$Server = $($Server.name)

    If (Test-Connection -computername $Server -count 1 -quiet) {
    $LogStat.Ping = "PingOK"
        #Check if CSE is installed
        TRY{
            If (Test-Path "\\$server\c$\Program Files\LAPS\CSE\AdmPwd.dll" -ErrorAction STOP){
            Write-Host "Installed on $Server!" -ForegroundColor GREEN
            $LogStat.LAPSInstalled = "Y"}
        }
        CATCH {
        Write-Warning "$Server Not Installed or Access Denied"
        $LogStat.LAPSInstalled = "N"
        $LogStat.UNCConnection = "ERROR"
         }
    }  
    ELSE {
    $LogStat.Ping = "No"
    Write-Host "$Server No Ping" -ForegroundColor RED
    }
$LogData += $LogStat
}
$LogData | Select ServerName,Ping,LAPSInstalled,UNCConnection | Export-csv -Path $Resultscsv -NoType