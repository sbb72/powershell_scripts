﻿#BAe Server Acceptance Checks





#-----------------------Initialise Scripts Varialbles-----------------------------------------------------------------------



$date = get-date
$initialDirectory = "C:\Support\Server Acceptance"
$outfilename = $env:computername + "_Check.json"
$Issuesfile = $env:computername +"_SA_Issues.html"
$htmlOut = (Join-Path $initialDirectory $Issuesfile)
$ErrorActionPreference = "Stop"
$folder = Test-Path $initialDirectory


write-host ""


if ($folder) {
write-host "Folder $initialDirectory already exists"
}
else {
New-Item $initialDirectory -type directory | out-null
write-host "New folder created C:\Support\Server Acceptance"
}


# -----------------------Call Functions ------------------------------------------------------------------------------------ 

$helperfunctions = Get-Content $initialDirectory\Scripts\helper_functions.ps1 -Raw

Invoke-Expression $helperfunctions 

#-----------------------Load the Server Configuration file for referencing checks against------------------------------------- 

Write-Host "Load Server Configuration file"
$JsonContent = Get-FileName ($initialDirectory)
  

$refconfig = Get-Content $JsonContent -Raw| ConvertFrom-Json -erroraction SilentlyContinue


##-----------------------Initialise Objects to save all test data to---------------------------------------------

$SACheck = New-Object psobject -Property @{

Date=$date
Engineer=$env:USERNAME
Servername = ""
Domain=""
Model=""
DomainOU=""
CPUCount=0
RAM=0
Disks=@()
PagefileLoc=""
PagefileSize=""
OS=""
License=""
Network=@()
BindOrder=""
RolesFeatures=@()
}


$SADetails = New-Object psobject -Property @{

Date=$date
Engineer=$env:USERNAME
Servername = ""
Domain=""
Model=""
DomainOU=""
CPUCount=0
RAM=0
PagefileLoc=""
PagefileSize=""
OS=""
License=""
BindOrder=""
RolesFeatures=@()
}



#------------------------Start of Server Checks-------------------------------------------------------------------------------

#Server Details - Servername,Server OS,Domain and OU

$SACheck.Servername = Get-WmiObject win32_computersystem  | Select-Object -Expand Name
$SACheck.Model = Get-WmiObject win32_computersystem  | Select-Object -Expand Model
$SACheck.Domain = Get-WmiObject win32_computersystem  | Select-Object -Expand Domain
$SACheck.OS = (Get-WmiObject -Class Win32_OperatingSystem).caption
$SACheck.DomainOU = (([adsisearcher]"(&(name=$env:computername)(objectclass=computer))").FindAll().path).split(',')[1].trimstart('OU=')


#CPU Count Check - Check the number of CPU's match number requested
$sum = 0
(Get-WmiObject Win32_processor).numberoflogicalprocessors | foreach{$sum+=$_}  
$SACheck.CPUCount = $sum
#RAM Check - Amount of configured RAM

$SACheck.RAM=((Get-WmiObject CIM_PhysicalMemory).capacity /1GB)

#Disk Check - Check Disk configuration is as requested

$getdisks = Get-WmiObject Win32_LogicalDisk

foreach ($item in $getdisks)

{
    $dsk = New-Object psobject -Property @{

    Size = [math]::Round((($item.Size) /1GB))
    DriveType = $item.DriveType
    DeviceID = $item.DeviceID
    VolumeName = $item.Volumename

}

    $SACheck.Disks += $dsk
    #$html_Disk = $dsk 
}


#Network Check - Check Network is confugured as requested

$getnetworks = Get-WmiObject Win32_NetworkAdapterConfiguration  | Where-Object {$_.IPEnabled -match "True"}

foreach ($item in $getnetworks)

{
    $nic = [pscustomobject] @{
    Description = $item.Description
    IPaddress = $item.IPAddress[0]
    DefaultIPGateway = $item.DefaultIPGateway[0]
    DNS_Server_1 = $item.DNSServerSearchOrder[0]
    DNS_Server_2 = $item.DNSServerSearchOrder[1]
    IPSubnet = $item.IPSubnet[0]
    }
$SACheck.Network += $nic
}


#Licencing Check - Check that windows is licenced and has the requested version


