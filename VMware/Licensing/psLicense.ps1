

$filename="C:\LicenseInformation.csv"
$ServiceInstance=Get-View ServiceInstance
$LicenseMan=Get-View $ServiceInstance.Content.LicenseManager
$vSphereLicInfo= @()
Foreach ($Licensein$LicenseMan.Licenses){
   $Details="" |Select Name, Key, Total, Used,Information
   $Details.Name=$License.Name
   $Details.Key=$License.LicenseKey
   $Details.Total=$License.Total
   $Details.Used=$License.Used
   $Details.Information=$License.Labels |Select-expandValue
   $vSphereLicInfo+=$Details
}
$vSphereLicInfo |Select Name, Key, Total, Used,Information | Export-Csv -NoTypeInformation $filename
