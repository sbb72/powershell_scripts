
##Load VMware PS plugin
Add-PSSnapin VMware.VimAutomation.Core
##Connect to vCenter
connect-viserver -server $vcenter_server -User $vcenter_user -Password $vcenter_pwd

$srcvms = get-vm -location "LAB1" | select -expandproperty Name

Foreach ($srcvm in $srcvms) {
##Stop VM
GET-VM -Name $VM2change| Stop-VMGuest -Confirm:$False
start-sleep -s 180

	$srvcvms_strip = $srcvm -replace "lab1_"

	new-vm -name "lab2_$vdevstrip" -vm $srcvm -vmhost 10.1.149.14 -datastore "datastore1" -DiskStorageFormat Thin -Location "LAB2" -RunAsync

	get-vm "lab2_$vdevstrip" | get-networkadapter | where {$_.NetworkName -eq "lab1_private-VLAN10"} | Set-NetworkAdapter -NetworkName "lab2_private-VLAN20" -confirm:$false

}


##Task Clone VM
##Declare variables
$VM2change = "test-server"
$VMclone = "$VM2change_clone"
$Hostesxi = "esxihost1.vsphere.local"
$vcenter_server ="vcenter.vsphere.local"
$vcenter_user ="administrator@vsphere.local"
$vcenter_pwd ="Password123"
##Email Settings
$emailServer = "192.168.1.1"
$sender = "powercli@vsphere.local"
$recipients = "admin@vsphere.local"
$dateofclone = $(get-date -f dd-MM-yyyy)
##Load VMware PS plugin
Add-PSSnapin VMware.VimAutomation.Core
##Connect to vCenter
connect-viserver -server $vcenter_server -User $vcenter_user -Password $vcenter_pwd
###########################Start- Custom Task #########################
##Stop VM
GET-VM -Name $VM2change| Stop-VMGuest -Confirm:$False
start-sleep -s 180
##Clone VM, set disk type to thin and create in template folder
New-VM -VM $VM2change -Name $VMclone -VMHost $Hostesxi -DiskStorageFormat Thin -Location "VM Template" -Notes "Clone created $dateofclone by David McIsaac"
##Convert to template
Set-VM -VM $VMclone -ToTemplate -Confirm:$False
##Start orignal VM
GET-VM -Name $VM2change| Start-VM -Confirm:$False
##Get Clone info
$VMcloneinfo = (Get-Template -Name $VMclone| fl *|Out-String)
##ping original VM
start-sleep -s 120
$isalive= (Test-Connection -ComputerName $VM2change -count 1|Out-String)
###########################End- Custom task #########################
##Compose email and send
$body = @" 
VM Clone Created,$VMcloneinfo.
Is original VM up??, $isalive
"@
send-mailmessage -from $sender -to $recipients -subject "VM Cloned $VM2change" -Bodyashtml "$body" -smtpserver $EmailServer



Function unregisterallvm([STRING]$datacentername,[STRING]$clustername)
{
 $vms = Get-DataCenter $datacentername | Get-Cluster $clustername | get-vm
 Foreach ($vm in $vms)
 {
   $vmname = $vm.name
   Write-Host "Unregistering VM: $vmname from Cluster $clustername"
   Remove-VM -VM $vmname -DeleteFromDisk:$false -Confirm:$false -RunAsync
 }
}
 
Function registerallvm([STRING]$vCenterHost,[STRING]$datacentername,[STRING]$clustername,[STRING]$datastorename)
{
 $datastore = Get-Datacenter $datacentername | Get-Datastore | ? {$_.name -match $datastorename}
 $datastoreshortname = $datastore.Name
 $ResourcePool = Get-Cluster -Name $clustername | Get-ResourcePool | Get-View
 $vmFolder = Get-View (Get-Datacenter -Name $datacentername | Get-Folder -Name "vm").id
 $vmdirs = (dir "vmstores:\$vCenterHost@443\$datacentername\$datastoreshortname\")
 Foreach ($f in $vmdirs)
 {
   $vmname = $f.Name
   $checkreg = (Get-Cluster $clustername | Get-VM | ? { $_.name -match $vmname})
   If (!$checkreg)
   {
     "Registering VM: $vmname on: $clustername \ $datastoreshortname"
     $vmFolder.RegisterVM_Task("[$datastoreshortname]/$vmname/$vmname.vmx", $vmname, $false, $ResourcePool.MoRef, $null)   
   }
   Else
   {
     "VM: $vmname is already registered with the same name. Skipping...."
   }
 }
}