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

#Format html output file
$a = "<style>"
$a = $a + "BODY{background-color:white;}"
$a = $a + "H1{font: 22pt Arial}"
$a = $a + "H2{font: 18pt Arial; color:#000000; font: 12pt Arial;}"
$a = $a + "H3{font: 12pt Arial; color: grey; font-weight: bold;}"
$a = $a + "H4{font: 12pt Arial; color: grey; font-weight}"
$a = $a + "TABLE{font: 12pt Arial; margin: 05px; border-width: 2px; border-collapse: collapse; text-align:left;}"
$a = $a + "TH{color: #000000; padding: 10px 8px; border-bottom: 2px solid #000000;}"
$a = $a + "TD{border-bottom: 1px solid #000000; color:#000000; padding: 6px 8px; font-weight:bold;}"
$a = $a + "</style>"

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
$ss = Get-WmiObject win32_computersystem | Select-Object Name,Domain,Model 
foreach ($soitem in $ss){
    $systemobject = New-Object –TypeName PSObject
    $systemobject | Add-Member –MemberType NoteProperty –Name "OS Name" –Value $soitem.Name
    $systemobject | Add-Member –MemberType NoteProperty –Name "Domain" –Value $soitem.Domain
    $systemobject | Add-Member –MemberType NoteProperty –Name "Model" –Value $soitem.Model
}
$systemobject | ConvertTo-Html -head $HeaderTable | out-file $outputfile -append

#OS Section(2)
$Step = $Step +1
$Task = "OS Information"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

"<H3>OS Section</H3>" | Out-File $OutputFile -append
$os = Get-WmiObject win32_operatingsystem | Select-Object caption, servicepackmajorversion
foreach ($ositem in $os){
    $osobject = New-Object  -TypeName PSObject
    $osobject | Add-Member -MemberType NoteProperty -Name "OS" -Value $ositem.caption
    $osobject | Add-Member -MemberType NoteProperty -Name "Service Pack" -Value $ositem.servicepackmajorversion
}
$OSobject | ConvertTo-Html -head $HeaderTable | out-file $outputfile -append

#UpTime (3)
$Step = $Step +1
$Task = "Checking Server UpTime"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

"<H3>UpTime</H3>" | Out-File $OutputFile -append
$wmi = Get-WmiObject Win32_OperatingSystem
$LBTime = $wmi.ConvertToDateTime($wmi.Lastbootuptime) 
[TimeSpan]$uptime = New-TimeSpan $LBTime $(get-date)
$UpTimeObject = New-Object -TypeName PSObject
$UpTimeTotal = "Server has been up " + $uptime.Days +" Days and "+ $uptime.Hours + " Hours" 
$UpTimeObject | add-member -MemberType NoteProperty -Name "Last Reboot Date" -value $LBTime
$UpTimeObject | add-member -MemberType NoteProperty -Name "Server UpTime" -value $UpTimeTotal
[array]$uptimeout += $UpTimeObject 
$UpTimeObject | ConvertTo-Html -head $HeaderTable | out-file $outputfile -append

#Reboot Check(4)
$Step = $Step +1
$Task = "Reboot Check"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

$outreboot = @()
"<H3>Pending Reboot</H3>" | Out-File $OutputFile -append
$RebootRequired = $NULL
if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) {$RebootRequired = "YES"}
    ELSE {if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) {$RebootRequired = "YES"}
        ELSE {if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) {$RebootRequired = "YES"}
        }
    }
If ($RebootRequired -eq "YES") {
$RebootRequired = "YES"
}
ELSE{
$RebootRequired = "No"
}
$reboot = New-Object  -TypeName PSObject
$reboot | add-member -MemberType NoteProperty -Name "Server" -value $hostname
$reboot | add-member -MemberType NoteProperty -Name "Reboot Pending" -value $RebootRequired
$outreboot += $reboot
$outreboot | ConvertTo-Html -head $HeaderTable | out-file $outputfile -append
$outreboot = $NULL

#Memory RAM (5)
$Step = $Step +1
$Task = "Checking Memory"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

"<H3>Memory</H3>" | Out-File $OutputFile -append
$outmem = @()
$mem = Get-WmiObject -Class win32_operatingsystem | Select TotalVisibleMemorySize
$memsize = [math]::truncate($mem.TotalVisibleMemorySize /1KB)
$memoryobject = New-Object -TypeName PSObject
$memoryobject | add-member -MemberType NoteProperty -Name "Total Visible Memory" -value "Total Visible Memory"
$memoryobject | add-member -MemberType NoteProperty -Name "RAM Size MB" -value $memsize
$outmem += $memoryobject 
$outmem | ConvertTo-Html -head $HeaderTable | out-file $outputfile -append

#CPU (6)
$Step = $Step +1
$Task = "Exporting CPUs"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

