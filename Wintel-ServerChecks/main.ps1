$cwd = (Get-Location).path
import-module  "$cwd\SAChecksModule\SAChecks.psm1" -Force
$date = Get-Date -f "HH:mm dd-MM-yyyy"
$HeaderTable = @"
<style>
TABLE {font: 12pt Arial; border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;text-align:left;}
TH {font: 12pt Arial; border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;text-align:left;}
TD {font: 12pt Arial; border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@



$SACheck = New-Object psobject -Property @{
    Date             = (Get-Date).ToString()
    Engineer         = $env:USERNAME
    Servername       = ""
    Domain           = ""
    Make             = ""
    Model            = ""
    DomainOU         = ""
    CPUCount         = 0
    RAM              = 0
    Disks            = @{ }
    PagefileLocation = ""
    PagefileSize     = ""
    OS               = ""
    ServicePack      = ""
    License          = ""
    Network          = @{ }
}

$SACheck.Servername = (Get-WmiObject win32_computersystem).Name
$SACheck.Make = (Get-WmiObject win32_computersystem).Make
$SACheck.Model = (Get-WmiObject win32_computersystem).Model
$SACheck.Domain = (Get-WmiObject win32_computersystem).Domain
$SACheck.OS = (Get-WmiObject -Class Win32_OperatingSystem).caption
#$SACheck.ServicePack = (Get-WmiObject win32_operatingsystem).servicepackmajorversion
#$SACheck.DomainOU = Get-DomainOU
$SACheck.CPUCount = Get-CPUCount
$SACheck.RAM = Get-Ram
$SACheck.Disks = Get-Disks
$SACheck.Network = Get-Nics
$SACheck.License = (Get-License | where { $_.Product -like "Windows*" }).Status
$SACheck.PagefileSize = [math]::Round((Get-WmiObject Win32_PageFileusage).AllocatedBasesize / 1000, 1)
$SACheck.PagefileLocation = (Get-WmiObject Win32_PageFileusage).Name.Trimend('pagefile.sys')



###### Genereate HTML fragments ######
$htmlArray = @()
$htmlArray += "<td><H1>$hostname - Server Troubleshooting Checks </H1>" 
$htmlArray += "<H4>Report produced on: $Date by: $env:USERNAME</H4></td></table>" 


$SADetails = $SACheck | select-object Servername, Domain, DomainOU, Model, OS, License, CPUCount, RAM | ConvertTo-HTML -As Table -PreContent '<div class="container"> <h2>Server Details</h2>' -Fragment -PostContent -head $HeaderTable'</div></div>'
$htmlArray += $SADetails | ConvertTo-HTML -As List -PreContent '<div class="row"><div class="container"><h2>Current Server Details</h2>' -Fragment -PostContent '</div>' -head $HeaderTable
$htmlArray += $SACheck.Disks.Values | Select-Object DeviceID, Size, VolumeName, "% FreeSpace" | ConvertTo-HTML -As Table -PreContent '<div class="container"><h2>Current Server Disks</h2>' -Fragment -PostContent '</div>'
$htmlArray += $SACheck.Network.values | ConvertTo-HTML -As Table -PreContent '<div class="container"> <h2>Current Server Network</h2>' -Fragment -PostContent '</div></div>'

$htmlArray += Get-InstalledApps | Sort-Object DisplayName | ConvertTo-HTML -PreContent '<div class="container"> <h2>List Of Applications</h2>' -Fragment -PostContent '</div></div>'

$sftCol = @()
$sftCol += Get-InstalledSoftware -AppName "VMware Tools" -AppArray $apparray 
$sftCol += Get-InstalledSoftware -AppName "FireEye Endpoint Agent" -AppArray $apparray 
$sftCol += Get-InstalledSoftware -AppName "IBM BigFix Client" -AppArray $apparray
$sftCol += Get-InstalledSoftware -AppName "RSA Authentication Agent" -AppArray $apparray 
$htmlArray += $sftCol | ConvertTo-HTML -As Table -PreContent '<h2>Check Installed Software</h2>' -Fragment

$htmlArray += Get-WmiObject win32_service | Select-Object Displayname, State, StartMode | Sort-Object Displayname | ConvertTo-HTML -As Table -PreContent '<h2>Services</h2>' -Fragment

$htmlArray += Get-HotFix | Select-Object HotFixID, InstalledOn, InstalledBy, Description | Sort-Object InstalledOn | ConvertTo-HTML -As Table -PreContent '<h2>Hotfixes</h2>' -Fragment

$htmlArray += Get-WinEvent @{logname = 'application', 'system'; starttime = [datetime]::Today.AddDays(-7); level = 2 } -ErrorAction SilentlyContinue | 
Select-Object logname, timecreated, id, message |
ConvertTo-HTML -As Table -PreContent '<h2>Events</h2>' -Fragment
<#
$htmlArray +=   Get-WmiObject Win32_PNPEntity | Where-Object {$_.status -notlike 'OK' -and $_.status -notlike $null } | 
                Select-Object name,status,ConfigManagerErrorCode | 
                ConvertTo-HTML -As Table -PreContent '<h2>Devices</h2>' -Fragment
<#
 $htmlArray +=   Get-WindowsFeature  |
                  Where-Object {$_. installstate -eq "installed"} |
                  Select-Object Name | 
                  ConvertTo-HTML -As Table -PreContent '<h2>Roles</h2>'
#>

#$htmlArray += $apparray | ConvertTo-HTML -As Table -PreContent '<h2>Apps</h2>' -Fragment

$htmlArray += $apparray | Where-Object { ($_.Displayname -like '*Update*') -or ($_.Displayname -like '*Service Pack 2*') } | ConvertTo-HTML -As Table -PreContent '<h2>Patches and Service Packs2</h2>' -Fragment

$htmlArray += "<H3>Report produced sucessfully: $Date</H3>" 
$htmlArray += "<H2>SECURITY MARKING: DXC PROPRIETRY HANDLE AS <b>RESTRICTED</b></H2>"

$htmlArray | Out-File c:\temp\Test1.html