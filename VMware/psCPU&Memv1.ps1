#
# Added Host server to export
$filepath = "E:\Temp"
$vcenter = ""
$myCol = @()

Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer -Server $vcenter -User csc_mcs -Password P@ssw0rd -Force 

$myCol = @()
Foreach ($VM in (Get-View -ViewType VirtualMachine |Sort Name)){
   $MYInfo = "" | select-Object VMName,VMHost,CPUReservation,CPULimit,CPUShares,MEMSize,MEMReservation,MEMLimit,MEMShares
   $MYInfo.VMName = $VM.Name
   #
   $ESXHOST = get-vm $VM.Name
   $MYInfo.VMHost = $ESXHOST.VMHost
   #
   $MYInfo.CPUReservation = $VM.Config.CpuAllocation.Reservation
   If ($VM.Config.CpuAllocation.Limit-eq "-1"){
      $MYInfo.CPULimit = "Unlimited"}
   Else{
      $MYInfo.CPULimit = $VM.Config.CpuAllocation.Limit
   }
   $MYInfo.CPUShares = $VM.Config.CpuAllocation.Shares.Shares
   $MYInfo.MEMSize = $VM.Config.Hardware.MemoryMB
   $MYInfo.MEMReservation = $VM.Config.MemoryAllocation.Reservation
   If ($VM.Config.MemoryAllocation.Limit-eq "-1"){
      $MYInfo.MEMLimit = "Unlimited"}
   Else{
      $MYInfo.MEMLimit = $VM.Config.MemoryAllocation.Limit
   }
   $MYInfo.MEMShares = $VM.Config.MemoryAllocation.Shares.Shares
   $myCol += $MYInfo
}
$myCol |Export-csv -NoTypeInformation $filepath"\"$vcenter-CPUMem.csv