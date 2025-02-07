$StartScript = (Get-Date)
Write-Host "Script started at '$StartScript'" 


# Path to the input CSV file
$inputCsvPath = 'C:\Temp\script-test\1-26-25 DXC  Rightsizing   Undersized  MDS  GLK Automation_Maidstone.csv'

# Path to save the output CSV file
$outputCsvPath = "C:\Temp\script-test\outputv_servers_Undersized.csv"

$servers = Get-Content -Path 'C:\Temp\script-test\ServerList.txt'

# Read the CSV file
Write-Host "Importing '$inputCsvPath '"

$data = Import-Csv -Path $inputCsvPath

# Filter the rows
$filteredData = $data | Where-Object {
    #Write-Host "removing data"
    # Parse the timestamp from the current row
    $timestamp = Get-Date $_.'Interval Breakdown' # Adjust 'Timestamp' to match your CSV's column name

    # Extract the day of the week (0 = Sunday, 6 = Saturday)
    $dayOfWeek = $timestamp.DayOfWeek

    # Extract the time portion
    $timeOnly = $timestamp.TimeOfDay

    # Define the time range (08:00:00 - 18:00:00)
    $startTime = [TimeSpan]::Parse("08:00:00")
    $endTime = [TimeSpan]::Parse("18:00:00")

    # Keep rows within the time range
   # $timeOnly -ge $startTime -and $timeOnly -le $endTime

    # Keep rows only if they are within the time range and not on Saturday or Sunday
    #($timeOnly -ge $startTime -and $timeOnly -le $endTime) -and ($dayOfWeek -ne "Saturday" -and $dayOfWeek -ne "Sunday")

    <# for 8till6
    ($timeOnly -ge $startTime -and $timeOnly -le $endTime) -and 
    ($dayOfWeek -ne "Saturday" -and $dayOfWeek -ne "Sunday") -and 
    ($servers -contains $_.Name)
    #>
    #24-7
    $servers -contains $_.Name
}

# Save the filtered data to a new CSV file
$filteredData | Export-Csv -Path $outputCsvPath -NoTypeInformation

Write-Host "Filtered data saved to $outputCsvPath"

$EndScript = (Get-Date)
$TimeToRun = New-Timespan -start $StartScript -End $EndScript
Write-Host "Script took '$($TimeToRun.Hours)'Hours, '$($TimeToRun.Minutes)Mins', '$($TimeToRun.Seconds)Secs'" 