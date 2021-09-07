
<#
#A list of function used in Y30 to help send data to Greenlnk
#Script creation
#Import-Module D:\Scripts\UsefulFunctionsv1.psm1
#Get-LatestfileToSend -PathtoCheck "D:\HealthChecks\Reports" -PartofFileName "skype-service_results"

#v1 - Added switch to search part of a file name

RUN THIS IN A SCRIPT

$Attachment = Get-LatestfileToSend -Pathtocheck D:\Temp

Get-SecureSendMail -EmailAttachment $Attachment

#>
Function Get-LatestfileToSend {
  <#
    .SYNOPSIS
    A function to find the latest version of a file in a specified directory 

    .DESCRIPTION
    A function to find the latest version of a file in a specified directory, extension and path can be given as a switch
            
    .PARAMETER PathtoCheck
    Path to directory you want to check

    .PARAMETER FileExtension
    The extension you want to query, default is csv

    .EXAMPLE
    PS C:\> Get-LatestfileToSend -PathtoCheck "D:\Temp" -FileExtension "pdf"
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$PathtoCheck,
                
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String]$PartofFileName = "",

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String]$FileExtension = "csv" 
        
     )

$DirtoCheck = Get-ChildItem $PathtoCheck -Recurse -file "*$PartofFileName*.$FileExtension" | Sort-Object LastWriteTime -Descending
$latestfile = $DirtoCheck | Sort-Object LastWriteTime | Select Fullname -Last 1

    If ($latestfile) {

    Write-Verbose "Latest file is $($latestfile.FullName)"

    }
    Else {

    Write-Verbose "No File Found $($_.Exception.Message)"

    }

Return $($latestfile.FullName)

}

Function Get-SecureSendMail {

    <#
    .SYNOPSIS
    A function to send mail requiring a certificate.

    .DESCRIPTION
    This function will enable to call and send multiple emails easily.
    Let the sending from  email details hard coded as this will be unique per domain account
    Can be more flexible later if required. 

    .PARAMETER EmailAttachment
    Full path including file name to file

    .PARAMETER SubjectTitle
    Subject of the email 

    .PARAMETER strTo
    To email address to send email to

    .PARAMETER strToAlias
    Alias of email address to send email to

    .PARAMETER FullPathTo_CpiNetSecureMaildll
    Full path to dotNet secure email dll
                
    .EXAMPLE
    PS C:\> Get-SecureSendMail -EmailAttachment "D:\Temp\Test.csv"
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$EmailAttachment,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String]$SubjectTitle,
        
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$strTo = "csc.remotesupport@baesystems.com",

        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$strToAlias = "remote support",

        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$FullPathTo_CpiNetSecureMaildll = "D:\Send_Reports\Cpi.Net.SecureMail.dll"
 
     )

#Delele after testing
#[string]$strTo          = "csc.remotesupport@baesystems.com" 
#[string]$strToAlias     = "remote support"                 
#$MsgAttachement1        = $EmailAttachment
#$MySubject              = $SubjectTitle 
#$FullPathTo_CpiNetSecureMaildll = "D:\SBarker_Test\Scripts\Cpi.Net.SecureMail.dll"

#Leaving these hard coded
[string]$signingCertThumbprint = "B043DAC1192938E56236D5DBB0A2D8203E96923B"
[string]$strFrom        = "zzservice.xhfohd@yellowlnk.net"
[string]$strFromAlias   = "zzservice xhfohd" 
[string]$strSmtpServer  = "10.180.192.103"
[string]$strSmtpPort    = "25"

$objCert = Get-childItem Cert:\CurrentUser\my | where {$_.Thumbprint -eq $signingCertThumbprint}
[System.Reflection.Assembly]::LoadFile($FullPathTo_CpiNetSecureMaildll) |Out-Null
[String]$strSubject      = $SubjectTitle
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
$objMail.Attachments.Add($EmailAttachment)
$objSMTPClient = New-Object System.Net.Mail.SmtpClient($strSmtpServer,$strSmtpPort)
$objSMTPClient.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
write-host ("Sending message with subject : " + $SubjectTitle )
$objSMTPClient.send($objMail)

}

Function Get-RemoveIPsfromFile {
<#
    .SYNOPSIS
    A script to check IPs in a file and replace with x.x.x.x

    .DESCRIPTION
    A function to find all IPs in a file and replace them. It save the file and appends the file name with _IPRemoved.
    So a file named 'Test01012001.csv' will be save after the check as 'Test01012001_IPRemoved.csv'.
            
    .PARAMETER PathtoFile
    Path to file you want to remove IPs
    
    .EXAMPLE
    PS C:\> Get-LatestfileToSend -PathtoCheck "D:\Temp" -FileExtension "pdf"
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$PathtoFile
        
     )


$FileWithoutIPs = $PathtoFile.Split(".")[0] + "_IPRemoved." +$PathtoFile.Split(".")[1]

$IPRegex = "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"

$listIPs = Get-Content $PathtoFile | Select-String -Pattern $IPRegex -AllMatches | % { $_.Matches } | % {$_.value}

$file = Get-Content $PathtoFile
foreach ($IP in $listips) {
  $file = $file -replace $IP, "x.x.x.x"
}
Set-Content -Path $FileWithoutIPs -Value $file

}