$getlicense = Get-CimInstance -ClassName SoftwareLicensingProduct | Where-Object LicenseStatus | Select-Object name,licensestatus

$out = New-Object psobject -Property @{
            Status = [string]::Empty;}

#switch ($getlicense.licensestatus) {
#                   0 {"Unlicensed"}
#                    1 {"Licensed"}
#                    2 {"Out-Of-Box Grace Period"}
#                    3 {"Out-Of-Tolerance Grace Period"}
#                    4 {"Non-Genuine Grace Period"}
#                    5 {"Notification"}
#                    6 {"Extended Grace"}
#                    default {"Unknown value"}
#                    }


    if ($getlicense.licensestatus -eq 1 )

    {$SACheck.License = $getlicense.name
    }



#if ($getservice -ne $null) 

#Roles and Features - Check that any pre-req Windowes Roles and Features have been installed

$GetRolesFeatures = Get-WindowsFeature  | Where-Object {$_. installstate -eq "installed"}   | Select-Object Name 

foreach ($item in $GetRolesFeatures)

{

    $SACheck.RolesFeatures += $item.Name
}


#---------------------------------------------Applications -------------------------------------------------------

$servers = $env:COMPUTERNAME
$array = @()
$array2 = @()

foreach ($item in $servers)
{
    $uninstallkey = "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('Localmachine',"$item")
    $uninskeys = $reg.OpenSubKey($uninstallkey).GetSubKeyNames()
    foreach ($key in $uninskeys)
    {
      $thiskey = $uninstallkey+"\\"+$key
      $thissubkey = $reg.OpenSubKey($thiskey) 
      $obj = New-Object psobject -Property @{
         DisplayName = $thissubkey.GetValue("DisplayName")
         DisplayVersion = $thissubkey.GetValue("DisplayVersion")
     
      }

       if(![string]::IsNullOrEmpty($obj.DisplayName)){$array2 += $obj}
    }

    $uninstallkey64 = "Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
    $reg64 = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('Localmachine',"$item")
    $uninskeys64 = $reg64.OpenSubKey($uninstallkey64).GetSubKeyNames()
    foreach ($key in $uninskeys64)
    {
      $thiskey = $uninstallkey64+"\\"+$key
      $thissubkey = $reg64.OpenSubKey($thiskey) 
      $obj = New-Object psobject -Property @{
         DisplayName = $thissubkey.GetValue("DisplayName")
         DisplayVersion = $thissubkey.GetValue("DisplayVersion")
       
      }
      #$obj
      if(![string]::IsNullOrEmpty($obj.DisplayName)){$array2 += $obj}
    }
  $item
  $apparray=@()
  $apparray = $array2  | where{($_.Displayname -notlike '*Update*') -and ($_.Displayname -notlike '*Service Pack 2*')}
  #$array2 = @()
}

#$SACheck.apps = $array2
#$array2 | ogv

#$array2  | where{$_.displayname -like "Java*"}
#compare-object ($array| select displayname) ($array2| select displayname)

#$array| select displayname | export-csv h:\installedapps85.csv

 
#$getapp = Get-WmiObject win32_product | Select-Object Name,Vendor,Version

#$SACheck.apps = $array2

#-------------------------------- Check for installed Agents  ------------------------------------------------------------

#Anti - Virus


$av=$apparray | Where {$_.displayname -match "McAfee Agent" }
if ($av -eq $null) {
    $AvObj= New-Object psobject -Property @{
    Name="McAfee Virusscan Enterprise"
    State="Not Installed"
    Version="Not Available"
    DatDate="Not Available"
    DatVersion="Not Available"
    }
}
else {
    $AvObj= New-Object psobject -Property @{
        Name=$av.displayname
        State="Installed"
        Version=$av.Displayversion
        DatDate=(Get-ItemProperty -Path HKLM:\Software\Wow6432Node\McAfee\AVengine -Name AVDatDate).AVDatDate
        DatVersion=(Get-ItemProperty -Path HKLM:\Software\Wow6432Node\McAfee\AVengine -Name AVDatversion).AVDatversion 
    }
    }

    
# Vmware Tools


