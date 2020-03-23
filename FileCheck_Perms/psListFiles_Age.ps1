
Get-ChildItem C:\Temp\ -recurse | Where-Object {$_.PSIsContainer -and $_.CreationTime -gt (Get-Date).AddDays(-1) -or $_.LastWriteTime -gt (Get-Date).AddDays(-1)} | 
Select-Object FullName, CreationTime, @{Name="Mbytes";Expression={$_.Length/1Kb}}, @{Name="Age";Expression={(((Get-Date) - $_.CreationTime).Days)}} | 
Export-Csv C:\search_TXT-and-PDF_files_01012013-to-12022014_sort.txt


Get-ChildItem C:\Temp\ -recurse | Where-Object {$_.PSIsContainer -and $_.CreationTime -gt (Get-Date).AddDays(-1) -or $_.LastWriteTime -gt (Get-Date).AddDays(-1)} | 
Select-Object FullName, CreationTime, LastWriteTime | Export-Csv -Path .\Test.csv -NoTypeInformation


$DateLess = "1"
$item = "C:\Temp"
$params = New-Object System.Collections.Arraylist
$params.AddRange(@("/L","/S","/NJH","/BYTES","/FP","/NC","/NDL","/TS","/XJ", "/MAXAGE:$DateLess","/R:0","/W:0"))
$countPattern = "^\s{3}Files\s:\s+(?<Count>\d+).*"
$sizePattern = "^\s{3}Bytes\s:\s+(?<Size>\d+(?:\.?\d+)\s[a-z]?).*"
((robocopy $item NULL $params)) | ForEach {
    If ($_ -match "(?<Size>\d+)\s(?<Date>\S+\s\S+)\s+(?<FullName>.*)") {
        New-Object PSObject -Property @{
            FullName = $matches.FullName
            Size = $matches.Size
            Date = [datetime]$matches.Date
            LastWriteTime = [datetime]$matches.Date
        }
    } Else {
        Write-Verbose ("{0}" -f $_)
    }
} | Export-CSV C:\Support\Test.csv -NoTypeInformation