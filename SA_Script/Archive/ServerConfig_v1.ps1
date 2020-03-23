#Server Configuration


#Initialise Scripts

$hostname = $env:COMPUTERNAME

$date = get-date
$path = "C:\Support\Server Acceptance"
$ErrorActionPreference = "Stop"
$folder = Test-Path $path
write-host ""


if ($folder) {
write-host "Folder $path already exists"
}
else {
New-Item $path -type directory | out-null
write-host "New folder created C:\Support\Server Acceptance"
}

$ServerConfig = New-Object psobject -Property @{

Date=$date
Engineer=$env:USERNAME
Servername = $env:computername
Model=""
Domain=""
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

#Start of Main Script


#Enter data in to created object

$ServerConfig.Engineer=$env:USERNAME
$ServerConfig.Date=$date

#Server Physical/Virtual

$mod = Read-Host -Prompt "Please Select -- 1:- Physical Server. 2:- Vitual Server "

switch ($mod) {
    1 { $ServerConfig.Model = "Physical Server"}
    2 { $ServerConfig.Model = "VMware Virtual Platform"}
    
    default {$ServerConfig.Model = ""}
    }

#Number CPU's

$ServerConfig.CPUCount = Read-Host -prompt "Number of CPU's Required:"

#Amount of RAM

$ServerConfig.RAM = Read-Host -prompt "Amount of RAM Required:"

#Version of Windows Server

$os = Read-Host -Prompt "Please select which Windows OS is required. 1 - Windows Server 2012 R2 2 - Windows Server 2016 "

switch ($os) {
1 { $ServerConfig.OS = "Microsoft Windows Server 2012 R2 Standard"}
2 { $ServerConfig.OS = "Windows(R) Server 2016 Standard"}

default {$ServerConfig.OS = ""}
}


$lv = Read-Host -Prompt "Please select licence version required. 1 - Standard Edition 2 - Datacenter Edition"

switch ($lv) {
1 { $ServerConfig.License = "Windows(R), ServerStandard edition"}
2 { $ServerConfig.License = "Windows(R), ServerDatacenter edition"}

default {$ServerConfig.License = ""}
}


$ServerConfig.Domain = Read-Host -Prompt "Please enter the Domain that the server needs to be added to"
$ServerConfig.DomainOU = Read-Host -Prompt "If known please add any OU's that the Server needs to be in"

#Drives

# $serverConfig.Disks = @{}
$numberofDisks = Read-host "Enter the number of disks"

for ($i = 0; $i -lt $numberofDisks; $i++)
{ 
    $dsk = New-Object psobject -Property @{

    DeviceID = Read-host "Enter the disk $i driver letter in the following format C:"
    VolumeName = Read-Host "Enter Volume Name :"
    Size = Read-host "Enter Disk Size in GB"
    DriveType = Read-host "Enter Drive type (3 = Local dirver : 4= Network drive)"
    }

    $serverConfig.Disks += $dsk
}
#Pagefile

$page = Read-Host -Prompt "Default Pagefile resides on the C:\ and is 1.5 x requested RAM. Do you require a none standard Pagefile. Y/N " 

if ($page -eq "Y"){ 

$ServerConfig.PagefileLoc = Read-Host -Prompt "Location of Pagefile"
$ServerConfig.PagefileSize = Read-Host -Prompt "Size of required Pagefile"}





#Network

$numberofNICS = Read-host "Enter the number of Network Connections"

for ($i = 0; $i -lt $numberofNICS; $i++)
{ 
    $nic = New-Object psobject -Property @{

    Label = Read-host "Enter the network Connection for NIC $i e.g. Data,Backup"
    IPaddress = Read-host "Enter Required IP address"
    IPSubnet = Read-Host "Enter Subnet address"
    DefaultIPGateway = Read-Host "Enter Gateway IP address"
    DNSServerSearchOrder1 = Read-Host "Enter Primary DNS address"
    DNSServerSearchOrder2 = Read-Host "Enter Secondary DNS address"
    }

    $serverConfig.Network += $nic 
}

$ServerConfig.BindOrder = Read-Host -prompt "Do you have a specific NIC Bind Order. Enter bind order required else enter 0 "

#Roles and Features

#$RolesFeat = Read-host "Enter number of Roles/Features to be installed"


#for ($i = 0; $i -lt $RolesFeat; $i++)
#{ 
#    $feat = New-Object psobject -Property @{
#
#    RoleFeat = Read-host "Enter $i Roles or Features to be installed"
# }

#    $serverConfig.RolesFeatures += $feat
#}

do {

    do {
    Write-Host "Select the following Roles and Features that you need installing"
    Write-Host "1 - Web Server ISS,2 - .Net Framework 3.5,3 - .Net Framework 4.5,4 - Group Policy Management,`
    5 - Active Directory Domain Services,6 - DNS Server,7 - DHCP Server,8 - SNMP,9 - Telnet,0 - Exit"
    
    $answer = Read-Host "Select - Number(s)"
    
    $ok = $answer -match '[1234567890]+$'
    if ( -not $ok) {Write-Host "Invalid Selection"
                    }
    } until ($ok)
    
    switch -Regex ( $answer ) {
    "1" {$ServerConfig.RolesFeatures += "Web-Server"}
    "2" {$ServerConfig.RolesFeatures += "NET-Framework-Features"}
    "3" {$ServerConfig.RolesFeatures += "NET-Framework-45-Features"}
    "4" {$ServerConfig.RolesFeatures += "GPMC"}
    "5" {$ServerConfig.RolesFeatures += "AD-Domain-Services"}
    "6" {$ServerConfig.RolesFeatures += "DNS-Server"}
    "7" {$ServerConfig.RolesFeatures += "DHCP-Server"}
    "8" {$ServerConfig.RolesFeatures += "SNMP-Service"}
    "9" {$SAConfig.RolesFeatures += "Telnet-Client"}
    }
    
    } until ( $answer -match "0")

# Write Data object out to file

$serverConfig  | ConvertTo-Json -depth 100 | Out-File $path\$hostname.json

