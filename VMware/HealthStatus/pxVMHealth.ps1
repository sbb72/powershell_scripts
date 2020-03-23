$vCenter ="vc"
connect-VIServer $vCenter
$allvms = @()
$vms = "servername"
$Log ="F\Sbarker\"

foreach($vm in $vms){
  $vmstat = "" | Select VmName, MemMax, MemAvg, MemMin, CPUMax, CPUAvg, CPUMin
  $vmstat.VmName = $vm
  
  $statcpu = Get-Stat -Entity ($vm)-start (get-date).AddDays(-7) -Finish (Get-Date)-MaxSamples 10000 -stat cpu.usage.average
  $statmem = Get-Stat -Entity ($vm)-start (get-date).AddDays(-7) -Finish (Get-Date)-MaxSamples 10000 -stat mem.usage.average

  $cpu = $statcpu | Measure-Object -Property value -Average -Maximum -Minimum
  $mem = $statmem | Measure-Object -Property value -Average -Maximum -Minimum
  
  $vmstat.CPUMax = $cpu.Maximum
  $vmstat.CPUAvg = $cpu.Average
  $vmstat.CPUMin = $cpu.Minimum
  $vmstat.MemMax = $mem.Maximum
  $vmstat.MemAvg = $mem.Average
  $vmstat.MemMin = $mem.Minimum
  $allvms += $vmstat
}
$allvms | Select VmName, MemMax, MemAvg, MemMin, CPUMax, CPUAvg, CPUMin | Export-Csv "F:\Sbarker\test.csv" -noTypeInformation

Disconnect-VIServer $vCenter