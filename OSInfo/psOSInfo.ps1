<#
.DESCRIPTION
Tests connectivity to the server then gathers Server information remotely putting the data into a csv file
.INPUTS
  Change $Servers variable to the input file location
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

#Input file...point to your server list
$Servers = Get-Content C:\Temp\Servers.txt
#Set the location of the results file csv file, appends date to the log file
$strLogDate = Get-Date -f ddMMyyyy
$Resultscsv = "C:\Temp\ServerInfo-$strLogDate.csv"
#Array
$LogData = @()

Foreach ($Server in $Servers){
$LogStat = "" | Select Servername,Ping,OSVersion,Manufacturer,Model,NumberOfProcessors,NumberOfLogicalProcessors,BIOS,BIOSDate,serialnumber
$LogStat.ServerName = $Server
#Ping Test before tries to connect to WMI
If (Test-Connection -computername $Server -count 1 -quiet) {
        $LogStat.Ping = "PingOK"
        Write-Output "Getting Data for $Server"
        
        #Get HardwareInfo
        $CSInfo = Get-WmiObject Win32_Computersystem -computername $Server
        $LogStat.Servername = $CSInfo.Name
        $LogStat.Manufacturer = $CSInfo.Manufacturer
        $LogStat.Model = $CSInfo.Model
        $LogStat.NumberOfProcessors = $CSInfo.NumberOfProcessors
        $LogStat.NumberOfLogicalProcessors = $CSInfo.NumberOfLogicalProcessors

        #Get BIOS Info
        $BIOSInfo = Get-WmiObject win32_bios -computername $Server
        $LogStat.BIOS = $BIOSInfo.SMBIOSBIOSVersion
        #$BIOSInfo.releasedate
        $LogStat.serialnumber = $BIOSInfo.serialnumber

        #Get first 8 numbers from the string to display the date
        $Date8 = $BIOSInfo.releasedate
        $LogStat.BIOSDate = $Date8.substring(0,8)

        #Get OS Version
        $OSInfo = Get-WmiObject Win32_OperatingSystem -computername $Server
        $LogStat.OSVersion = $OSVersion = $OSInfo.Caption
        
}
Else {
$LogStat.Ping = "NoConnectivity"
Write-Output "No Connectivity to $Server"
}
$LogData += $LogStat
}
$LogData | Select Servername,Ping,OSVersion,Manufacturer,Model,NumberOfProcessors,NumberOfLogicalProcessors,BIOS,BIOSDate,serialnumber | Export-CSV -Path $Resultscsv -NoType
