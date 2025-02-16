# PowerShell Script to Import CSV into Elasticsearch (Handles "NR", Adds Timestamp, Avoids Index Creation Error)

# Variables
$CsvPath = "D:\Temp\Regional_Steels_August_Monthly_Medal__NettScoreSheet_12_02_2025.csv"
$ElasticsearchURL = "https://192.168.0.110:9200"
$IndexName = "competition_results"
$ApiKey = "bWVkVi01UUJCcVZ0bHlaSS1tN2o6M1B6a19OVUlRNHlrak0xdXBpcDdlUQ=="

# Ignore SSL Certificate Validation
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

# Headers for API Key authentication
$Headers = @{
    "Authorization" = "ApiKey $ApiKey"
    "Content-Type"  = "application/json"
}

# Check if Index Already Exists
try {
    $IndexCheck = Invoke-RestMethod -Uri "$ElasticsearchURL/$IndexName" -Method Get -Headers $Headers -ErrorAction Stop
    Write-Host "Index '$IndexName' already exists. Proceeding with data import..."
} catch {
    Write-Host "Index '$IndexName' does not exist. Creating..."
    
    # Create Index with Mapping
    $Mapping = @{
        settings = @{
            number_of_shards   = 1
            number_of_replicas = 0
        }
        mappings = @{
            properties = @{
                Pos         = @{ type = "keyword" }
                Name        = @{ type = "text" }
                Gross       = @{ type = "integer" }
                Hcp         = @{ type = "float" }
                Nett        = @{ type = "integer" }
                NewExact    = @{ type = "float" }
                imported_at = @{ type = "date" }
            }
        }
    } | ConvertTo-Json -Depth 10

    Invoke-RestMethod -Uri "$ElasticsearchURL/$IndexName" -Method Put -Headers $Headers -Body $Mapping
    Write-Host "Index '$IndexName' created successfully."
}

# Read CSV and Filter Data
$CsvData = Import-Csv -Path $CsvPath | Where-Object { $_.Pos -match "^\d+$" }  # Exclude division headers

# Function to Convert Values Safely
function Convert-ToNumber {
    param ($Value, $Type = "int")
    if ($Value -match "^\d+(\.\d+)?$") {
        if ($Type -eq "int") { return [int]$Value }
        if ($Type -eq "float") { return [float]$Value }
    }
    return $null  # Return null for invalid numbers (e.g., "NR")
}

# Get Current UTC Time in ISO 8601 Format
$Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

# Build Bulk JSON Payload (Ensure newline at the end)
$BulkData = ""
foreach ($row in $CsvData) {
    $IndexAction = @{ index = @{ _index = $IndexName } } | ConvertTo-Json -Compress
    $Document = @{
        Pos         = Convert-ToNumber -Value $row.Pos -Type "int"
        Name        = $row.Name
        Gross       = Convert-ToNumber -Value $row.Gross -Type "int"
        Hcp         = Convert-ToNumber -Value $row.Hcp -Type "float"
        Nett        = Convert-ToNumber -Value $row.Nett -Type "int"
        NewExact    = Convert-ToNumber -Value $row.NewExact -Type "float"
        imported_at = $Timestamp  # Add import timestamp
    } | ConvertTo-Json -Compress
    $BulkData += "$IndexAction`n$Document`n"  # Append newline after each document
}

# Ensure the payload ends with a newline
$BulkPayload = $BulkData.TrimEnd() + "`n"

# Bulk Import Data
Invoke-RestMethod -Uri "$ElasticsearchURL/_bulk" -Method Post -Headers $Headers -Body $BulkPayload

Write-Host "Data import completed successfully!"
