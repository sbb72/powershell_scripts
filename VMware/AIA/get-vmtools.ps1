# Adds the powercli cmdlets
Add-PSSnapin VMware.VimAutomation.Core -erroraction SilentlyContinue

# Array of viservers you want to process. Can be a vCenter or ESX / ESXi host
$viServers = 


$output = @()
$strOutFile = "VMToolStatus.csv"
$today = get-date


# Disconnects from any viserver to stop potential false results in ouput

if ($global:DefaultVIServer -ne $null){
		write-host "Disconnecting from current viserver(s)"
		disconnect-viserver * -confirm:$false
	}
	else
	{
	write-host "Not connected to any viserver, continuing"
}

# Great objects to capture Tool details
$supress = New-VIProperty -Name ToolsVersion -ObjectType VirtualMachine -ValueFromExtensionProperty 'Config.tools.ToolsVersion' 
$supress = New-VIProperty -Name ToolsVersionStatus -ObjectType VirtualMachine -ValueFromExtensionProperty 'Guest.ToolsVersionStatus'


foreach ($viServer in $viservers) {
    write-host "Connecting to $viserver"
    connect-viserver $viServer
    $colVMs = $null
    $colVMs = get-vm
    $counter = 0    

    foreach ($objVM in $colVMs) {
	$counter++
	write-progress -activity "Processing VMs" -status "Percent Complete" -PercentComplete (($counter / $colVms.length) * 100)
	$VMView = $null
        $VMView = $objVM
	    
        $objResult = [PSCustomObject] @{
		        "VM Name" 									= $objVm.Name
		        "Version"						= $VMView.Version
		        "Tools Version" 							    = $vmview.ToolsVersion
		        "Tools Version Status"					    = $VMview.ToolsVersionStatus
		        "vCenter"					    = $viServer
	}

        $output += $objResult
	$objResult
    
    }
    disconnect-viserver $viserver -confirm:$false -force
}
$output
$output | export-csv $strOutFile -notype
