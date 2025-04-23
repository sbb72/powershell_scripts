$folderPath = "D:\Temp\Majors_2023"
$outputFile = "D:\Temp\MergedFile_Majors2022.csv"

# Get all CSV files in the folder
$files = Get-ChildItem -Path $folderPath -Filter "*.csv"

# Read and merge the files
$mergedData = foreach ($file in $files) {
    $fileData = Import-Csv $file.FullName

    # Extract filename parts (before first "_")
    $filePart = $file.BaseName -split "_" | Select-Object -First 1
    If ($file.BaseName -match 'Medal') {
        $month = $file.BaseName -split " " | Select-Object -First 1    
    }
    $compdate = $file.BaseName -split "_" | Select-Object -last 1

    # Add columns for filename and month
    $fileData | ForEach-Object { 
        $_ | Add-Member -NotePropertyName "Competition" -NotePropertyValue $filePart -PassThru 
    } | ForEach-Object {
        $_ | Add-Member -NotePropertyName "Month" -NotePropertyValue $month -PassThru
    }| ForEach-Object {
        $_ | Add-Member -NotePropertyName "CompetitionDate" -NotePropertyValue $compdate -PassThru
    }
}

# Export merged data to a new CSV file
$mergedData | Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "Merge complete! Output file: $outputFile"

