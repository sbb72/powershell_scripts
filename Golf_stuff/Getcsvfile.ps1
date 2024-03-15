$foldername = "C:\Users\Scott\Downloads\Wood_Bowl_(Major)_NettScoreSheet_15_03_2024.csv"

$csvdata = Import-csv -Path $foldername 



$csvGameType = $csvdata | select-string 'Score Type:'

$csvTeeBox = $csvdata | select-string 'Course/Tee:'

$csvTeeBox | Select-Object Filename

$csvdata | Where-Object {$_.'Date:' -match $searchTerm -or $_.system -match $searchTerm} |Select-Object -Expand Name


$Test = $csvDate.ToString().Split(';') | Select-String Name

#Get date of comp from csv file
$csvDate = $csvdata | select-string "Date:" 
#$date1 = $Test.ToString("dd-MM-yyyy").Split('=')[1]

Get-Date $Test.ToString("dd-MM-yyyy").Split('=')[1] -Format 'dd-MM-yyyy'

PS> $date = '24 June 2012 00:00:00'
PS> Get-Date $date -Format 'dd/MM/yyyy'
24/06/2012