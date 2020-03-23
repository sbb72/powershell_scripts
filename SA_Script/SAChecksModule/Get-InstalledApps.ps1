function Get-InstalledApps {
  $UninstallRegKeys = @("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall", "SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")
  $apparray = @()
  $computer = $env:COMPUTERNAME
  foreach ($UninstallRegKey in $UninstallRegKeys) {
    try {
      $HKLM = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine', $computer)
      $UninstallRef = $HKLM.OpenSubKey($UninstallRegKey)
      $Applications = $UninstallRef.GetSubKeyNames()
    }
    catch {
      Write-Verbose "Failed to read $UninstallRegKey"
      Continue
    }
    foreach ($App in $Applications) {
      $AppRegistryKey = $UninstallRegKey + "\\" + $App
      $AppDetails = $HKLM.OpenSubKey($AppRegistryKey)
      if (!$($AppDetails.GetValue("DisplayName"))) { continue }

      $obj = New-Object psobject -Property @{
        DisplayName    = $($AppDetails.GetValue("DisplayName"))
        DisplayVersion = $($AppDetails.GetValue("DisplayVersion"))
        Publisher      = $($AppDetails.GetValue("Publisher"))
        Install_Date   = $($AppDetails.GetValue("InstallDate"))
      }
      $apparray += $obj
    }
  }
  return $apparray 
}
