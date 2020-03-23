<#
.DESCRIPTION
Exports the VMTools Version, VMTools Status (if it's upto date or not) and the Hardware version.
.INPUTS
  Change $vCenter variable with a valid location of the text file containing the list of names to query
.OUTPUTS
   Change $LogName, the output will be written to the current folder.
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  11-01-2018
  Purpose/Change: Initial script  
Version 1.0
Created Script
#>

# Adds the powercli cmdlet
Add-PSSnapin VMware.VimAutomation.Core -erroraction SilentlyContinue

$strLogDate = Get-Date -f ddMMyyyy
#Log Name
$LogName = "Accountx"
#VC List by file
#$vCenter = Get-Content "F:\sbarker\Scripts\VMware\VCs.txt"
$vCenter ="VCServer01"
$serverdetails = @()
#Define Extended properties
New-VIProperty -Name ToolsVersion -ObjectType VirtualMachine -ValueFromExtensionProperty 'Config.tools.ToolsVersion' -force
New-VIProperty -Name ToolsVersionStatus -ObjectType VirtualMachine -ValueFromExtensionProperty 'Guest.ToolsVersionStatus' -Force

ForEach ($VC in $vCenter) {
connect-VIServer $VC

    ForEach ($Cluster in Get-Cluster){

        ForEach ($Item in ($Cluster | Get-VMHost)) {

            ForEach ($VM in ($Item | Get-VM)) {
            $ServerStat = "" | Select vCenter,Name,Cluster,HWVersion,VMToolsVersion,VMToolsStatus
            $ServerStat.vCenter = $VC
            $vmhost_view = $VM
            Write-Host "Checking versions on $VM"
            $ServerStat.Name = $vmhost_view.Name
            $ServerStat.Cluster = $Cluster
            #Get VMtools data
            $ServerStat.VMToolsVersion = $vmhost_view.ToolsVersion
            $ServerStat.VMToolsStatus = $vmhost_view.ToolsVersionStatus
            #Get Hardware Version
            $ServerStat.HWVersion = $vmhost_view.Version

            $serverdetails += $ServerStat
            }
        }

    }
Disconnect-VIServer $VC -force -Confirm:$false
}
$serverdetails | Select vCenter,Name,Cluster,HWVersion,VMToolsVersion,VMToolsStatus | Export-csv -Path .\$LogName-$strLogDate.csv -Notype
