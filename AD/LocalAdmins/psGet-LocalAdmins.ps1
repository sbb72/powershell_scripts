<#
.DESCRIPTION
This script has been created to check what is in the local Administrators group of a remote machine
.INPUTS
  Change $servers with a valid location of the text file containing the list of servers and the script.
.OUTPUTS
  Log file stored in $output
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  05-06-2019
  Purpose/Change: Initial script  
#>

Import-Module ActiveDirectory
#Choose the input data below
#$servers = Get-Content ".\PCList.txt"
$Servers = Get-adcomputer -filter {OperatingSystem -like "*server*"} | Select Name

$reportdate = Get-Date -Format dd-MM-yyyy
$output = ".\"+$ReportDate+"_LocalAdmins.csv"

$results = @()

foreach ($server in $servers) {
$server = $Server.name
  $admins = @()
  $group = [ADSI]"WinNT://$server/Administrators" 
  $members = @($group.psbase.Invoke("Members"))
  Write-Host "Checking $Server" -ForegroundColor Green
  If (Test-Connection -computername $server -count 1 -quiet) {
    $members | foreach {
      $obj = new-object psobject -Property @{
        Server = $Server
        Admin  = $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
        Ping   = "Ping OK"
      }
      $admins += $obj
    }
  }
  ELSE {
    $objPing = new-object psobject -Property @{
      Server = $Server
      Ping   = "NoConnectivity"
    }
    $admins += $ObjPing
    Write-Host "$server not Pinging" -ForegroundColor Red
  }
  $results += $admins
}
$results | Export-csv $Output -NoTypeInformation