$Vmt = $apparray | Where {$_.displayname -match "VMware Tools"} 
if ($Vmt -eq $null) {
    $VmtObj= New-Object psobject -Property @{
        Name="VMware Tools"
        State="Not Installed"
        Version="Not Available"
    
        }
    }
else {
    $VmtObj= New-Object psobject -Property @{
        Name=$Vmt.displayname
        State="Installed"
        Version=$Vmt.DisplayVersion
        }

    }


# Fire Eye Agent
$FireE = @()

$FireE = $apparray | Where {$_.displayname -match "FireEye Endpoint Agent"} 
if ($FireE -eq $null) {
    $FireEObj= New-Object psobject -Property @{
        Name="VMware Tools"
        State="Not Installed"
        Version="Not Available"
    
        }
    }
else {
    $FireEObj= New-Object psobject -Property @{
        Name=$FireE.displayname
        State="Installed"
        Version=$FireE.DisplayVersion
        }

    }


# Big Fix Client
$BigF = @()

$BigF = $apparray | Where {$_.displayname -match "IBM BigFix Client"} 
if ($BigF -eq $null) {
    $BigFObj= New-Object psobject -Property @{
        Name="VMware Tools"
        State="Not Installed"
        Version="Not Available"
    
        }
    }
else {
    $BigFObj= New-Object psobject -Property @{
        Name=$BigF.displayname
        State="Installed"
        Version=$BigF.DisplayVersion
        }

    }


# RSA Agent
$RSA = @()



$RSA = $apparray | Where {$_.displayname -match "RSA Authentication Agent"} 
if ($RSA -eq $null) {
    $RSAObj= New-Object psobject -Property @{
        Name="VMware Tools"
        State="Not Installed"
        Version="Not Available"
    
        }
    }
else {
    $RSAObj= New-Object psobject -Property @{
        Name=$RSA.displayname
        State="Installed"
        Version=$RSA.DisplayVersion
        }

    }

# Superscript
$Folder2 = 'C:\_Un1ty\superscript'

if ($Folder2 -eq $null) {
    $SuperObj= [pscustomobject] @{
        Name="SuperScript"
        State="Not Installed"
        
    
        }
    }
else {
    $SuperObj= [pscustomobject] @{
        Name="SuperScript"
        State="Installed"
              
      
      }

    }



# Check Services, Eventlog and Device manager for errors and issues

# Check services for any that are set to run Automatically and have stopped


$servarray = @()
$servarray= Get-WmiObject win32_service -Filter "startmode = 'auto' AND state != 'running' " | select name,state,exitcode

#Get-Service | Select-Object -Property Name,Status,Startmode | Where-Object {$_.Status -eq "Stopped" -and $_.Starttype -eq "Automatic"}

$uparray = @()
$uparray = $array2  | where{($_.Displayname -like '*Update*') -or ($_.Displayname -like '*Service Pack 2*')}

# Eventlog Errors

$evarray = @()
$evarray = Get-WinEvent @{logname='application','system';starttime=[datetime]::Today;level=2} | select logname,timecreated,id,message

#Device Manager Errors

$DmArray= @()
$DmArray=Get-WmiObject Win32_PNPEntity | Where-Object {$_.status -notlike 'OK' -and $_.status -notlike $null } | select name,status,ConfigManagerErrorCode


#***********************************************  End of Server checks *********************************************************************************


#------------------------------------------------ Output ServerCheck object to file ---------------------------------------------------------------------

$SACheck  | ConvertTo-Json -depth 200 | Out-File $initialDirectory\$outfilename


#------------------------------------------------- Compare Server Checks with Reference data -----------------------------------------------------------

$difResult=@{}
$saCompareOutput=@{}
$difResult = Compare-Function $SACheck $refconfig -diffCollection $saCompareOutput

#-------------------------------------------------- Output Data to html ---------------------------------------------------------------------------------


$top = @"
<table>
<tr>
<H1>Server Acceptance Report -  $env:COMPUTERNAME</H1></td>
</tr>
</table>
"@
 

