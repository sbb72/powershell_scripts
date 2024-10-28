Function Get-CombineCSVFiles
{
    param (
        [string]$csvDirectory
    )
    

# Define the directory containing the CSV files
#$csvDirectory = "C:\Temp\Rightsizing_VMDSC"
# Define the directory containing the CSV files


# Get all CSV files in the directory
$csvFiles = Get-ChildItem -Path $csvDirectory -Filter *.csv

# Initialize a hashtable to store unique headers
$headers = @{}

# First pass: Collect all unique headers across all files
foreach ($csvFile in $csvFiles) {
    $csvData = Import-Csv -Path $csvFile.FullName
    foreach ($header in $csvData[0].PSObject.Properties.Name) {
        $headers[$header] = $true  # Store header names as keys to ensure uniqueness
    }
}

# Convert hashtable keys to an array of headers
$headers = $headers.Keys

# Initialize an array to hold combined data
$combinedData = @()

# Function to create a PSObject with all headers, adding cells based on specific criteria
function Create-ObjectWithHeaders {
    param (
        [array]$headers,
        [pscustomobject]$row
    )
    
    $object = New-Object PSObject
    foreach ($header in $headers) {
        # Retrieve the value from the row, or set to an empty string if missing
        $value = $row.$header

        # Check if the cell contains a numeric value and is greater than 0
        if ([double]::TryParse($value, [ref]$null)) {
            # If numeric, only add if greater than 0
            if ([double]$value -gt 0) {
                $object | Add-Member -MemberType NoteProperty -Name $header -Value $value
            } else {
                $object | Add-Member -MemberType NoteProperty -Name $header -Value ""
            }
        } elseif (![string]::IsNullOrEmpty($value)) {
            # If non-numeric, add if not empty
            $object | Add-Member -MemberType NoteProperty -Name $header -Value $value
        } else {
            # For missing or empty values, add as an empty string
            $object | Add-Member -MemberType NoteProperty -Name $header -Value ""
        }
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
#$combinedData | FT
    Return $combinedData | Sort-Object -Descending 'vCenter'
}
Get-CombineCSVFiles -csvDirectory "C:\Temp\Rightsizing_VMDSC\"
