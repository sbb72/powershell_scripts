<#
.DESCRIPTION
This script has been created to perform basic checks on Active Directory then export the results into a HMTL and email the results.
The script doesn't check RODC in the domain at the moment.
.INPUTS
Gets the list of DCs in the forest, removing RODC's from the array to be checked.
.OUTPUTS
Output file stored in $outputfile location
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  10-07-2019
  Purpose/Change: Initial script  
Version 1.0
Purpose/Change: Initial script  
#>
#Services to be checked
$Services = "Netlogon","NTDS","DNS"
$ReplChecks = "Replications","FSMOCheck","Advertising","Services","NetLogons"
$LogData = @()
$strLogDate = Get-Date -f ddMMyyyy
$path = "D:\Scripts\Support_and_Administration\AD_Checks"
$outputfile = $path+"\ADChecks_"+$strLogDate+".html"
#Email
$From="Sender" 
$To="To"
$Subject="AD Checks ...."
$SmtpServer="Relay"
#HTML format
$HeaderTable = @"
<style>
TABLE {font: 12pt Arial; border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;text-align:left;}
TH {font: 12pt Arial; border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;text-align:left;}
TD {font: 12pt Arial; border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

#Get List of DCs
$getForest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest()
$DCServers = $getForest.domains | ForEach-Object {$_.DomainControllers} | ForEach-Object {$_.Name}
#List of RODCs
$RODCs = Get-ADDomainController -Filter {IsReadOnly -eq $true} | ForEach-Object {$_.HostName}

Foreach ($Server in $DCServers){
$DCChecks = New-Object psobject -Property @{
Server = ""
RODC = ""
Ping =""
Netlogon=""
NTDS=""
DNS=""
Replications=""
FsmoCheck=""
Advertising=""
Services =""
NetLogons=""
}
    Write-Host "checking if $Server is a RODC"
    If ($RODCs -Match $Server) {
    Write-Host "YES"
    $DCChecks.Server = $Server
    $DCChecks.RODC = "Y"
    }
    ELSE {
    Write-Host "NO"
    $DCChecks.RODC = "N"
    
    $DCChecks.Server = $Server
    if (Test-Connection -ComputerName $Server -Count 4 -Quiet) {
    Write-Host "$Server--Ping OK" -ForegroundColor Green
    $DCChecks.Ping = "OK"
        #Checking DC Services Status
        foreach ($service in $Services){
        TRY {$servicestaus = Get-Service -ComputerName $Server | Where-Object {$_.Name -eq $service} -ErrorAction STOP
            If ($servicestaus.status -eq "Running") {
            $DCChecks.$Service = $servicestaus.status
            Write-Host "$Server--$Service is $($servicestaus.status)"-ForegroundColor Green} 
            ELSE {
            $DCChecks.$Service = $servicestaus.status
            }
            }
            CATCH {
            Write-Host "$Server--Issues with $Service" -ForegroundColor Red
            $DCChecks.$Service = "ERROR"
            }
        }
        #Checking DC replication
        foreach ($ReplCheck in $ReplChecks){
            #Dcdiag Replication Check
            Write-Verbose "Checking status of DCdiag $ReplCheck"
            $dcdiagchecks = dcdiag /test:$ReplCheck /s:$Server
            if ($dcdiagchecks -match "passed test $ReplCheck"){
            $DCChecks.$ReplCheck = "OK"
            }
            else {
            $DCChecks.$ReplCheck= "ERROR"
            }
        }
    }

    ELSE {
    Write-Host "$Server--Ping Failed" -ForegroundColor Red
    $DCChecks.Ping = "Failed" 
    }
  }
$LogData += $DCChecks | Select-Object Server,RODC,Ping,Netlogon,NTDS,DNS,Replications,FsmoCheck,Advertising,Services,NetLogons 
}
#Post HTML data
$RepDate = Get-Date -Format F
$PostHTML = "AD Checks performed on $env:COMPUTERNAME By "+ $env:USERNAME +" on " +$RepDate

$LogData | ConvertTo-Html -Head $HeaderTable -PreContent "<td><H1>$Subject</H1>" -PostContent "<td><H3>$PostHTML</H3>" | ForEach {$PSItem -replace "<td>ERROR</td>", "<td style='background-color:#FF8080'>ERROR</tb>"} | Out-File $OutputFile
$Body = Get-Content -Path $outputfile | Out-String
Send-MailMessage -From $From -To $To -Subject $Subject -SmtpServer $SmtpServer -Body $Body -BodyAsHtml 
