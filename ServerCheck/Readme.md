# Server Check

## Introduction
This script has been created to export settings and logs from a Windows Server into a html log file to aid troubleshooting.  It’s not been created to run periodically, even though it could if there was a requirement too.

This repository contains 3 working files:
- ServerCheckv1.exe
- ServerCheck.ps1
- CopyFiles.ps1

**ServerCheckv1.exe**
Is a compiled exe from the source ServerCheck.ps1 PowerShell script for ease of running the script. Below is a link on how to create the exe from Microsoft Script center.
https://gallery.technet.microsoft.com/scriptcenter/PS2EXE-GUI-Convert-e7cb69d5

**ServerCheck.ps1**
PowerShell script that exports the information into a html format. The script exports the following information:
- Operating System (OS) information
  - OS version & SP
  - Up Time of the server
  - Server pending a restart?
  - Memory and CPU Information
- Top 20 Active Processes - CPU
- Top 15 Active Processes - Memory
- Local Disk information
- NIC Settings
- VMWare Tools status
- Services Status
- Installed Hotfixes
- Device Manager Errors
- Event Log errors from last 48 hours
  - Application and System events
 
**CopyFiles.ps1**
This PowerShell script creates the structure to run the ServerCheck.exe executable .  If you specify a -Server switch with a valid server name it will create the structure on the remote servers to enable you to log on to the server locally and run the executable.  You can also run the -ServerList switch to point to a server list to deploy to a list of servers.  The text file just needs to have a list of servers names with a carriage  return between the server names.
The usage 'Copyfiles.ps1 -Server servername' or 'Copyfiles.ps1 -ServerList C:\Temp\Servers.txt'


## How to....
To run the ServerCheckv1.exe locate the executable in C:\Support\Server_Check on the local server and 'Run As Administrator’ (Right Click the exe and select Run As Administrator).
The executable will run and export the html file in the following format, *Date_Hostname.html* i.e. *26032018_Server01.html*.
If the executable is being ran again on the same day the script will prompt you if you want to overwrite the file, if you select no the exit the script and prompt you to rename the html file then re-run the exceuatable. If you select 'Y' it will over write the html file.


## Improvements \ Actions
- [ ] Add File Versions to the exe file
- [ ] Send script engineers for testing
- [ ] Review feed back 


## Known Issues
Waiting for feedback....



