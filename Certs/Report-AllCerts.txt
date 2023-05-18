<#
        .SYNOPSIS
        A function to extract expiring certificates.
 
        .DESCRIPTION
        The function establishes a connection to a Windows Certification Authority then exports expired certificates
        
        .PARAMETER ComputerName
        Name of the computer to of CA
 
        .PARAMETER Type
        Type of healthcheck. The default is "Certificates".
#>

[CmdletBinding()]
Param 
(   
[Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]
[ValidateNotNullOrEmpty()]
[String]$ComputerName = $env:COMPUTERNAME,

[Parameter(Mandatory=$false)]
[ValidateNotNullOrEmpty()]
[String]$Type = "Certificates",

[Parameter(Mandatory=$false)]
[ValidateNotNullOrEmpty()]
[Int]$CertificateExpireDays = "",

[Parameter(Mandatory=$false)]
[ValidateNotNullOrEmpty()]
[String[]]$IgnoreCertificates = ""

)
$ComputerName = "" 
$IgnoreCertificates=@(
)

$ReportDate = Get-date -Format dd_MM_yyy
$Reportname = ".\$ReportDate"+"_DOmain-CA.csv"

$OmitList = [String]::Join(", CertificateTemplate >",$IgnoreCertificates)
$OmitList = "CertificateTemplate >" + $OmitList

#Define Date formats
[int]$ExpireDays = "0"
Get-Date -f 'M/d/yyyy h:mm tt'
$CurrentDate = Get-Date -f 'M/d/yyyy'
$SearchDate = (Get-date).AddDays($CertificateExpireDays).ToString('M/d/yyyy')


$expiringCerts = certutil -config $ComputerName -view -restrict "$OmitList" -out "RequestID, Commonname, Request.RequesterName, NotBefore,NotAfter,CertificateTemplate" csv


$ExpiringCertsArray =@()

foreach ($item in $expiringCerts) {


[array]$Itemline = $item.Split(",") -replace ('"',"")
$Certdata = New-Object PSObject
$Certdata | Add-Member -MemberType NoteProperty -Name "RequestID" -Value $Itemline[0]
$Certdata | Add-Member -MemberType NoteProperty -Name "Commonname" -Value $Itemline[1]
$Certdata | Add-Member -MemberType NoteProperty -Name "RequesterName" -Value $Itemline[2]
$Certdata | Add-Member -MemberType NoteProperty -Name "NotBefore" -Value $Itemline[3]
$Certdata | Add-Member -MemberType NoteProperty -Name "NotAfter" -Value $Itemline[4]
$Certdata | Add-Member -MemberType NoteProperty -Name "CertificateTemplate" -Value $Itemline[5]

$ExpiringCertsArray += $Certdata 
}

$ExpiringCertsArray | Select RequestID,Commonname,RequesterName,NotBefore,NotAfter,CertificateTemplate | Select-Object -Skip 2 |Export-csv $Reportname -NoTypeInformation

$emailArray = @{
From =''
To =''
smtpserver = ''
Subject = "Certs - $(Get-date -f "dd-MM-yyyy")"
Attachments = $Reportname
Body = "The attachment contains a list of certificates from $(get-date -Format "dddd dd MMMM yyyy")"

}

Send-MailMessage @emailArray