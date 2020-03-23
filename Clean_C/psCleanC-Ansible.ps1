<########
.DESCRIPTION
This script has been created to remove files from the C Drive.  It will remove files in C:\Temp C:\Windows\ProPatches\Patches (Shavlik cache).
It will also delete profiles not used in 90 days, using the Delprof2 utility.
.OUTPUTS
All Outputs are on the screen and to C:\Support\CDrive_Clean via the $output variable
Add any accounts \ profiles to the $arg variable that will not get removed.
.INPUT
Delprof2 utility is required to remove the old profiles, link below to download it.
https://helgeklein.com/free-tools/delprof2-user-profile-deletion-tool/
.NOTES
  Version:        1.1
  Author:         SBarker
  Creation Date:  13-04-2018
  Purpose/Change: Initial script  
Version 1.0
Script Creation  
Version 1.1
Changed outpout to append a text file to log errors and track deletions.
#>
#Variables
$PathsToDelete = "C:\Temp", "C:\Windows\ProPatches\Patches" #All folders that contents will be deleted
$Server = $env:COMPUTERNAME
$strLogDate = Get-Date -f ddMMyyyy
$strLog = Get-Date -f dd-MM-yyyy
$SourceFilePath = "Wintel Tools\DelProf2\DelProf2.exe"
$DestFilePath = "C:\Support\CDrive_Clean"
$File = "DelProf2.exe"

$output = "$DestFilePath\$strLogDate-CleanC.txt"

function CDriveCheck ([string]$Server, [string]$diskoutput) {
    If (Get-WmiObject Win32_LogicalDisk -EA SilentlyContinue) {
        $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
        $CDriveFree = [Math]::Round($Disk.Freespace / 1MB)
        $CDriveSize = [Math]::Round($Disk.Size / 1MB)
        Write-Host "C Drive is $CDriveSize MB in Size"
        "$diskoutput-C_Drive_Size_MB C Drive is $CDriveSize MB in Size" | Out-File $Output -Append
        Write-Host "C Drive has $CDriveFree MB free"
        "$diskoutput-C_Drive_Size_MB C Drive is $CDriveFree MB in Size" | Out-File $Output -Append
    }
    ELSE {
        Write-Host "WMI Connection_Failed"
        "WMI Connection_Failed" | Out-File $Output -Append
    }   
}

Clear-Host
Write-Host "This script will delete all files in the following folders: " -ForegroundColor Green
Write-Host $PathsToDelete -ForegroundColor Green
Write-Host "It will also delete profiles that have not been used for over 90 Days." -ForegroundColor Green
Write-Host "Are you ready to contine?" -ForegroundColor Green
$ReadAnswer = Read-Host " (Y / N) "
Switch ($ReadAnswer) {
    Y {Write-Host "OK Continuing script....." -ForegroundColor Green}
    N {Write-Host "You selected No! The script will now exit!!" -ForegroundColor Red; Exit}
}
Clear-Host

If (Test-Path $SourceFilePath -EA SilentlyContinue) {
    Write-Host "Connection to $SourceFilePath was sucessful"
    If (Test-Path $DestFilePath -EA SilentlyContinue) {
        Write-Host "$DestFilePath Exists....skipping folder creation."
        $error[0].exception.message
    }
    ELSE {
        New-Item $DestFilePath -itemtype Dir -EA SilentlyContinue | Out-Null
        if (-not $?) {
            $error[0].exception.message
            write-warning "Folder Creation Failed"
        }
        else {write-host " Created folder Succes"}
    }
    If (Test-Path $DestFilePath\$File -EA SilentlyContinue) {
        Write-Host "$File Exists....skipping file copy."
    }
    Else {
        Copy-Item $SourceFilePath $DestFilePath -EA SilentlyContinue | Out-Null
        if (-not $?) {write-warning "Copy Failed"}
        else {
            write-host "Copied DelProf OK"
            "##########################################" | Out-File $Output -Append
            "Started C Drive clean up $strLog" | Out-File $Output -Append
            "##########################################" | Out-File $Output -Append
            "Copied DelProf OK" | Out-File $Output -Append
        } 
    }
}
ELSE {
    Write-Host "Connection to $SourceFilePath Failed, Check Source Server Path! Script will EXIT" -ForegroundColor Red; EXIT
    "Connection to $SourceFilePath Failed, Check Source Server Path! Script will EXIT" | Out-File $Output -Append
}

If (Get-WmiObject Win32_LogicalDisk -EA SilentlyContinue) {
    Write-Host "Checking C drive space before deletion of files"
    $diskoutput = "B4"
    CDriveCheck $Server $diskoutput
    #Delete all files from the folders in the PathsToDelete variable
    Foreach ($folder in $PathsToDelete) {
        If (Test-Path $folder) {     
            $folder + " Exists" | Out-File $Output -Append
            Remove-Item -path "$folder\*" -recurse   
            if (-not $?) {
                write-warning "Deletion of $folder Failed"
                "Deletion of $folder Failed" | Out-File $Output -Append
            }
            else {
                Write-host -foregroundcolor Green  "Contents of $folder Deleted"
                "Contents of $folder Deleted" | Out-File $Output -Append
            } 
            [System.Threading.Thread]::Sleep(1500) 
        }
        ELSE {     
            Write-host -foregroundcolor Red "$folder  Does not exist" 
            "$folder  Does not exist" | Out-File $Output -Append
        } 
    }
    #Remove prfiles older than 90 days and not the local admin account
    $arg = " /u /d:90 /ed:Admin* /ed:zGKRADMIN"
    $cmd = $DestFilePath + "\" + $file + $arg
    Invoke-Expression $cmd

    #Get size and free space afterwards
    Write-Host "Checking C drive space after deletion of folders"
    $diskoutput = "After"
    CDriveCheck $Server $diskoutput
}
ELSE {
    Write-Host "WMI Connection_Failed"
    "WMI Connection_Failed" | Out-File $Output -Append
}
#End