$head = @"
<Title>Server Acceptance Report - $env:COMPUTERNAME</Title>
<style>
body { 
	background-color:white;
    font-family:Arial;
    font-size:10pt; 
}
td, th { 
	border:0px solid black; 
	border-collapse:collapse;
	white-space:pre; 
}
th { 
	color:white;
	background-color:black; 
}	
table, tr, td, th { 
	padding: 2px; 
	margin: 0px ;
	white-space:pre; 
}
tr:nth-child(odd) {
	background-color: lightgray
}
table { 
	margin-left:5px; 
	margin-bottom:20px;
}
h2 {
	font-family:Arial;
	color:black;
}
.alert {
 	color: red; 
 }
.footer { 
	color:green; 
	margin-left:10px; 
	font-family:Arial;
	font-size:8pt;
	font-style:italic;
}
.transparent {
	background-color:white;
}
 
</style>
"@




$SADetails.Servername = $SACheck.Servername
$SADetails.Domain +=  $SACheck.Domain
$SADetails.DomainOU +=  $SACheck.DomainOU
$SADetails.Model += $SACheck.Model
$SADetails.OS += $SACheck.OS
$SADetails.License += $SACheck.License
$SADetails.CPUCount += $SACheck.CPUCount
$SADetails.RAM += $SACheck.RAM



$params = @{
	'As'='Table';
	'PreContent'='<h2>Items listed show difference between the requested configuration and the actual server configuration</h2>'
}

$html_Diff = $difResult  | convertto-html @params

$params = @{
	'As'='Table';
	'PreContent'='<h2>Anti Virus</h2>'
}
$html_Av = $AvObj  | convertto-html @params

$params = @{
	'As'='Table';
	'PreContent'='<h2>VMware tools</h2>'
}
$html_Vmt = $VmtObj | convertto-html @params

$params = @{
	'As'='Table';
	'PreContent'='<h2>FireEye Agent</h2>'
}
$html_FireE = $FireEObj | convertto-html @params

$params = @{
	'As'='Table';
	'PreContent'='<h2>Big Fix </h2>'
}
$html_BigF = $BigFObj | convertto-html @params


$params = @{
	'As'='Table';
	'PreContent'='<h2>RSA</h2>'
}
$html_RSA = $RSAObj | convertto-html @params

$params = @{
	'As'='Table';
	'PreContent'='<h2>Services set to run automaticaly not currently running will be listed below. </h2>'
}
$html_service = $servarray | convertto-html @params

$params = @{
	'As'='List';
	'PreContent'='<h2>Device Manager Check - Any issues with any devices will be listed below. </h2>'
}
$html_DevM = $DmArray  | convertto-html @params

$params = @{
	'As'='Table';
	'PreContent'='<h2>Event Viewer Check - Any Errors in the System or Application Event logs will be listed below</h2>'
}
$html_EventV = $evArray  | convertto-html @params

$params = @{
	'As'='List';
	'PreContent'='<h2>Current Server Details</h2>'
}
$html_SADetails = $SADetails  | convertto-html @params


$params = @{
	'As'='Table';
	'PreContent'='<h2>Current Server Disk Details</h2>'
}
$html_Disks = $SACheck.Disks  | convertto-html @params

$params = @{
	'As'='Table';
	'PreContent'='<h2>Current Server Network Details</h2>'
}
$html_Net = $SACheck.Network  | convertto-html @params

$params = @{
	'As'='Table';
	'PreContent'='<h2>SuperScript Check</h2>'
}
$html_SuperS = $SuperObj  | convertto-html @params

$params = @{
	'As'='Table';
	'PreContent'='<h2>Full list of Installed Applications </h2>'
}

$html_apps = $apparray  | convertto-html @params

# Creating Html page for Display

$htmlfragments = @()
$htmlfragments += $top
$htmlfragments += $html_SADetails
#$htmlfragments += $html_Diff
$htmlfragments += $html_Disks
$htmlfragments += $html_Net
$htmlfragments += $html_av
$htmlfragments += $html_Vmt
$htmlfragments += $html_FireE
$htmlfragments += $html_BigF
$htmlfragments += $html_RSA
$htmlfragments += $html_SuperS
$htmlfragments += $html_service
$htmlfragments += $html_DevM
$htmlfragments += $html_EventV
$htmlfragments += $html_apps
#$htmlfragments += $html_RoleFeat


$params = @{
	head = $head
	body = $htmlfragments
}

convertto-html @params | Out-File $htmlOut























