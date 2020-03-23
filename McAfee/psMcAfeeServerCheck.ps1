<########
.DESCRIPTION
This script has been created to help troubleshot McAfee issues on servers.
The popular issues have been found to stop McAfe VSE from updating\working, this script will check for those issues.
1.Check it's on the network i.e. ping
2.Check its enabled in AD, get the last logon date and password date.
3.Check diskspace of the C drive
4.Check VSE version, engine and dat versions
.INPUTS
  Change $input variable with a valid location of the text file containing the list of computer names
.OUTPUTS
  Log file stored in current directory, change the location in the $Resultscsv variable if required.
.NOTES
  Version:        1.3
  Author:         SBarker
  Creation Date:  26-09-2016
  Purpose/Change: Initial script  
Version 1.0
Purpose/Change: Initial script  
Version 1.1
Added error check for the 4 checks
Version 1.3
Added Get IP from DNS
Version 1.4
Added Functions
#>

#Check input file exists
$InputFile = ".\Test.txt"
$Servers = Get-Content $InputFile
If (Test-path $InputFile -EA SilentlyContinue) {
  Write-Host "Input file exists" -ForegroundColor Green
}
ELSE {
  Write-Host "Can not find INPUT file!" -ForegroundColor Red
  EXIT
}

#Set the location of the results file csv file, appends date to the log file
$strLogDate = Get-Date -f ddMMyyyy
$Resultscsv = ".\Test-$strLogDate.csv"
#Array
$LogData = @()

#Import AD Module
Import-Module ActiveDirectory

#Functions
Function DNSCheck {
  Param ($strDNS)
  $LogStat.IP = [system.Net.Dns]::Resolve($strDNS).AddressList.IPAddressToString
  If (!($LogStat.IP)) { $LogStat.IP = "NotinDNS" }
}

Function ADCheck {
  Param ($strAD)
  $CompDetails = Get-ADComputer -Identity $strAD -Properties *
  $LogStat.LastLogonDate = $CompDetails.LastLogonDate
  $LogStat.PasswordLastSet = $CompDetails.PasswordLastSet
  $LogStat.Enabled = $CompDetails.Enabled
}
    
ForEach ($Server in $Servers) {
  $LogStat = "" | Select ServerName, Ping, IP, LastLogonDate, PasswordLastSet, Enabled, CDriveFree, CDriveSize, CBSRebootPend, WUAURebootReq, PendFileRename, VSEVersion, EngineVer, DatVersion
  $LogStat.ServerName = $Server

  #Ping Test before tries to connect to server
  If (Test-Connection -computername $Server -count 1 -quiet) {
    $LogStat.Ping = "PingOK"
    Write-Output "Getting Data for $Server"

    #Get AD details of machine
    If (Get-ADComputer -Filter { name -eq $Server } -EA SilentlyContinue) {
      #Call Function
      ADCheck $Server
    
      #Get IP of machine from DNS via Function
      DNSCheck $Server
    
      #Get size Space from remote machine
      If (Get-WmiObject Win32_LogicalDisk -ComputerName $Server -EA SilentlyContinue) {
        #Write-Host "WMI YES"
        $disk = Get-WmiObject Win32_LogicalDisk -ComputerName $Server -Filter "DeviceID='C:'" #| Select Size,FreeSpace
        $LogStat.CDriveFree = [Math]::Round($Disk.Freespace / 1MB)
        $LogStat.CDriveSize = [Math]::Round($Disk.Size / 1MB)
      }
      ELSE {
        Write-Host "WMI NO"
        $LogStat.CDriveFree = "Connection_Failed"
      }

      #Check if Server requires a reboot
      ## Making registry connection to the local/remote computer 
      $HKLM = [UInt32] "0x80000002" 
      $WMI_Reg = [WMIClass] "\\$Server\root\default:StdRegProv" 

      $RegSubKeysCBS = $WMI_Reg.EnumKey($HKLM, "SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\") 
      $LogStat.CBSRebootPend = $RegSubKeysCBS.sNames -contains "RebootPending"
      If ($LogStat.CBSRebootPend) {
        $LogStat.CBSRebootPend = "NoEntry"
      }
 
      ## Query WUAU from the registry 
      $RegWUAURebootReq = $WMI_Reg.EnumKey($HKLM, "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\") 
      $LogStat.WUAURebootReq = $RegWUAURebootReq.sNames -contains "RebootRequired" 
             
      ## Query PendingFileRenameOperations from the registry 
      $RegSubKeySM = $WMI_Reg.GetMultiStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\Session Manager\", "PendingFileRenameOperations") 
      $RegValuePFRO = $RegSubKeySM.sValue
      $LogStat.PendFileRename = "False"
      If ($RegValuePFRO) { 
        $PendFileRename = $true
        $LogStat.PendFileRename = $PendFileRename
      }
      #Get Dat files for McAfee
      if ((Get-WmiObject win32_operatingsystem | select osarchitecture).osarchitecture -eq "64-bit") {
        #64 bit logic here
        #Write "64-bit OS"
        #Write-Output "Getting McAfee Data for $Server"
        $ProductVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Server).OpenSubKey('SOFTWARE\Wow6432Node\McAfee\DesktopProtection').GetValue('szProductVer')
        $EngineVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Server).OpenSubKey('SOFTWARE\Wow6432Node\McAfee\AVEngine').GetValue('EngineVersionMajor')
        $DatVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Server).OpenSubKey('SOFTWARE\Wow6432Node\McAfee\AVEngine').GetValue('AVDatVersion')
        $LogStat.VSEVersion = $ProductVer
        $LogStat.EngineVer = $EngineVer
        $LogStat.DatVersion = $DatVer
      }
      else {
        #32 bit logic here
        #Write "32-bit OS"
        $ProductVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Server).OpenSubKey('Software\McAfee\DesktopProtection').GetValue('szProductVer')
        $EngineVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Server).OpenSubKey('Software\McAfee\AVEngine').GetValue('EngineVersionMajor')
        $DatVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Server).OpenSubKey('Software\McAfee\AVEngine').GetValue('AVDatVersion')
        $LogStat.VSEVersion = $ProductVer
        $LogStat.EngineVer = $EngineVer
        $LogStat.DatVersion = $DatVer
      }
    }
    ELSE {
      $LogStat.Enabled = "Not_in_AD"
      Write-Host "No Ping NOT in AD"
    }
  }
  Else {
    $LogStat.Ping = "NoConnectivity"
    Write-Output "No Connectivity to $Server"
    #Get AD details of machine
    If (Get-ADComputer -Filter { name -eq $Server } -EA SilentlyContinue) {
      Write-Host "YES - No Ping"
    
      ADCheck $Server
      #Get IP of machine from DNS
      DNSCheck $Server

    }
    ELSE {
      $LogStat.Enabled = "Not_in_AD"
      # Write-Host "No Ping NOT in AD"
      DNSCheck $Server
    }

  }
  $LogData += $LogStat
}
$LogData | Select ServerName, Ping, IP, LastLogonDate, PasswordLastSet, Enabled, CDriveFree, CDriveSize, CBSRebootPend, WUAURebootReq, PendFileRename, VSEVersion, EngineVer, DatVersion | Export-CSV -Path $Resultscsv -NoType
