#TODO
#Create module to send mails
#Crteate module to scan for IPs
#Get latest report Module


#Get latest xHF report
$xhfReport = Get-ChildItem "\\y30as0183v\d$\xHF\Results" -Recurse -file *.csv | Sort-Object LastWriteTime -Descending
$latestfile = $xhfReport | Sort-Object LastWriteTime | Select Fullname -Last 1
Write-Host "Latest file is $($latestfile.FullName)"

[string]$strTo          = "csc.remotesupport@baesystems.com" 
[string]$strToAlias     = "remote support"                 

$MsgAttachement1        = $($latestfile.FullName)
$MySubject              = "xHF Reports" 

$FullPathTo_CpiNetSecureMaildll = "D:\SBarker_Test\Scripts\Cpi.Net.SecureMail.dll"

$signingCertThumbprint = "B043DAC1192938E56236D5DBB0A2D8203E96923B"

[string]$strFrom        = "zzservice.xhfohd@yellowlnk.net"
[string]$strFromAlias   = "zzservice xhfohd" 
[string]$strSmtpServer  = "mail.yellowlnk30.net"
[string]$strSmtpPort    = "25"
$objCert = Get-childItem Cert:\CurrentUser\my | where {$_.Thumbprint -eq $signingCertThumbprint}
[System.Reflection.Assembly]::LoadFile($FullPathTo_CpiNetSecureMaildll) |Out-Null
[String]$strSubject      = $MySubject
[string]$strBody        = "TLPropertyRoot=YELLOWLNK30;Classification=NATO UNCLASSIFIED;" + "`n`rSecond line of Message body"  
$objMail = New-Object Cpi.Net.SecureMail.SecureMailMessage
$objFrom = New-Object Cpi.Net.SecureMail.SecureMailAddress($strFrom,$strFromAlias,$objCert,$objCert)
$objTo   = New-Object Cpi.Net.SecureMail.SecureMailAddress($strTo,$strToAlias)
$objMail.From = $objFrom
$objMail.to.Add($objTo)
$objMail.Subject = $strSubject
$objMail.Body = $strBody
$objMail.IsBodyHtml = $False
$objMail.IsSigned = $True
$objMail.IsEncrypted = $FALSE
$objMail.Attachments.Add($MsgAttachement1)
$objSMTPClient = New-Object System.Net.Mail.SmtpClient($strSmtpServer,$strSmtpPort)
$objSMTPClient.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
write-host ("Sending message with subject : " + $MySubject )
$objSMTPClient.send($objMail)