$outcpu = @()
"<H3>CPU</H3>" | Out-File $OutputFile -append
Get-WmiObject Win32_processor | select-object name, numberoflogicalprocessors, currentclockspeed | foreach {
    $cpuobject = New-Object -TypeName PSObject
    $cpuobject | Add-Member -MemberType NoteProperty -Name "Name" -value $($_.name)
    $cpuobject | Add-Member -MemberType NoteProperty -Name "Number of CPUs" -value $($_.numberoflogicalprocessors)
    $outcpu += $cpuobject 
    Clear-Variable cpuobject
}
$outcpu | ConvertTo-Html -head $HeaderTable | out-file $outputfile -append

#Processes (7)
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

#Memory Usage (8)
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

#Drives(9)
$Step = $Step +1
$Task = "Disk Space Check"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

$out | ConvertTo-Html -head $HeaderTable | out-file $outputfile -append
"<H3>Local Disks</H3>" | Out-File $OutputFile -append
$drivesout = @()
$disks = Get-WmiObject win32_logicaldisk | Where-Object {$_.DriveType -eq "3"}
$disks | foreach {
    $driveobject = New-Object -TypeName PSObject
    $driveletter = $_.deviceID
    $size = [System.Math]::Round($_.Size/1GB)
    $freespace = [System.Math]::Round($_.FreeSpace/1GB)
    $driveobject | Add-Member -MemberType NoteProperty -Name "Drive" -value $driveletter
    $driveobject | Add-Member -MemberType NoteProperty -Name "Size GB" -value $size
    $driveobject | Add-Member -MemberType NoteProperty -Name "Freespace GB" -value $freespace
    $PreFree = [Math]::Round(($freespace /1MB) / ($Size / 1MB) * 100)
    $driveobject | Add-Member -MemberType NoteProperty -Name "% Free" -value $PreFree
    $drivesout += $driveobject
    clear-variable driveletter,size,freespace,driveobject
}
$drivesout | ConvertTo-Html -head $HeaderTable | out-file $outputfile -append

#NIC Settings(10)
$Step = $Step +1
$Task = "Exporting NIC Config"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

"<H3>NIC Settings</H3>" | Out-File $OutputFile -append
$nicout = @()
$NICs = Get-wmiobject -class win32_networkadapter | Where-Object {$_.adaptertype -ne $null} | foreach {
    $nicobject = New-Object -TypeName PSObject
    $nicobject | Add-Member -MemberType NoteProperty -Name "Name" -value $($_.netconnectionid)
    $nicobject | Add-Member -MemberType NoteProperty -Name "Speed" -value $($_.Speed)
    $index = $_.index
    
    $IPs=Get-wmiobject -Class win32_NetworkAdapterConfiguration | where {$_.IPEnabled -eq "True" -and $_.index -eq $index}
    $IPs | foreach { 
		$nicobject | Add-Member -MemberType NoteProperty -Name "IP Address" -value $($_.Ipaddress)
		$nicobject | Add-Member -MemberType NoteProperty -Name "Subnet Mask" -value $($_.IPsubnet)
		$nicobject | Add-Member -MemberType NoteProperty -Name "Gateway" -value $($_.DefaultIPgateway)
        $DNSIPs =  $_.DNSServerSearchOrder -join ' | '
		$nicobject | Add-Member -MemberType NoteProperty -Name "DNS Servers" -value $DNSIPs
		}
		$nicout += $nicobject
      clear-variable IPs,index,nicobject     
} 
$nicout | ConvertTo-Html -head $HeaderTable | out-file $outputfile -append

#VMware Tools(11)
$Step = $Step +1
$Task = "VMTools Check"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

"<H3>VMware Tools</H3>" | Out-File $OutputFile -append
$VMTools = get-WmiObject Win32_Service | Where-object {$_.displayname -eq "VMware Tools"} 
$vmtoolsout = @()
$vmtoolsobject = New-Object -TypeName PSObject
if ($VMTools) {
    $vmtoolsobject | Add-Member -MemberType NoteProperty -Name "Name" -value "VMware Tools"
    $vmtoolsobject | Add-Member -MemberType NoteProperty -Name "State" -value $($VMTools.State)
    $vmtoolsobject | Add-Member -MemberType NoteProperty -Name "Status" -value $($VMTools.Status)
    $vmtoolsobject | Add-Member -MemberType NoteProperty -Name "Start Mode" -value $($VMTools.StartMode)
    }
ELSE {
    $vmtoolsobject | Add-Member -MemberType NoteProperty -Name "Name" -value "VMware Tools"
    $vmtoolsobject | Add-Member -MemberType NoteProperty -Name "State" -value "Not Installed"
 } 
$vmtoolsout += $vmtoolsobject
$vmtoolsobject | ConvertTo-Html -head $HeaderTable | out-file $outputfile -append

#Services(12)
$Step = $Step +1
$Task = "Checking Services"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

$outservices = @()
"<H3>Services</H3>" | Out-File $OutputFile -append
$ServicesList = get-WmiObject Win32_Service | Sort-Object $ServicesList.DisplayName -Descending
    $ServicesList | foreach {
        $ServicesListObject = New-Object -Typename PSObject
        $ServicesListObject | Add-Member -MemberType NoteProperty -Name "Service Name" -value $($_.DisplayName)
        $ServicesListObject | Add-Member -MemberType NoteProperty -Name "State" -value $($_.State)
        $ServicesListObject | Add-Member -MemberType NoteProperty -Name "Start Mode" -value $($_.StartMode)
        $outservices += $ServicesListObject
}
$outservices | ConvertTo-Html -head $HeaderTable | Out-File $outputfile -append
Clear-Variable -Name outservices

