$cwd = (Get-Location).path
import-module  "$cwd\SAChecksModule\SAChecks.psm1" -Force

$SACheck = New-Object psobject -Property @{
    Date=(Get-Date).ToString()
    Engineer=$env:USERNAME
    Servername = ""
    Domain=""
    Model=""
    DomainOU=""
    CPUCount=0
    RAM=0
    Disks=@{}
    PagefileLocation=""
    PagefileSize=""
    OS=""
    License=""
    Network=@{}
}

$SACheck.Servername = (Get-WmiObject win32_computersystem).Name
$SACheck.Model =  (Get-WmiObject win32_computersystem).Model
$SACheck.Domain = (Get-WmiObject win32_computersystem).Domain
$SACheck.OS = (Get-WmiObject -Class Win32_OperatingSystem).caption
$SACheck.DomainOU = Get-DomainOU
$SACheck.CPUCount = Get-CPUCount
$SACheck.RAM= Get-Ram
$SACheck.Disks = Get-Disks
$SACheck.Network = Get-Nics
$SACheck.License = (Get-License  | where {$_.Product -like "Windows*"}).Status
$SACheck.PagefileSize = [math]::Round((Get-WmiObject Win32_PageFileusage).AllocatedBasesize / 1000,1)
$SACheck.PagefileLocation = (Get-WmiObject Win32_PageFileusage).Name.Trimend('pagefile.sys')

try {
    
    $diff = Compare-Function -SurfForm $surfFormResults -ServerConfig $SACheck
}
catch {
    Write-Warning "Error occured in the comparison operation: " + $_.exception.message 
    if($host.name -eq 'ConsoleHost'){
        Write-Host -NoNewLine 'Press any key to continue...'
        $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-null
        }
    
        Exit
}

$apparray = Get-InstalledApps

###### Genereate HTML fragments ######
$htmlArray = @()

if($diff.count -ge 0){
    $htmlArray += '<div class="row alert"><h2>Warning! Surf and server config do not match</h2> </div>' 
    $htmlArray +=  $diff | Select-Object PropertyName, SurfForm, ServerConfig | ConvertTo-HTML -As Table -PreContent '<div class="row"><h2>Surf and Server Config Differences</h2>' -Fragment  -PostContent '</div>' 
}
else{
    $htmlArray +=  $diff | Select-Object PropertyName, SurfForm, ServerConfig | ConvertTo-HTML -As Table -PreContent '<div class="row"><h2>Surf and Server Config Differences</h2>' -Fragment  -PostContent '</div>' 
  
}

$SADetails = $SACheck | select-object Servername,Domain,DomainOU,Model,OS,License,CPUCount,RAM
$htmlArray  += $SADetails | ConvertTo-HTML -As List -PreContent '<div class="row"><div class="container"><h2>Current Server Details</h2>' -Fragment -PostContent '</div>'
$htmlArray  += $SACheck.Disks.Values| Select-Object DeviceID, VolumeName, Size, DriveType |ConvertTo-HTML -As List -PreContent '<div class="container"><h2>Current Server Disks</h2>' -Fragment -PostContent '</div>'
$htmlArray  += $SACheck.Network.values| ConvertTo-HTML -As List -PreContent '<div class="container"> <h2>Current Server Network</h2>' -Fragment -PostContent '</div></div>'

$htmlArray +=  $surfFormResults | select-object Servername,Domain,DomainOU,Model,OS,License,CPUCount,RAM | ConvertTo-HTML -As List -PreContent '<div class="row"><div class="container"><h2>Surf Form</h2>' -Fragment -PostContent '</div>'
$htmlArray +=  $surfFormResults.Disks.values | Select-Object DeviceID, VolumeName, Size, DriveType| ConvertTo-HTML -As List -PreContent '<div class="container"><h2>Surf Form Disks</h2>' -Fragment -PostContent '</div>'
$htmlArray +=  $surfFormResults.Network.values | ConvertTo-HTML -As List -PreContent '<div class="container"><h2>Surf Form Network</h2>' -Fragment -PostContent '</div></div>'

#Get AV Agent ?
$sftCol = @()

$sftCol += Get-InstalledSoftware -AppName "VMware Tools" -AppArray $apparray 
$sftCol += Get-InstalledSoftware -AppName "FireEye Endpoint Agent" -AppArray $apparray 
$sftCol += Get-InstalledSoftware -AppName "IBM BigFix Client" -AppArray $apparray
$sftCol += Get-InstalledSoftware -AppName "RSA Authentication Agent" -AppArray $apparray 
$htmlArray += $sftCol | ConvertTo-HTML -As Table -PreContent '<h2>Check Installed Software</h2>' -Fragment

$htmlArray +=   Get-WmiObject win32_service -Filter "startmode = 'auto' AND state != 'running' " | 
                Select-Object name,state,exitcode | 
                ConvertTo-HTML -As Table -PreContent '<h2>Services</h2>' -Fragment

$htmlArray +=   Get-WinEvent @{logname='application','system';starttime=[datetime]::Today.AddDays(-7);level=2} -ErrorAction SilentlyContinue | 
                Select-Object logname,timecreated,id,message |
                ConvertTo-HTML -As Table -PreContent '<h2>Events</h2>' -Fragment

$htmlArray +=   Get-WmiObject Win32_PNPEntity | Where-Object {$_.status -notlike 'OK' -and $_.status -notlike $null } | 
                Select-Object name,status,ConfigManagerErrorCode | 
                ConvertTo-HTML -As Table -PreContent '<h2>Devices</h2>' -Fragment

#  $htmlArray +=   Get-WindowsFeature  |
#                  Where-Object {$_. installstate -eq "installed"} |
#                  Select-Object Name | 
#                  ConvertTo-HTML -As Table -PreContent '<h2>Roles</h2>'

$htmlArray +=   $apparray|  ConvertTo-HTML -As Table -PreContent '<h2>Apps</h2>' -Fragment

$htmlArray +=   $apparray |  Where-Object{($_.Displayname -like '*Update*') -or ($_.Displayname -like '*Service Pack 2*')} | ConvertTo-HTML -As Table -PreContent '<h2>Patches and Service Packs2</h2>' -Fragment

###### Generate JSON ######
#$SACheck  | ConvertTo-Json -depth 200 | Out-File $initialDirectory\$outfilename


###### Generate HTML Report ######
$head = Get-content .\HtmlReportHeader.html
$params = @{
	head = $head
	body = $htmlArray
}

$htmlOut = Save-FileAs -Title "Save Surf Form As" -FileTypeFilter "html"
if ($htmlOut -contains "Cancel"){
    Write-Error "Save operation has been cancelled"
}
else{
    convertto-html @params | Out-File $htmlOut[1]
}
