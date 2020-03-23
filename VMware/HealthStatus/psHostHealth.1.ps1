<#
.DESCRIPTION
Export the top level performance for CPU and Memory per virtual cluster
.INPUTS
  Change $vCenters variable with a valid vCenters
  Change the interval variable to change the date range for the performance interval check
.OUTPUTS
   Change $Output to the output file location.
.AMENDMENTS
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  02-01-2018
  Purpose/Change: Initial script  
Version 1.0
Created Script
#>

#Add date for file name
$short_date = Get-Date -uformat "%Y%m%d"
$Output = "C:\Temp\HealthCheck_$short_date.cev"

# Adds the powercli cmdlets
Add-PSSnapin VMware.VimAutomation.Core -erroraction SilentlyContinue

#Change virtual center servers here!
$vcenters = "vCenter"
$allhosts = @()
$interval = 7

foreach($vcenter in $vcenters){
#Disconnects from any viserver to stop potential false results in ouput
if ($global:DefaultVIServer -ne $null){
write-host "Disconnecting from current vcenter(s)"
disconnect-viserver * -confirm:$false}
else {
write-host "Not connected to any vCenter, continuing"}
#Connect to vCenter    
Connect-VIServer -Server $vcenter
    Foreach($cluster in Get-Cluster){
        Write-host "Checking $($Cluster.Name)"
        foreach($vmHost in ($Cluster | Get-VMHost)){
          $statcpu = Get-Stat -Entity ($vmHost)-start (get-date).AddDays(-$interval) -Finish (Get-Date)-MaxSamples 10000 -stat cpu.usage.average
          $statmem = Get-Stat -Entity ($vmHost)-start (get-date).AddDays(-$interval) -Finish (Get-Date)-MaxSamples 10000 -stat mem.usage.average
          $cpu = $statcpu | Measure-Object -Property value -Average -Maximum -Minimum
          $mem = $statmem | Measure-Object -Property value -Average -Maximum -Minimum}
          $Hostobject += New-Object psobject -Property @{

         'vCenter' = $vcenter
        'Cluster' = $cluster
        'HostName' = $vmHost.Name
        'CPUMax' = $cpu.Maximum
        'CPUAvg' = $cpu.Average
        'CPUMim' = $cpu.Minimum
        'MemMax' = $mem.Maximum
        'MemAvg' = $mem.Average
        'MemMin' = $mem.Minimum
        }

    }
   # $allhosts += $Hostobject
} 
$allhosts | Export-Csv -Path $Output -NoTypeInformation