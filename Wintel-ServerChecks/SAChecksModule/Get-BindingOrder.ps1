Function Get-BindOrder {
  $Binding = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Linkage").Bind
  $Return = New-Object PSobject
  $BindingOrder = @()
    ForEach ($Bind in $Binding) {
    $DeviceId = $Bind.Split("\")[2]
    $Adapter = (Get-WmiObject Win32_Networkadapter | Where-Object {$_.GUID -eq $DeviceId }).NetConnectionId
    $BindingOrder += $Adapter
    }
  $BindingOrder
}