#Hotfixes (13)
$Step = $Step +1
$Task = "Exporting HotFixes"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

"<H3>Installed HotFixes</H3>" | Out-File $OutputFile -append
$outhotfixes = @()
$Hotfixes = Get-Hotfix
$Hotfixes | foreach {
     $Hotfixesobject = New-Object -TypeName PSObject 
     $Hotfixesobject | Add-Member -MemberType NoteProperty -Name "Source" -value $($_.Source)
     $Hotfixesobject | Add-Member -MemberType NoteProperty -Name "Description" -value $($_.Description)
     $Hotfixesobject | Add-Member -MemberType NoteProperty -Name "HotFixID" -value $($_.HotFixID)
     $Hotfixesobject | Add-Member -MemberType NoteProperty -Name "InstalledBy" -value $($_.InstalledBy)
     $Hotfixesobject | Add-Member -MemberType NoteProperty -Name "InstalledOn" -value $($_.InstalledOn)
     $outhotfixes += $Hotfixesobject     
}
$outhotfixes | ConvertTo-Html -head $HeaderTable | Out-File $outputfile -append

#Device Manager (14)
$Step = $Step +1
$Task = "Device Manager Errors"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

"<H3>Device Manager: Failed Devices</H3>" | Out-File $OutputFile -append
$outdevice = @()
$DeviceErrors = Get-WmiObject Win32_PNPEntity | where {$_.Status -eq "Error"}
$DeviceErrors | foreach {
     $DeviceErrorsobject = New-Object -TypeName PSObject 
     $DeviceErrorsobject | Add-Member -MemberType NoteProperty -Name "Name" -value $($_.name)
     $DeviceErrorsobject | Add-Member -MemberType NoteProperty -Name "__PATH" -value $($_.__PATH)
     $DeviceErrorsobject | Add-Member -MemberType NoteProperty -Name "Status" -value $($_.Status)
     $outdevice += $DeviceErrorsobject   
}
$outdevice | ConvertTo-Html -head $HeaderTable | Out-File $outputfile -append

#Event Viewer App(15)
$Step = $Step +1
$Task = "Export Event Viewer Errors Application Log"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

"<H3>Event Log: Application Log Errors (Last 48 Hours)</H3>" | Out-File $OutputFile -append
$outapp = @()
$AppLogErrors = get-eventlog -logname application -after (get-date).adddays(-2) -entrytype error
$AppLogErrors | foreach {
     $AppLogErrorsobject = New-Object -TypeName PSObject 
     $AppLogErrorsobject | Add-Member -MemberType NoteProperty -Name "TimeGenerated" -value ($_.TimeGenerated)
     $AppLogErrorsobject | Add-Member -MemberType NoteProperty -Name "EntryType" -value $($_.EntryType)
     $AppLogErrorsobject | Add-Member -MemberType NoteProperty -Name "Source" -value $($_.Source)
     $AppLogErrorsobject | Add-Member -MemberType NoteProperty -Name "InstanceID" -value $($_.InstanceID)
     $AppLogErrorsobject | Add-Member -MemberType NoteProperty -Name "Message" -value $($_.Message)
     $outapp += $AppLogErrorsobject   
}
$outapp | ConvertTo-Html -head $HeaderTable | Out-File $outputfile -append

#Event Viewer System(16)
$Step = $Step +1
$Task = "Export Event Viewer Errors System Log"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

"<H3>Event Log: System Log Errors (Last 48 Hours)</H3>" | Out-File $OutputFile -append
$outsys = @()
$SysLogErrors = get-eventlog -logname System -after (get-date).adddays(-2) -entrytype error
$SysLogErrors | foreach {
     $SysLogErrorsobject = New-Object -TypeName PSObject 
     $SysLogErrorsobject | Add-Member -MemberType NoteProperty -Name "TimeGenerated" -value $($_.TimeGenerated)
     $SysLogErrorsobject | Add-Member -MemberType NoteProperty -Name "EntryType" -value $($_.EntryType)
     $SysLogErrorsobject | Add-Member -MemberType NoteProperty -Name "Source" -value $($_.Source)
     $SysLogErrorsobject | Add-Member -MemberType NoteProperty -Name "InstanceID" -value $($_.InstanceID)
     $SysLogErrorsobject | Add-Member -MemberType NoteProperty -Name "Message" -value $($_.Message)
     $outsys += $SysLogErrorsobject 
}
$outsys | ConvertTo-Html -head $HeaderTable | Out-File $outputfile -append

#End of Script(17)
$Step = $Step +1
$Task = "End of Script"
Write-Progress -Id $Id -Activity $Activity -Status "Step $Step running out of $TotalSteps" -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
Write-Host "Running '$Task', Step $Step running out of $TotalSteps..." -ForegroundColor Green

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
