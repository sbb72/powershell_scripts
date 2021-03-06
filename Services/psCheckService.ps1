##########################################################
##	Description: Extract DNS details for Servers 		##
##				 moving datacenter via SRM 				##
##														##
##														##
##	Date: 06-01-2015									##
##	Version 0.1 - Script Creation						##
##														##
##	S Barker											##
##														##
##########################################################

#Date Variable
$strLogDate = Get-Date -f dd-MM-yyyy
$strLogDir = "D:\Temp\"
#Log file
$strAVCheck = "$strLogDir$strLogDate-AVCheck.csv"
#Log file No Pings
$strNoPings = "$strLogDir$strLogDate-NoPings.txt"
#List of VMs
$ServerName = Get-Content "D:\Temp\Servers.txt"
#Service to check
#$strService = "SepMasterService"
$strService = 'AeLookupSvc'
#Create array used to capture hostname, mac and ip address
$outarray = @()

CheckService

Function CheckService{
	ForEach ($ItemServer in $ServerName) {
	$colitems = Get-Service -Computername $ItemServer | Where-Object {$_.Name -eq $strService} -ErrorAction Continue
			ForEach($Item in $colitems) {
		    $outarray += New-Object PsObject -property @{
	    	'Server' = $ItemServer
	        'Service' = $strService
	        'Status' = $Item.Status
	        }
			}
	#export to .csv file
	$outarray | export-csv $strAVCheck -NoTypeInformation	
	}
}

Function GetPing {
	ForEach ($Name in $ServerName){
	if (Test-Connection -ComputerName $name -Count 1 -ErrorAction SilentlyContinue) {
	    Write-output "$name WORKING pinging"
		$strPing = "$Name Pinged"
		}
	else 
		{Write-output "$name is not pinging"
		$strPing = "$Name FailedPing"
	      }
	$strPing
	}
}	
		 