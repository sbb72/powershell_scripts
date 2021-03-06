<#
.DESCRIPTION
This script has been created to help gather information to aid troubleshooting a windows server.
It places all the useful information in a html file
.INPUTS
  N\A
.OUTPUTS
  Log file stored in the directory specified in $path variable, change the location in variable if required.
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  09-02-2017
  Purpose/Change: Initial script  
Version 1.0
Purpose/Change: Initial script  
#>

#Variables
$date = Get-Date -f "HH:mm dd-MM-yyyy"
$strLogDate = Get-Date -f ddMMyyyy
$hostname = $env:COMPUTERNAME
$path = "C:\Support\Server_Check"
$outputfile = $path+"\"+$strLogDate+"_"+$hostname+".html"
$ErrorActionPreference = "Stop"
#Progress Bar
$Activity = "Creating Server Checks"
$Step = 0
$ID = "1"
$TotalSteps = "17"

$HeaderTable = @"
<style>
TABLE {font: 12pt Arial; border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;text-align:left;}
TH {font: 12pt Arial; border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;text-align:left;}
TD {font: 12pt Arial; border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

#Check Folder \ File exists
if (Test-Path $path -EA SilentlyContinue) {
write-host "Folder $path already exists" -ForegroundColor Green
    If (Test-Path $outputfile -EA SilentlyContinue) {
        Write-Host "An output file already exists $outputfile, do you want to delete it?" -ForegroundColor Red
        $ReadAnswer = Read-Host " (Y / N) "
        Switch ($ReadAnswer) {
        Y {Remove-Item $outputfile -Force
        Write-Host "OK Deleted the file, Continuing script....." -ForegroundColor Green}
        N {Write-Host "You selected No! Rename the file $outputfile. The script will now exit!!" -ForegroundColor Red;Exit}
        }
    }
}
else {
New-Item $path -type directory | out-null
write-host "New folder created $Path" -ForegroundColor Green
}

$prompt = Read-Host -prompt "Please enter engineer name" 
#"<table><td><img src=""https://twimg0-a.akamaihd.net/profile_images/558490756/CSC_logo_twitter_normal_normal.png"" padding=""20px""></a href></td>" | Out-File $OutputFile
"<td><H1>$hostname - Server Troubleshooting Checks </H1>" | Out-File $OutputFile -append
"<H4>Report produced on: $Date by: $prompt</H4></td></table>" | Out-File $OutputFile -append
Clear-Variable prompt
write-host ""

#System Section(1)
$Step = $Step +1
$Task = "System infomation"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

"<H3>System Section</H3>" | Out-File $OutputFile -append
foreach ($soitem in (Get-WmiObject win32_computersystem | Select-Object Name,Domain,Manufacturer,Model)){
    $systemsection = New-Object -TypeName psobject -Property @{
    ServerName = $soitem.Name
    Domain = $soitem.Domain
    Manufacturer = $soitem.Manufacturer
    Model = $soitem.Model
    OperatingSystem = (Get-WmiObject win32_operatingsystem).caption
    ServicePack = (Get-WmiObject win32_operatingsystem).servicepackmajorversion
    }
$systemsectionarray += $systemsection
}
$systemsectionarray | Select-Object ServerName,Domain,Manufacturer,Model,OperatingSystem,ServicePack | ConvertTo-Html -head $HeaderTable | out-file $outputfile -append

#UpTime (2)
$Step = $Step +1
$Task = "Checking Server UpTime"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

"<H3>UpTime</H3>" | Out-File $OutputFile -append
"<H5>Checking UpTime</H5>" | Out-File $OutputFile -append
ForEach ($uptimeItem in Get-WmiObject Win32_OperatingSystem) {
    $LBTime = $uptimeItem.ConvertToDateTime($uptimeItem.Lastbootuptime) 
    [TimeSpan]$uptime = New-TimeSpan $LBTime $(get-date)
        $upTimesection = New-Object -TypeName psobject -Property @{
        "Server UpTime" = "Server has been up " + $uptime.Days +" Days and "+ $uptime.Hours + " Hours" 
        "Last Reboot Date" = $LBTime
    }
$UpTimeArray += $upTimesection 
}
$UpTimeArray | ConvertTo-Html -head $HeaderTable | out-file $outputfile -append

#Reboot Check(3)
$Step = $Step +1
$Task = "Reboot Check"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

$outreboot = @()
"<H3>Pending Reboot</H3>" | Out-File $OutputFile -append
"<H5>This part of the script check different registry entries to check if a reboot is required.</H5>" | Out-File $OutputFile -append
$RebootRequired = "NO"
if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) {$RebootRequired = "YES"}
    ELSE {if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) {$RebootRequired = "YES"}
        ELSE {if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) {$RebootRequired = "YES"}
        }
    }
$reboot = New-Object -TypeName PSObject -Property @{
 Server = $hostname
"Reboot Pending" = $RebootRequired
}
$outreboot += $reboot
$outreboot | ConvertTo-Html -head $HeaderTable | out-file $outputfile -append

#Checking CPU & Memory (4)
$Step = $Step +1
$Task = "Checking CPU & Memory"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

