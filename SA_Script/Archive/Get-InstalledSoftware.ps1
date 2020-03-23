function Get-InstalledSoftware ($Apparray, $AppName)
{
    if($Apparray.count -eq 0){
    }
    $software =$Apparray | Where {$_.DisplayName  -match  $AppName} 
    if ($software.count -eq  0) {
        $softObj= New-Object psobject -Property @{
            Name="$AppName"
            State="Not Installed"
            Version="Not Available"
        }
    }
    else {
        $softObj= New-Object psobject -Property @{
            Name=$software.displayname
            State="Installed"
            Version=$software.DisplayVersion
            }

    }
    return $softObj
}