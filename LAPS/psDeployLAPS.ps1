<#
.DESCRIPTION
This script has been created to deploy LAPS CSE remotely
.INPUTS
  Change $input variable with a valid location of the text file containing the list of computer names
  Change the Copy Item path to the location of the LAPS source files
.OUTPUTS
    N|A
.NOTES
  Version:        2.0
  Author:         SBarker
  Creation Date:  12-12-2017
  Purpose/Change: Initial script  
Version 1.0
  Purpose/Change: Initial script  
Version 2.0 - 15-05-2019
  Added TRY/Catch to log errors
Version 2.1 - 20-05-2019
  Changed the location of the Install part of the script
#>

#Vars
#Set the location of the results file csv file, appends date to the log file
$strLogDate = Get-Date -f ddMMyyyy
$Resultscsv = "Drive:\path\InstallLAPS-$strLogDate.csv"
$NewFolder = "LAPS"
$Psexec = ".\PsExec.exe \\"
$Ag = " cmd /c ""msiexec.exe /i C:\Temp\LAPS\"
$Ag2 = " /qn /norestart"""
#$servers = Get-Content Drive:\path\AllServers.txt
$Servers = ""
#Array
$LogData = @()

Foreach ($server in $Servers) {
  $LogStat = New-Object psobject -Property @{
    ServerName    = ""
    Ping          = ""
    UNCConnection = ""
    Arch          = ""
    LAPSInstalled = ""
    CopyError     = ""
  }

  $LogStat.ServerName = $Server

  If (Test-Connection -computername $Server -count 1 -quiet) {
    $LogStat.Ping = "PingOK"
    Write-Host "$Server Pinging" -ForegroundColor Green
    TRY {
      IF (Test-Path "\\$server\c$\Program Files\LAPS\CSE\AdmPwd.dll" -ErrorAction STOP) {
        Write-Host "Installed on $Server!" -ForegroundColor Green
        $LogStat.LAPSInstalled = "Y"
      }
      ELSE {
        #Get Architecture Type
        $InstallLAPS = ""
        if ((Get-WmiObject win32_processor -ComputerName $Server | select -first 1 | Select addresswidth).addresswidth -eq "64") {
          $LogStat.Arch = "64-Bit"
          $InstallLAPS = "LAPS.x64.msi"
        }
        ELSE {
          $LogStat.Arch = "32-Bit"
          $InstallLAPS = "LAPS.x86.msi"
        }

        #Check for folder & file
        IF (Test-Path \\$Server\C$\Temp\$NewFolder\$InstallLAPS) {
          Write-Host "Installation files exists on $server"
        }
        ELSE {
          TRY {
            New-Item "\\$Server\C$\Temp\$NewFolder" -itemtype Dir -ErrorAction STOP | Out-Null
            Write-Host "Copying Files to $server"
            Copy-Item Drive:\Path\$InstallLAPS \\$Server\C$\Temp\$NewFolder\$InstallLAPS -ErrorAction STOP
            $LogStat.CopyError = "N"
          }
          CATCH {
            Write-Warning "Copied Failed"
            $LogStat.CopyError = "Y"
          }
        }
        #Install LAPS
        Write-Host "Installing LAPS on $Server"
        $cmd = $Psexec + $Server + $Ag + $InstallLAPS + $Ag2
        Invoke-Expression $cmd | Out-Null
      }
                    
    }
    CATCH {
      Write-Warning "$Server Not Installed or Access Denied"
      $LogStat.LAPSInstalled = "N"
      $LogStat.UNCConnection = "ERROR"
    }    

  }
  ELSE {
    $LogStat.Ping = "Failed"
    Write-Host "$Server Ping Failed" -ForegroundColor Red
  }
  $LogData += $LogStat
}
$LogData | Select ServerName, Ping, UNCConnection, Arch, LAPSInstalled, CopyError | Export-csv -Path $Resultscsv -NoType