"<H3>CPU & Memory</H3>" | Out-File $OutputFile -append
$mem = Get-WmiObject -Class win32_operatingsystem | Select TotalVisibleMemorySize
$memsize = [math]::truncate($mem.TotalVisibleMemorySize /1KB)
Get-WmiObject Win32_processor | select-object name, numberoflogicalprocessors, currentclockspeed | foreach {
    $cpumemobject = New-Object -TypeName PSObject -Property @{
    Name = $($_.name)
    "Number of CPUs" = $($_.numberoflogicalprocessors)
    "CPU Speed" = $($_.currentclockspeed)
    "Memory Size MB"= $memsize
    }
    $outmemcpu += $cpumemobject 
}
$outmemcpu | Select-Object Name, "Number of CPUs","CPU Speed", "Memory Size MB" | ConvertTo-Html -head $HeaderTable | out-file $outputfile -append

###CHECK THIS
#Processes (5)
$Step = $Step +1
$Task = "Exporting Top 20 Active Processes"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

$Procsoutput = @()
"<H3>Top 20 Active Processes</H3>" | Out-File $OutputFile -append
get-wmiobject Win32_PerfFormattedData_PerfProc_Process | Sort-Object -Property PercentProcessorTime -Descending | Select Name, PercentProcessorTime -First 20 | Foreach {
    $procsobject = New-Object -TypeName PSObject
    $procsobject | Add-Member -MemberType NoteProperty -Name "Name" -value $($_.name)
    $procsobject | Add-Member -MemberType NoteProperty -Name "CPU Usage%" -value $($_.PercentProcessorTime)
    $Procsoutput += $procsobject
    }
$Procsoutput | ConvertTo-Html -head $HeaderTable | out-file $outputfile -append
$Procsoutput = $NULL

###CHECK THIS
#Memory Usage (6)
$Step = $Step +1
$Task = "Exporting Top 10 Active Memory"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

$memoutput = @()
"<H3>Top 10 Active Memory</H3>" | Out-File $OutputFile -append
$MemPhysical = Get-WmiObject -Class win32_operatingsystem | Select TotalVisibleMemorySize
Get-WMIobject Win32_Process | Sort WorkingSetSize -Descending | Select Name,WorkingSetSize| Select -First 15 | Foreach {
    $memobject = New-Object -TypeName PSObject
    $memobject | Add-Member -MemberType NoteProperty -Name "Name" -value $($_.name)
    $WSMB = [math]::round(($_.WorkingSetSize / 1mb), 2)
    $memobject | Add-Member -MemberType NoteProperty -Name "Private Memory (MB)" -value $WSMB
    $MemPer = [Math]::Round($WSMB / $($MemPhysical.TotalVisibleMemorySize / 1KB) * 100)
    $memobject | Add-Member -MemberType NoteProperty -Name "Private Memory %" -value $MemPer
    $memoutput += $memobject
    }
$memoutput | ConvertTo-Html -head $HeaderTable | out-file $outputfile -append
$memoutput = $NULL

#Drives(7)
$Step = $Step +1
$Task = "Disk Space Check"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

"<H3>Local Disks</H3>" | Out-File $OutputFile -append
ForEach ($individualDisk in (Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq "3"})){
    $diskInfo = New-Object -TypeName PSObject -Property @{
        "Size in GB" = [math]::Round((($individualDisk.Size) /1GB))
        "FreeSpace in GB" = [math]::Round((($individualDisk.FreeSpace) /1GB))
        "FreeSpace%" = [Math]::Round(($individualDisk.FreeSpace /1MB) / ($individualDisk.Size / 1MB) * 100)
        Drive = $individualDisk.DeviceID
        VolumeName = $individualDisk.VolumeName
    }
$ArrayOfDiskInfo += $diskInfo
} 
$ArrayOfDiskInfo | Select-Object Drive,VolumeName,"Size in GB","FreeSpace in GB","FreeSpace%" |  ConvertTo-Html -head $HeaderTable | out-file $outputfile -append

#NIC Settings(8)
$Step = $Step +1
$Task = "Exporting NIC Config"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

"<H3>NIC Settings</H3>" | Out-File $OutputFile -append
$getnetworks = Get-WmiObject Win32_NetworkAdapterConfiguration  | Where-Object {$_.IPEnabled -match "True"}
$nicarray = @{}
ForEach ($item in $getnetworks){
    $nic =  New-Object -TypeName PSObject -Property @{
    Description = $item.Description
    IPaddress = $item.IPAddress -join ''
    IPSubnet = $item.IPSubnet -join ''
    DefaultIPGateway = $item.DefaultIPGateway -join ''
    DNS_Servers1 =  if($item.DNSServerSearchOrder.count -gt 0){$item.DNSServerSearchOrder[0]}else {""}
    DNS_Servers2 =  if($item.DNSServerSearchOrder.count -gt 1){$item.DNSServerSearchOrder[1]}else {""}

    }
$nicarray += @{$nic.Description= $nic}
}
$nicarray | Select-object Description, IPaddress, DefaultIPGateway, IPSubnet,DNS_Servers 

$nicarray | ConvertTo-Html -head $HeaderTable | out-file $outputfile -append

#End of Script(17)
Write-Host "Completing Script...." -ForegroundColor Green

"<H3>Report produced sucessfully: $Date</H3>" | Out-File $OutputFile -append
"<H2>SECURITY MARKING: DXC PROPRIETRY HANDLE AS <b>RESTRICTED</b></H2>" | Out-File $OutputFile -append
write-host ""
write-host "Server Troubleshooting Checks Complete"
write-host "File saved in $path"
write-host ""

Write-Host "Would you like to open the Server Checks file?" -Foregroundcolor Green
$ReadAnswer = Read-Host " (Y / N) "
    Switch ($ReadAnswer) {
    Y {Invoke-Item $outputfile}
    N {Write-Host "Open $Outputfile when ready.";Exit}
    }

write-host "Server Troubleshooting Checks Completed - :)"
write-host ""
