# Yasin Kara (DXC) (March 2020)
#####################################################
###UPDATE SMTP OPTIONS ON EACH DOMAIN AS REQUIRERD###
#####################################################

#set the filename for the extract
$filename = $PSScriptRoot+"\"+$env:userdomain+"_Servers_AD_Extract_"+$(get-date -f dd.MM.yyyy)+".csv"

#Setup SMTP email parameters that will be used for emailing
$options = @{
    'SmtpServer' = "apprelay.des.grplnk.net" 
    'From' = "$env:userdomain-AD-Servers@leonardocompany.com"
    'To' = "csc.remotesupport@leonardocompany.com, pmabbott@dxc.com"
    'Subject' = "$env:userdomain Servers AD Extract ($(get-date -f dd/MM/yyyy))"
    'Attachments' = $filename
}

#Tidy up execution logs and previous reports older than 10 days so it doesnt eventually fill the drive
(Get-ChildItem $PSScriptRoot | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-10))}) | Remove-Item -include *_Servers_AD_Extract_*.csv,*_Servers_AD_Extract_PoSHScriptExecutionLog_*.txt -Recurse

#Imprt AD module and cmcdlet
Import-Module ActiveDirectory -Cmdlet get-adcomputer

#run the ad query
get-adcomputer -filter {operatingsystem -like "*server*"} -property CanonicalName,Created,Description,IPv4Address,LastLogonDate,Location,OperatingSystem,OperatingSystemServicePack,OperatingSystemVersion | Select-object Name,Enabled,LastLogonDate,IPv4Address,Created,Location,OperatingSystem,OperatingSystemServicePack,OperatingSystemVersion,@{name="CanonicalName";Expression={(split-path $_."CanonicalName")}},Description | Sort-Object Name | Export-CSV $filename -NoTypeInformation

#Send email to CSC Remote Support with Attachment
Send-MailMessage @options

#Create the Bionix execution log file
$log = $PSScriptRoot+"\"+$env:userdomain+"_Servers_AD_Extract_PoSHScriptExecutionLog_"+$(get-date -f dd.MM.yyyy)+".txt"
"$(Get-date): process started." | out-file $log

#Send the email with the execution log attached to the Bionix Execution channel 
Send-MailMessage -to '9e8ef572.CSCPortal.onmicrosoft.com@amer.teams.ms' -From $options.From -SmtpServer $options.smtpserver -Subject "Execution Log: Daily $env:userdomain Server AD Extract" -Body "Please find attached the execution log for the Powershell script" -Attachments $log