function Get-AVStatus ($Apparray, $AppName) {
    if ((Get-WmiObject win32_operatingsystem | select osarchitecture).osarchitecture -eq "64-bit"){
        $macfeepath  = "SOFTWARE\Wow6432Node\McAfee\"}
        else{
        $macfeepath = "Software\McAfee\"}

    $mcsoftware =$Apparray | Where {$_.DisplayName  -match  $AppName} 
    if ($mcsoftware -eq $null) {
        $mcafeeobj= New-Object psobject -Property @{
        Name="$AppName"
        State="Not Installed"
        Version="Not Available"}
    }
    else {
        $mcafeeobj= New-Object psobject -Property @{
        Name=$mcsoftware.displayname
        State="Installed"
        Version=$mcsoftware.DisplayVersion
        Product_Version = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$Server).OpenSubKey($macfeepath+"DesktopProtection").GetValue('szProductVer')
        Engine_Version = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$Server).OpenSubKey($macfeepath+'AVEngine').GetValue('EngineVersionMajor')
        Dat_Version = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$Server).OpenSubKey($macfeepath+'AVEngine').GetValue('AVDatVersion')
        }
$test = $mcafeeobj | Select-Object Name, State, Product_Version, Engine_Version, Dat_Version
    }
#$mcafeeobj | Select-Object Name, State, Product_Version, Engine_Version, Dat_Version
}