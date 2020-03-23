#Variables
$date = Get-Date -f "HH:mm dd-MM-yyyy"
$strLogDate = Get-Date -f ddMMyyyy
$hostname = $env:COMPUTERNAME
$path = "C:\Support\Server_Acceptance"
$outputfile = $path + "\" + $strLogDate + "_" + $hostname + ".html"

$cwd = (Get-Location).path
import-module  "$cwd\SA_Script\SAChecksModule\SAChecks.psm1" -Force

#Add Header
$htmlArray += @(
    "<td><H1>$hostname - Server Acceptance Check</H1>"
    "<H4>Report produced on: $Date by: $env:USERNAME</H4></td></table>" 
)



#Check Folder \ File exists
if (Test-Path $path -EA SilentlyContinue) {
}
else {
    New-Item $path -type directory | out-null
    write-host "New folder created $Path" -ForegroundColor Green
}


$SACheck = New-Object psobject -Property @{
    Date             = (Get-Date).ToString()
    Servername       = ""
    Domain           = ""
    Manufacturer     = ""
    Model            = ""
    DomainOU         = ""
    CPUCount         = 0
    RAM              = 0
    PagefileLocation = ""
    PagefileSize     = ""
    OS               = ""
    License          = ""
}

$SACheck.Servername = (Get-WmiObject win32_computersystem).Name
$SACheck.manufacturer = (Get-WmiObject win32_computersystem).manufacturer
$SACheck.Model = (Get-WmiObject win32_computersystem).Model
$SACheck.Domain = (Get-WmiObject win32_computersystem).Domain
$SACheck.OS = (Get-WmiObject -Class Win32_OperatingSystem).caption
#$SACheck.DomainOU = Get-DomainOU
$SACheck.CPUCount = Get-CPUCount
$SACheck.RAM = Get-Ram
$SACheck.PagefileLocation = (Get-WmiObject Win32_PageFileusage).Name
$SACheck.License = (Get-License | where { $_.Product -like "Windows*" }).Status
$SACheck.PagefileSize = [math]::Round((Get-WmiObject Win32_PageFileusage).AllocatedBasesize / 1000, 1)


#Export Computer Info
$SADetails = $SACheck | select-object Servername, Domain, DomainOU, Manufacturer, Model, OS, PagefileSize, PagefileLocation, RAM, CPUCount, License
$htmlArray += $SADetails | ConvertTo-HTML -As List -PreContent '<div class="row"><div class="container"><h2>Current Server Details</h2>' -Fragment -PostContent '</div>'

#Export NICs Info
$arrayNics = Get-Nics | Select-object Description, IPaddress, DefaultIPGateway, IPSubnet, DNS_Servers
$htmlArray += $arrayNics | ConvertTo-HTML -As Table -PreContent '<div class="row"><div class="container"><h2>NIC Info</h2>' -Fragment -PostContent '</div>'

#Export Services Info
$GetServices = Get-Services
$htmlArray += $GetServices | ConvertTo-HTML -As Table -PreContent '<div class="row"><div class="container"><h2>List of Services</h2>' -Fragment -PostContent '</div>'

#Export Disk Info
$arrayDisks = Get-Disks | Select-Object Drive, "Volume Name", "Size GB", "Free Space GB", "Precent Free"
$htmlArray += $arrayDisks | ConvertTo-HTML -As Table -PreContent '<div class="row"><div class="container"><h2>Local Disks</h2>' -Fragment -PostContent '</div>'

#Export Installed Software
$arrayApps = Get-InstalledApps | Sort-Object Displayname | Select-Object Displayname, displayversion, Install_Date, publisher
$htmlArray += $arrayApps | ConvertTo-HTML -As Table -PreContent '<div class="row"><div class="container"><h2>Installed Software</h2>' -Fragment -PostContent '</div>'

#Export Installed Patches
$arrayPatches = Get-InstalledUpdates
$htmlArray += $arrayPatches | ConvertTo-HTML -As Table -PreContent '<div class="row"><div class="container"><h2>Installed Patches</h2>' -Fragment -PostContent '</div>'

$htmlArray | Out-File $OutputFile

$htmlArray = $null

C:\Support\Server_Acceptance\28012020_SCOTTPC.html
