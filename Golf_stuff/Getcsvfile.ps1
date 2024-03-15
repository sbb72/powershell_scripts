$foldername = "C:\Temp\Wood_Bowl_(Major)_NettScoreSheet_15_03_2024 (2).csv"

$csvdata = Import-csv -Path $foldername 

$csvDate = $csvdata | select-string "Date:" 

$csvGameType = $csvdata | select-string 'Score Type:'

$csvTeeBox = $csvdata | select-string 'Course/Tee:'

$csvTeeBox | Select-Object Filename

$csvdata | Where-Object {$_.'Date:' -match $searchTerm -or $_.system -match $searchTerm} |Select-Object -Expand Name


$Test = $csvDate.ToString().Split(';') | Select-String Name

$Test