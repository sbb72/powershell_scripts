<#
.SYNOPSIS
Find VMs with memory limits configured, compare limit to allocation and report on Ballooning and Swapping

.PARAMETER
No parameters required

.DESCRIPTION
Loops through all VMs on a number of viservers finding any VMs that have a configured memory limit. This value is compared to the 
memory allocation of the server and a flag set if the limit is lower than the allocation. Ballooning and Swapping statistics
are also gathered for each VM. 

The results can be printed to the powershell console, exported in a file or emailed.

The driver for this activity comes from the following VMWare KB article http://kb.vmware.com/kb/1003470 "Balloon driver retains 
hold on memory causing virtual machine guest operating system performance issues "
#>

# Adds the powercli cmdlets
Add-PSSnapin VMware.VimAutomation.Core -erroraction SilentlyContinue

# Array of viservers you want to process. Can be a vCenter or ESX / ESXi host
$viServers = 


$output = @()
$strOutFile = "VMsWithBadMemoryConfig.csv"
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



foreach ($viServer in $viservers) {
    
    connect-viserver $viServer
    
    $colVMs = get-vm
    
    foreach ($objVM in $colVMs) {
	
        $VMView = $objVM | get-view

        if (($vmView.Config.memoryallocation.Limit) -ne "-1") {
       
            write-host  "Memory Limit Detected on " $objVM.Name -ForegroundColor Magenta
            

            if ($vmview.config.memoryallocation.limit -lt $VMView.summary.config.MemorySizeMB ) {
                    $AllocLimitMissMatch = $true
                } else {
                    $AllocLimitMissMatch = $false
                }
	
	        $VMBaloon = ($objVM | get-stat -Realtime -stat mem.vmmemctl.average -MaxSamples 1 -ErrorAction SilentlyContinue).Value
            $VMSwap   = ($objVM | get-stat -Realtime -stat mem.swapped.average -Maxsamples 1 -ErrorAction SilentlyContinue).value
            
            $objResult = [PSCustomObject] @{
		        "VM Name" 									= $objVm.Name
		        "Memory Allocation" 						= $VMView.summary.config.MemorySizeMB
		        "Memory Limit" 							    = $vmview.config.memoryallocation.limit
		        "Memory Reservation" 					    = $vmview.config.memoryallocation.Reservation
                "Memory Limit Less than Allocation" 	    = $AllocLimitMissMatch
                "Ballooned Memory" 							= $VMBaloon
                "Swapped Memory" 							= $VMSwap
                "Power State"                               = $objVM.PowerState
                "vCenter Server"                            = $viServer
	        }

        $output += $objResult

        } 
    
    }
    disconnect-viserver $viserver -confirm:$false
}
$output
$output | export-csv $strOutFile -notype
