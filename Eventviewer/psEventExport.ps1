Get-EventLog -LogName System -After "28/12/2016" -Before "23/12/2016" | Where-Object {$_.EntryType -like 'Error' -or $_.EntryType -like 'Warning'} | export-csv c:\Temp\test.csv

Get-EventLog -LogName System -After "28/12/2016" -Before "23/12/2016" | Where-Object {$_.EventID -eq '4624'} | export-csv c:\Temp\test.csv