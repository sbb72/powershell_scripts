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
        $Hostobject = New-Object PSObject
        $Hostobject | Add-Member -membertype NoteProperty -name "HostName" -Value $vmHost.name
        $statcpu = Get-Stat -Entity ($vmHost)-start (get-date).AddDays(-$interval) -Finish (Get-Date)-MaxSamples 10000 -stat cpu.usage.average
        $statmem = Get-Stat -Entity ($vmHost)-start (get-date).AddDays(-$interval) -Finish (Get-Date)-MaxSamples 10000 -stat mem.usage.average
        $cpu = $statcpu | Measure-Object -Property value -Average -Maximum -Minimum
        $mem = $statmem | Measure-Object -Property value -Average -Maximum -Minimum
        $Hostobject | Add-Member -membertype NoteProperty -name "vCenter" -Value $vcenter
        $Hostobject | Add-Member -membertype NoteProperty -name "Cluster" -Value $cluster
        $Hostobject | Add-Member -membertype NoteProperty -name "CPUMax" -Value $cpu.Maximum
        $Hostobject | Add-Member -membertype NoteProperty -name "CPUAvg" -Value $cpu.Average
        $Hostobject | Add-Member -membertype NoteProperty -name "CPUMim" -Value $cpu.Minimum
        $Hostobject | Add-Member -membertype NoteProperty -name "MemMax" -Value $mem.Maximum
        $Hostobject | Add-Member -membertype NoteProperty -name "MemAvg" -Value $mem.Average
        $Hostobject | Add-Member -membertype NoteProperty -name "MemMin" -Value $mem.Minimum
        $allhosts += $Hostobject	
        }

    }
} 
$allhosts | Export-Csv -Path $Output -NoTypeInformation