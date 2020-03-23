<#
.DESCRIPTION
Tests connectivity to the server, then check status of a Service exporting the results into a csv file
.INPUTS
  Change $Servers variable to the input file location
.OUTPUTS
  Log file stored in C:\Temp\
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  10-04-2017
  Purpose/Change: Initial script  
.EXAMPLE
  N|A
#>
#Create Log Name String
$Path="C:\Temp\"
$strLogDate = Get-Date -f ddMMyyyy

$log=$Path+$strLogDate+"-ServerCheck.csv"

#Service to check
$strService = "dhcp"

#List of server names
$Servers = Get-Content "C:\Temp\Test.txt"
$serverdetails = @()

foreach ($Server in $Servers) {
   $PingStat = "" | Select ServerName,Days,Error,Service,Status,StartType
   $PingStat.ServerName = $Server
    
    if ( Test-Connection -ComputerName $Server -Count 1 -ErrorAction SilentlyContinue ) {
        $wmi = gwmi Win32_OperatingSystem -computer $Server
        $LBTime = $wmi.ConvertToDateTime($wmi.Lastbootuptime)
        [TimeSpan]$uptime = New-TimeSpan $LBTime $(get-date)
        $PingStat.Days = "$($uptime.days)Days&$($uptime.hours)Hours"
        #Write-output $PingStat.ServerName   
        Write-output "$Server $($uptime.days)Days&$($uptime.hours)Hours"
        $PingStat.Error = "OK"
            #Check Service
            $colitems = Get-Service -Computername $Server | Where-Object {$_.Name -eq $strService} -ErrorAction Continue 
           	ForEach($Item in $colitems) {
            $PingStat.Service = $strService
	        $PingStat.Status = $Item.Status
	        $pingStat.StartType = (Get-WmiObject Win32_Service -filter "Name='$strService'").StartMode
            }
        }
        else {
        Write-output "$Server NoPing"
        $PingStat.Days = "ERROR"
        $PingStat.Error = "NoPing"
		    }
 	$serverdetails += $PingStat
}
$serverdetails | Select ServerName,Days,Error,Service, Status,StartType | Export-csv -Path $log -Notype