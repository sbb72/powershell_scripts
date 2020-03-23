# Clean Up C Drive Script

## Introduction
This script has been developed to run against Window Servers that have reached a low disk space threshold.  The script removes temporary files and empty folders that are known to hold temporary files or files that can be deleted without review.
You will need administrator rights on the remote machine for the script to work.

## What does the script do?

### Folders to delete
The variable $PathsToDelete has a list of folders that contents will be deleted.  The list of folders to delete the contents from (not deleting the folder itself) can be easily amended depending on your environment. At the moment it delete the contents of the following folders:
- C:\Temp (Temp folder)
- C:\Windows\Temp\ (Temp Folder)
- C:\Windows\ProPatches\Patches\ (Shavlik Cache)
- C:\Program Files (x86)\BigFix Enterprise\BES Client\__BESData\__Global\__Cache\Downloads (BigFix Cache, checks if 32 or 64 bit)
- Any user profiles not used in 90 days


### Delete Profiles
Deleting profiles requires more than just deleting the a folder in the Users directory.  The script is using a utility called Delprof2 (see link below for more information and download) to remove profiles that haven't been used for over 90 days and ignores the local administrator profile.
Other profiles can be configured to be ignored if required.
The Delprof2 link https://helgeklein.com/free-tools/delprof2-user-profile-deletion-tool/

## Running the Script.
Run the script as a normal PowerShell script. The script will need to be run in 'Run As Administrator' mode or it will fail with access denied errors, there will be issues removing profiles if not 'Run As Administrator'.

To run against a single server use this cmd:
- '.\Manual_CleanUp-CDrive.ps1 -Server Test01'

To run against a serverlist in a file use this cmd:
 - '.\Manual_CleanUp-CDrive.ps1 -Serverlist C:\temp\servers.txt'
