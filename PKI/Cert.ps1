$Output = Get-CA -name "CA Cluster" | Get-IssuedRequest | Select RequestID, Commonname, NotAfter, CertificateTemplate | sort Notafter

$NoOfDays = 7

$Certs = Get-CA -name "CA Cluster" | Get-IssuedRequest | Select Commonname,RequestID, NotAfter, CertificateTemplate | Export-Csv C:\temp\cert.csv -NoTypeInformation

ForEach ($Item in $Certs) {
$c =$Item.Group | Sort notafter | Select-Object -Last 1 | Select-Object CommonName,notafter | Where {$_.notafter -gt $now.adddays($NoOfDays)}

}


ForEach ($Item in $Certs) {
$c =$Item.Group | Sort notafter | Select-Object -Last 1 | Select-Object @{Name="alreadyexpired";Expresssion={$_.notafter -lt $now}},` 
CommonName,notafter | Where {$_.notafter -gt $now.adddays($NoOfDays)}

}

 Get-CA -name "CA_NAme" | Get-IssuedRequest -RequestID 36 | Select-Object -Property *