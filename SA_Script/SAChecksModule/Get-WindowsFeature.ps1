function Get-WindowsFeature {
Get-WindowsFeature | Where-Object {$_.installed -eq "true"} | Sort-Object Name | Select-Object Name, Installed
}