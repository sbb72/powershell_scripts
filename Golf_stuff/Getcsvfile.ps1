$foldername = "C:\Users\Scott\Downloads\Wood_Bowl_(Major)_NettScoreSheet_15_03_2024.csv"

$csvdata = Import-csv -Path $foldername 






$csvTeeBox | Select-Object Filename

$csvdata | Where-Object {$_.'Date:' -match $searchTerm -or $_.system -match $searchTerm} |Select-Object -Expand Name


$Test = $csvDate.ToString().Split(';') | Select-String Name

#Get date of comp from csv file
$csvDate = $csvdata | select-string "Date:" 
$Test = $csvDate.ToString().Split(';') | Select-String Name
$Test.ToString("dd-MM-yyyy").Split('=')[1]
Get-Date $Test.ToString("dd-MM-yyyy").Split('=')[1] -Format 'dd-MM-yyyy'

#Format of play
$csvGameFormat = $csvdata | select-string 'Score Type:'
$csvGameFormat  = $csvGameType.ToString().Split(';') | Select-String Name
$csvGameFormat = $csvGameFormat.ToString().Split('=')[1]

#Tee
$csvTeeBox = $csvdata | select-string 'Course/Tee:'
$csvTeeBox  = $csvTeeBox.ToString().Split(';') | Select-String Name
$csvTeeBox = $csvTeeBox.ToString().Split('=')[1]