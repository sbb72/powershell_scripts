
$certADTemplatesOmit=@(
"1.3.6.1.4.1.311.21.8.11689746.5359023.7621305.12837275.9531266.235.5057969.16776334",#Secure Wireless End User Device Non TPM "1.3.6.1.4.1.311.21.8.11689746.5359023.7621305.12837275.9531266.235.2695394.7509637",#"Secure Wireless End User Device RBSL Non TPM"
"1.3.6.1.4.1.311.21.8.11689746.5359023.7621305.12837275.9531266.235.853955.11824657",#"Secure Wireless End User Device RBSL Non TPM v2"
"1.3.6.1.4.1.311.21.8.11689746.5359023.7621305.12837275.9531266.235.3642223.15958363",#"Secure Wireless End User Device RBSL with TPM"
"1.3.6.1.4.1.311.21.8.11689746.5359023.7621305.12837275.9531266.235.1379587.4772709",#"Secure Wireless End User Device RBSL with TPM v2"
"1.3.6.1.4.1.311.21.8.11689746.5359023.7621305.12837275.9531266.235.267646.2202633",#"Secure Wireless End User Device with TPM"
"1.3.6.1.4.1.311.21.8.11689746.5359023.7621305.12837275.9531266.235.748348.5893723",#"WinRM"
"1.3.6.1.4.1.311.21.8.11689746.5359023.7621305.12837275.9531266.235.3402091.3622159",#"WinRM SOE Template"
"1.3.6.1.4.1.311.21.8.11689746.5359023.7621305.12837275.9531266.235.8185495.12102405",#"DigitalDocsignV1"
"1.3.6.1.4.1.311.21.8.11689746.5359023.7621305.12837275.9531266.235.13450465.9399453"#"DigitalDocsignWin7V1"
)

$ReportDate = Get-date -Format dd_MM_yyy 
$Reportname = ".\$ReportDate"+"_Greenlnk-CA.csv"

$OmitList = [String]::Join(", CertificateTemplate >",$certADTemplatesOmit) 
$OmitList = "CertificateTemplate >" + $OmitList

#Define Date formats
[int]$ExpireDays = "30"
Get-Date -f 'M/d/yyyy h:mm tt'
$CurrentDate = Get-Date -f 'M/d/yyyy'
$SearchDate = (Get-date).AddDays($ExpireDays).ToString('M/d/yyyy')

$expiringCerts = certutil -view -restrict "NotAfter<=$SearchDate,NotAfter>=$CurrentDate,$OmitList" -out "RequestID, Commonname, Request.RequesterName, NotBefore,NotAfter,CertificateTemplate" csv #>C:\SUPPORT\SBarker\TestArraywithdate.csv

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
smtpserver = ""
Subject = "Certs Expiring $(Get-date -f "dd-MM-yyyy")"
Attachments = $Reportname
Body = "The attachment contains a list of certificates due to expire within $ExpireDays Days of $(get-date -Format "dddd dd MMMM yyyy")"

}

Send-MailMessage @emailArray

