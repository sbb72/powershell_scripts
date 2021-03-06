<#
.SYNOPSIS
Find VMWare snapshots on VMs and email results

.PARAMETER
No parameters required

.DESCRIPTION
Loops through all VMs on a number of viservers finding any snapshots. If snapshots are located details are emailed in html format. 
Optionally, local versions of the report are also saved to csv and htm files.
#>

# Adds the powercli cmdlets. This is not needed in Powershell 3.0 and higher
Add-PSSnapin VMware.VimAutomation.Core

# Array of viservers you want to process. Can be a vCenter or ESX / ESXi host
$viServers = 

# Disconnects from any viserver to stop potential false results in ouput

if ($global:DefaultVIServer -ne $null){
		write-host "Disconnecting from current viserver(s)"
		disconnect-viserver * -confirm:$false -force
	}
	else
	{
	write-host "Not connected to any viserver, continuing"
}

# Clears the array object for ouput later on
$snapshotinfo = @()

$strOutFile = ".\Snapshots.htm"

$today = get-date

# Loop through each viserver looking for VMs with snapshots
foreach ($viserver in $viservers) {
	$vms = $null
	$vms = @()	
	Connect-VIServer $viserver
	write-host "Working on:" $viserver
	# Retrieve all VMs on viserver
	$vms = get-vm
	$counter = 0
	
	# Loop through VMs on viserver 
	foreach ($vm in $vms) {
		# Progress counter for interactive execution
		$counter++
		write-progress -activity "Searching VMs for Snapshots" -status "Percent Complete" -PercentComplete (($counter / $vms.length) * 100)
		# Find snapshots on VMs
		$snapshots = $null
		$snapshots = get-snapshot -vm $VM
		
		# If a snapshot is found, loop through each one and gather information. Else, exit at this point and process the next VM
		if ($snapshots -ne $null) {
			write-host "Snapshot found on: "$vm
			foreach ($snapshot in $snapshots) {
				if ((($today) - ($snapshot | select -expand created) | select -expand days)	-ne "0"){
					# Create new object to store snapshot data
					$objSnapshotInfo = New-Object System.Object
					$objSnapshotInfo | add-member -MemberType NoteProperty -Name VM -Value $vm.name
					$objSnapshotInfo | add-member -MemberType NoteProperty -Name Snapshot -Value $snapshot.name
					$objSnapshotInfo | add-member -MemberType NoteProperty -Name Created -Value $snapshot.Created
					$objSnapshotinfo | add-member -membertype Noteproperty -Name "Age (Days)" -Value (($today) - ($snapshot | select -expand created) | select -expand days)
					$objSnapshotInfo | add-member -MemberType NoteProperty -Name Description -Value $snapshot.Description
					$objSnapshotInfo | add-member -MemberType NoteProperty -Name "Size (GB)" -Value ("{0:N2}" -f ($snapshot.SizeMB /1024))
					$objSnapshotInfo | add-member -MemberType NoteProperty -Name IsCurrent -Value $snapshot.IsCurrent
					$objSnapshotInfo | add-member -MemberType NoteProperty -Name Cluster -value ($vm | get-cluster | select -expand Name)
					$objSnapshotInfo | add-member -MemberType NoteProperty -Name vCenter -value $viserver
					$snapshotinfo += $objSnapshotInfo
				}
			}
		}
	}
	
	disconnect-viserver $viserver -confirm:$false -force
}

# HTML CSS for email body and .htm file
$style = @"
<style>
	body {
		color:#333333;
		font-family:Calibri,Tahoma;
		font-size: 9pt;
	}
	h1 {
		text-align:center;
	}
	h2 {
		border-top:1px solid #666666;
	}

	th {
		font-weight:bold;
		color:#eeeeee;
		background-color:#333333;
		border-top:1px solid #666666;
	}
	.odd  { background-color:#ffffff; }
	.even { background-color:#dddddd; }
</style>
"@

# Uncomment these files if you want local versions of the report in csv and htm.
$snapshotinfo | sort-object vCenter,VM | convertto-html -head $style -body $strMail | out-file $strOutFile
$snapshotinfo | export-csv .\snapshots.csv -notype
