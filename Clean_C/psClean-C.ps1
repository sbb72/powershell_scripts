<#
.DESCRIPTION
######################################################################
##BE SURE YOU WANT TO DELETE THE FILES IN THE FOLDERS SPECIFIED!!!!!##
######################################################################
This script has been created to delete files from Temp files on servers, files from the following folders
to be deleted are C:\Temp, C:\Windows\Temp and C:Windows\ProPatches\Patches.
The list of folder contents to delete can be changed by changing $PathsToDelete variable on line 25 ish, keep it in the same format.
If the server can not be pinged the script will end.
.INPUTS
  Change $strworkingdir variable on line 29 ish with a valid location of the text file containing the list of servers and the script.
  The Server list should be called 'Servers.txt' and have the server name on each line.
.OUTPUTS
  Log file stored in $strworkingdir
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  06-07-2017
  Purpose/Change: Initial script  
Version 1.0
Purpose/Change: Initial script  
#>


##################################################
#All folders that contents are to be deleted
$PathsToDelete = "C$\Temp", "C$\Windows\Temp", "C$\Windows\ProPatches\Patches"

##################################################
#Set the directory that the script and server list exists
$strworkingdir = "path\"

##################################################
#Confirming what the script will do!!!
Clear-host
Write-Host "This script will delete all files in the following folders $PathsToDelete, do you want to contine?" -Foregroundcolor Red
$ReadAnswer = Read-Host " (Y / N) "
Switch ($ReadAnswer) {
    Y { Write-Host "Yes, Continue" -ForegroundColor Green }
    N { Write-Host "No, Exit Script" -ForegroundColor Red; Exit }
}

#Check input file exists
$InputFile = "$strworkingdir\Servers.txt"
$Servers = Get-Content $InputFile
If (Test-path $InputFile -EA SilentlyContinue) {
    Write-Host "Input file exists" -ForegroundColor Green
}
ELSE {
    Write-Host "Cannot find INPUT file!" -ForegroundColor Red
    EXIT
}

#Set the location of the results csv file, appends date to the log file
$strLogDate = Get-Date -f ddMMyyyy
$Resultscsv = $strworkingdir + "ClearC-" + $strLogDate + ".csv"
#Checking if results file exists and confirm to overwrite it
If (Test-Path $Resultscsv) {
    Clear-host
    Write-host "$Resultscsv exists and will be over written, do you want to contine?" -Foregroundcolor Red
    $ReadAnswer = Read-Host " (Y / N) "
    Switch ($ReadAnswer) {
        Y { Write-Host "Yes, Continuing" -ForegroundColor Green }
        N { Write-Host "No, Exit Script" -ForegroundColor Red; Exit }
    }
}

#Main part of script
#Array
$LogData = @()

ForEach ($Server in $Servers) {
    $LogStat = "" | Select ServerName, Ping, CDriveFreeB4, CDriveSizeB4, CDriveFreeAfter
    $LogStat.ServerName = $Server

    #Ping Test before tries to connect to server
    If (Test-Connection -computername $Server -count 1 -quiet) {
        $LogStat.Ping = "PingOK"
        Write-Output "$Server is pinging"

        #Get size from remote machine before
        If (Get-WmiObject Win32_LogicalDisk -ComputerName $Server -EA SilentlyContinue) {
            #Write-Host "WMI YES"
            $disk = Get-WmiObject Win32_LogicalDisk -ComputerName $Server -Filter "DeviceID='C:'" #| Select Size,FreeSpace
            $LogStat.CDriveFreeB4 = [Math]::Round($Disk.Freespace / 1MB)
            $LogStat.CDriveSizeB4 = [Math]::Round($Disk.Size / 1MB)
        }
        ELSE {
            Write-Host "WMI NO"
            $LogStat.CDriveFree = "Connection_Failed"
        }
        #Delete all files from the folders in the PathsToDelete variable
        Foreach ($folder in $PathsToDelete) {
            $strServer = "\\$Server\$Folder"
            If (Test-Path $strServer) {     
                $folder + " on " + $Server + " Exists" 
                Remove-Item -path "\\$Server\$folder\*" -recurse 
                Write-host -foregroundcolor Red  "Contents of $Server\$folder Deleted" 
                [System.Threading.Thread]::Sleep(1500) 
            }
            ELSE {     
                Write-host -foregroundcolor Red $Server"\"$folder  " Does not exist" 
            } 
        
        }

        #Get size from remote machine before deletion
        If (Get-WmiObject Win32_LogicalDisk -ComputerName $Server -EA SilentlyContinue) {
            #Write-Host "WMI YES"
            $disk = Get-WmiObject Win32_LogicalDisk -ComputerName $Server -Filter "DeviceID='C:'" #| Select Size,FreeSpace
            $LogStat.CDriveFreeAfter = [Math]::Round($Disk.Freespace / 1MB)
        }
        ELSE {
            Write-Host "WMI NO"
            $LogStat.CDriveFree = "Connection_Failed"
        }

    }
    ELSE {
        $LogStat.Ping = "NoConnectivity"
        Write-Output "No Connectivity to $Server"
    }
    $LogData += $LogStat
}#END

$LogData | Select ServerName, Ping, CDriveFreeB4, CDriveSizeB4, CDriveFreeAfter | Export-CSV -Path $Resultscsv -NoType