
$certADTemplatesOmit=@(
)

$ReportDate = Get-date -Format dd_MM_yyy 
$Reportname = ".\$ReportDate"+"-CA.csv"

$OmitList = [String]::Join(", CertificateTemplate >",$certADTemplatesOmit) 
$OmitList = "CertificateTemplate >" + $OmitList

#Define Date formats
[int]$ExpireDays = "30"
Get-Date -f 'M/d/yyyy h:mm tt'
$CurrentDate = Get-Date -f 'M/d/yyyy'
$SearchDate = (Get-date).AddDays($ExpireDays).ToString('M/d/yyyy')

$expiringCerts = certutil -view -restrict "NotAfter<=$SearchDate,NotAfter>=$CurrentDate,$OmitList" -out "RequestID, Commonname, Request.RequesterName, NotBefore,NotAfter,CertificateTemplate" csv

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

