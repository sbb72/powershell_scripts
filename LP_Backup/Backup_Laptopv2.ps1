<#
.DESCRIPTION
Backup data to NAS
.INPUTS
 
.OUTPUTS
  Log file stored in C:\Temp\ServerInfo-%Currentdate%.csv...change the location in the $Resultscsv variable if required.
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  26-09-2016
  Purpose/Change: Initial script  
.EXAMPLE
  N|A
#>	

#Date Format
$Date = Get-Date -f dd-MM-yyyy

#Varibles
#Backup directory
$SourceDir = "D:\Data\ " 
$DestDir = "\\192.168.1.50\BackupData\WorkLP\Data\"
#$BackupLogDir = "\\192.168.0.199\BackupLog\"
$BackupLogDir = "D:\Data"

$LogFile = $DestDir + "Backup" + $Date + ".log" #Log File name

#Robocopy Command
#$strBackupCmd = "robocopy "D:\TEMP\Kixart C:\Temp /s /e /a /z /np /r:1 /w:1 /log: +$strBackupLogFile
$switches = "/e /a /np /purge /r:1 /w:1 /log:"
$excludedirs = " /XD D:\Temp D:\Data\Notes_Archive "

$Backupcmd =  "robocopy " + $SourceDir + $DestDir + $excludedirs + " "  + $switches + $LogFile

invoke-expression -command $Backupcmd 
