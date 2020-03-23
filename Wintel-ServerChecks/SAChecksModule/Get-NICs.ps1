function Get-NICs {
    $getnetworks = Get-WmiObject Win32_NetworkAdapterConfiguration  | Where-Object {$_.IPEnabled -match "True"}
    $nicarray = @{}
    ForEach ($item in $getnetworks){
        $nic =  New-Object -TypeName PSObject -Property @{
        Description = $item.Description
        IPaddress = $item.IPAddress -join ''
        IPSubnet = $item.IPSubnet -join ''
        DefaultIPGateway = $item.DefaultIPGateway -join ''
        DNS_Servers1 =  if($item.DNSServerSearchOrder.count -gt 0){$item.DNSServerSearchOrder[0]}else {""}
        DNS_Servers2 =  if($item.DNSServerSearchOrder.count -gt 1){$item.DNSServerSearchOrder[1]}else {""}

        }
    $nicarray += @{$nic.Description= $nic}
    }
    $nicarray #| Select-object Description, IPaddress, DefaultIPGateway, IPSubnet,DNS_Servers 
}