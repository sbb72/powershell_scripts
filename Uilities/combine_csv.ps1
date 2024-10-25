Function Get-CombineCSVFiles
{
    param (
        [string]$csvDirectory
    )
    

# Define the directory containing the CSV files
#$csvDirectory = "C:\Temp\Rightsizing_VMDSC\"

# Get all CSV files in the directory
$csvFiles = Get-ChildItem -Path $csvDirectory -Filter *.csv

# Initialize an array to hold combined headers
$headers = @()

# First pass: Collect all unique headers across all files
foreach ($csvFile in $csvFiles) {
    $csvData = Import-Csv -Path $csvFile.FullName
    $headers += $csvData[0].PSObject.Properties.Name
}

# Remove duplicates from headers
$headers = $headers | Select-Object -Unique

# Initialize an array to hold combined data
$combinedData = @()

# Function to create a PSObject with all headers and populate missing values as empty strings
function Create-ObjectWithHeaders {
    param (
        [array]$headers,
        [pscustomobject]$row
    )
    
    $object = New-Object PSObject
    foreach ($header in $headers) {
        # Use the value if it exists in row; otherwise, set to empty string
        $object | Add-Member -MemberType NoteProperty -Name $header -Value ($row.$header -as [string])
    }
    return $object
}

# Second pass: Populate combinedData with data from each CSV file
foreach ($csvFile in $csvFiles) {
    $csvData = Import-Csv -Path $csvFile.FullName

    # Add each row of data to the combined data array
    foreach ($row in $csvData) {
        $combinedData += Create-ObjectWithHeaders -headers $headers -row $row
    }
}

# Output the combined array
    Return $combinedData | Sort-Object -Descending 'vCenter' | Format-Table
}

Get-CombineCSVFiles -csvDirectory "C:\Temp\Rightsizing_VMDSC\"