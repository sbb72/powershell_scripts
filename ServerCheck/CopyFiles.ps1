<########
.DESCRIPTION
This script has been created to copy the Server_Check.ps1 script to a server ot list of servers.
.OUTPUTS
All Outputs are on the screen
.INPUT
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  28-03-2018
  Purpose/Change: Initial script  
Version 1.0
#>
param([string] $Server,
[string] $ServerList
)

$Folder = "C$\SUPPORT\Server_Check"
$File = "\ServerCheckv1.exe"
$SourceFilePath = "G:\SBarker\Server_Check_Deploy\"+$File
Write-Host $Server
Write-Host $ServerList

Function DeployScript { 
    Param ($Server)
    Write-Host "Starting Copying...."
    If (Test-Path \\$Server\c$ -EA SilentlyContinue){
        Write-Host "Connection to $Server was sucessful"
            If (Test-Path \\$Server\$Folder -EA SilentlyContinue) {
                Write-Host "$Folder Exists....skipping folder creation."
                $error[0].exception.message}
            ELSE {
                New-Item \\$Server\$Folder -itemtype Dir -EA SilentlyContinue | Out-Null
                if(-not $?) {$error[0].exception.message
                write-warning "Folder Failed"}
                else {write-host " Created folder Succes"}
                }
            If (Test-Path \\$Server\$Folder\$File -EA SilentlyContinue) {
            Write-Host "$File Exists....skipping file copy."
            }
            Else {
                Copy-Item $SourceFilePath \\$Server\$Folder\$File -EA SilentlyContinue | Out-Null
                if(-not $?) {write-warning "Copy Failed"}
                else {write-host "Copied script Succes"} 
            }
    }
    ELSE {
    Write-Host "Connection to $Server Failed, Check server is up!" -ForegroundColor Red
    }
}

Clear-Host
Write-Host "This script will copy $File script to a server" -ForegroundColor Green
Write-Host "Or a list of servers depending on what swicth you have specified." -ForegroundColor Green
Write-Host "Usage 'Copyfiles.ps1 -Server servername' or 'Copyfiles.ps1 -ServerList C:\Temp\Servers.txt'" -ForegroundColor Green
Write-Host "Are you ready to contine?" -ForegroundColor Green
$ReadAnswer = Read-Host " (Y / N) "
Switch ($ReadAnswer) {
    Y {Write-Host "OK Continuing script....." -ForegroundColor Green}
    N {Write-Host "You selected No! The script will now exit!!" -ForegroundColor Red;Exit}
    }
Clear-Host

If (!$ServerList) {Write-Host "No Server List path entered Using Server switch "
    If (!$Server) {
        Write-Host "Server Switch also is empty"
        Write-Host "Re-Run the script the following format 'Copyfiles.ps1 -Server servername'"
        Exit
    }
    ELSE {
        DeployScript $Server
    }
}
ELSE {$Servers = Get-Content $ServerList -EA SilentlyContinue
    if(-not $?) {write-warning "Something went wrong importing the server list!"}
    ELSE {
        ForEach ($Server in $Servers) {
        Write-Host $Server
        DeployScript $Server}
    }
}