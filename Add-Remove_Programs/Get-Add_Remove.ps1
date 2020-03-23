import-module activedirectory

$domain = Get-ADDomain | Select Name
$logdate = Get-Date -Format "dd-MM-yyy"
$logfile = "C:\Temp\"+$domain.name+"-"+$logdate+".csv"

$AllServers = Get-ADComputer -Filter {operatingsystem -like "*server*"} | Select-Object Name

ForEach ($computer in $AllServers) {
    $computer = $computer.name
    Write-Host "Checking $computer Exporting Add-Remove Programs"

    $UninstallRegKeys=@("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall","SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")
    $apparray = @()
    foreach($UninstallRegKey in $UninstallRegKeys) {
      try {
    $HKLM   = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computer)
    $UninstallRef  = $HKLM.OpenSubKey($UninstallRegKey)
    $Applications = $UninstallRef.GetSubKeyNames()
      } catch {
    Write-Verbose "Failed to read $UninstallRegKey"
    Continue
      }
          foreach ($App in $Applications) {
          $AppRegistryKey  = $UninstallRegKey + "\\" + $App
          $AppDetails   = $HKLM.OpenSubKey($AppRegistryKey)
          if(!$($AppDetails.GetValue("DisplayName"))) { continue }

          $obj = New-Object psobject -Property @{
                Server = $computer
                DisplayName = $($AppDetails.GetValue("DisplayName"))
                DisplayVersion = $($AppDetails.GetValue("DisplayVersion"))
                Publisher = $($AppDetails.GetValue("Publisher"))
                Install_Date = $($AppDetails.GetValue("InstallDate"))
                }
              $apparray += $obj
        }
    }
$apparray1 += $apparray
}

$apparray1 | Sort-Object Server | Select-Object Server, Displayname, displayversion, Install_Date, publisher | Export-Csv $logfile -NoTypeInformation
