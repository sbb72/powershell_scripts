<########
.DESCRIPTION
Checks ping reply and the uptime using WMI
.INPUTS
 A list of servers in a specified in $ServerList var
.OUTPUTS
  Log file stored $Output variable, change the location in the variable if required. 
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  07-02-2018
  Purpose/Change: Initial script  
Version 1.0
Purpose/Change: Initial script  
#############
IMPROVEMENTS
#############
1.Error check if WMI fails try to get Uptime
#>

#Group Name
$GP = "Group1"
#Create Log Name String
$Path="C:\Temp\"
$short_date = Get-Date -uformat "%Y%m%d"
$OutPut=$Path+$GP+$short_date+".csv"
$ServerList = "C:\Temp\Test.txt"

#List of server names
$Servers = Get-Content $ServerList
$PingData = @()
Function Uptime {
    $wmi = Get-WmiObject Win32_OperatingSystem -computer $Server
    $LBTime = $wmi.ConvertToDateTime($wmi.Lastbootuptime)
    [TimeSpan]$uptime = New-TimeSpan $LBTime $(get-date)
    $UpTimeHoursDays = "$($uptime.days) Days & $($uptime.hours) Hours"
    $Pingobject | Add-Member -membertype NoteProperty -name "UpTime" -Value $UpTimeHoursDays
  
    #Write-output $PingStat.ServerName   
    Write-output $UpTimeHoursDays
    $Pingobject | Add-Member -membertype NoteProperty -name "Error" -Value "OK"
}

foreach ($Server in $Servers) {
    $Pingobject = New-Object PSObject
    $Pingobject | Add-Member -membertype NoteProperty -name "HostName" -Value $Server
    Write-Host "Checking $Server"
    If (Test-Connection -ComputerName $Server -Count 1 -ErrorAction SilentlyContinue ) {
     Uptime $Server
    }
    else {
    Write-output "$Server NoPing"
    $Pingobject | Add-Member -membertype NoteProperty -name "Error" -Value "No Ping"
    Uptime $Server
	}
 	$PingData += $Pingobject
}
$PingData | Export-csv -Path $OutPut -Notype