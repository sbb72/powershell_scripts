###########################################################################################
# Title:	VMware health check 
# Created: 21-02-2014
# Version: v1	Script Creation
#
###########################################################################################

###########################################################################################
# Configuration:
#
#   Edit the powershell.ps1 file and edit the following variables:
#   $vcserver="localhost"
#   Enter the VC server, if you execute the script on the VC server you can use localhost
#   $filelocation="D:\temp\healthcheck.htm"
#   Specify the path where to store the HTML output
###########################################################################################

####################################
# VMware VirtualCenter server name #
####################################
$vcserver="VC"

##################
# Add VI-toolkit #
##################
Add-PSsnapin VMware.VimAutomation.Core
#Initialize-VIToolkitEnvironment.ps1
connect-VIServer $vcserver

#############
# Variables #
#############
$short_date = get-date -uformat "%Y%m%d"
$filelocation="D:\Reports\ESX_healthcheck\"+$short_date+"_server_healthcheck.htm"
$vcversion = get-view serviceinstance
$snap = get-vm | get-snapshot
$date=get-date

##################
# Mail variables #
##################
#$enablemail="yes"
#$smtpServer = "smtprelay..com" 
#$mailfrom = 
#$mailto = 

#############################
# Add Text to the HTML file #
#############################
ConvertTo-Html –title "URENCO FFTF VMware Health Check " –body "<H1>URENCO FFTF VMware Health script</H1>" -head "<link rel='stylesheet' href='style.css' type='text/css' />" | Out-File $filelocation
ConvertTo-Html –title "URENCO FFTF VMware Health Check " –body "<H4>Date and time</H4>",$date -head "<link rel='stylesheet' href='style.css' type='text/css' />" | Out-File -Append $filelocation

#######################
# VMware ESX hardware #
#######################
Get-VMHost | Get-View | ForEach-Object { $_.Summary.Hardware } | Select-object Vendor, Model, MemorySize, CpuModel, CpuMhz, NumCpuPkgs, NumCpuCores, NumCpuThreads, NumNics, NumHBAs | ConvertTo-Html –title "VMware ESX server Hardware configuration" –body "<H2>VMware ESX server Hardware configuration.</H2>" -head "<link rel='stylesheet' href='style.css' type='text/css' />" | Out-File -Append $filelocation

#######################
# VMware ESX versions #
#######################
get-vmhost | % { $server = $_ |get-view; $server.Config.Product | select { $server.Name }, Version, Build, FullName }| ConvertTo-Html –title "VMware ESX server versions" –body "<H2>VMware ESX server versions and builds.</H2>" -head "<link rel='stylesheet' href='style.css' type='text/css' />" | Out-File -Append $filelocation

######################
# VMware VC version  #
######################
$vcversion.content.about | select Version, Build, FullName | ConvertTo-Html –title "URENCO FFTF VMware VirtualCenter version" –body "<H2>VMware VC version.</H2>" -head "<link rel='stylesheet' href='style.css' type='text/css' />" |Out-File -Append $filelocation

#############
# Snapshots # 
#############
$snap | select vm, name,created,description | ConvertTo-Html –title "Snaphots active" –body "<H2>Snapshots active.</H2>" -head "<link rel='stylesheet' href='style.css' type='text/css' />"| Out-File -Append $filelocation

#########################
# Datastore information #
#########################

function UsedSpace
{
	param($ds)
	[math]::Round(($ds.CapacityMB - $ds.FreeSpaceMB)/1024,2)
}

function FreeSpace
{
	param($ds)
	[math]::Round($ds.FreeSpaceMB/1024,2)
}

function PercFree
{
	param($ds)
	[math]::Round((100 * $ds.FreeSpaceMB / $ds.CapacityMB),0)
}

$Datastores = Get-Datastore
$myCol = @()
ForEach ($Datastore in $Datastores)
{
	$myObj = "" | Select-Object Datastore, UsedGB, FreeGB, PercFree
	$myObj.Datastore = $Datastore.Name
	$myObj.UsedGB = UsedSpace $Datastore
	$myObj.FreeGB = FreeSpace $Datastore
	$myObj.PercFree = PercFree $Datastore
	$myCol += $myObj
}
$myCol | Sort-Object PercFree | ConvertTo-Html –title "Datastore space " –body "<H2>Datastore space available.</H2>" -head "<link rel='stylesheet' href='style.css' type='text/css' />" | Out-File -Append $filelocation

# Invoke-Item $filelocation

##################
# VM information #
##################
$Report = @()
 
get-vm | % {
  $vm = Get-View $_.ID
    $vms = "" | Select-Object VMName, IPAddress, VMState, TotalCPU, TotalMemory, MemoryUsage, ToolsStatus, ToolsVersion
    $vms.VMName = $vm.Name
    $vms.IPAddress = $vm.guest.ipAddress
    $vms.VMState = $vm.summary.runtime.powerState
    $vms.TotalCPU = $vm.summary.config.numcpu
    $vms.TotalMemory = $vm.summary.config.memorysizemb
    $vms.MemoryUsage = $vm.summary.quickStats.guestMemoryUsage
    $vms.ToolsStatus = $vm.guest.toolsstatus
    $vms.ToolsVersion = $vm.config.tools.toolsversion
    $Report += $vms
}
$Report | ConvertTo-Html –title "URENCO FFTF Virtual Machine information" –body "<H2>URENCO FFTF Virtual Machine information.</H2>" -head "<link rel='stylesheet' href='style.css' type='text/css' />" | Out-File -Append $filelocation

######################
# E-mail HTML output #
######################
if ($enablemail -match "yes") 
{ 
$msg = new-object Net.Mail.MailMessage
$att = new-object Net.Mail.Attachment($filelocation)
$smtp = new-object Net.Mail.SmtpClient($smtpServer) 
$msg.From = $mailfrom
$msg.To.Add($mailto) 
$msg.Subject = “URENCO FFTF VMware Healthscript”
$msg.Body = “URENCO FFTF VMware healthscript”
$msg.Attachments.Add($att) 
$smtp.Send($msg)
}

##############################
# Disconnect session from VC #
##############################

disconnect-viserver -confirm:$false

##########################
# End Of Healthcheck.ps1 #
##########################
