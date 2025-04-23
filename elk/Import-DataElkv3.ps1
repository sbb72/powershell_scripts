Import-Module D:\gitlab-work\iSolve-Powershell-Module\DXC-iSolve\DXC-iSolve.psd1 -Force

$directory_input_files = "D:\Temp\2025_Comps"
$input_files = Get-ChildItem -Path $directory_input_files -Filter *.csv 
$Responses = New-Object System.Collections.ArrayList

# Function to parse date string into UTC ISO format
function Get-DateFromString {
    param (
        [string]$DateString
    )
    $DateFormats = @("dd/MM/yyyy", "MM/dd/yyyy", "dd-MM-yyyy", "MM-dd-yyyy", "dd.MM.yyyy", "MM.dd.yyyy")
    foreach ($Format in $DateFormats) {
        try {
            $DateTime = [DateTime]::ParseExact($DateString, $Format, $null, [System.Globalization.DateTimeStyles]::None)
            return [DateTime]::SpecifyKind($DateTime, [System.DateTimeKind]::Utc).ToString("yyyy-MM-ddTHH:mm:ssZ")
        } catch {
            continue
        }
    }
    throw "Unrecognized date format: $DateString"
}

# Function to parse metadata from filename
function Parse-FileMetadata {
    param (
        [string]$FileName
    )

    # Remove .csv extension
    $fileBase = [System.IO.Path]::GetFileNameWithoutExtension($FileName)

    # Attempt to extract name and date with regex
    if ($fileBase -match "^(?<Name>.+?)_(?<Date>\d{2}[_\-\.]\d{2}[_\-\.]\d{4})$") {
        $name = $matches['Name']
        $rawDate = $matches['Date'] -replace "_", "-"  # Normalize delimiters

        $dateParts = $rawDate -split "-"
        $year = $dateParts[2]
        $month = $dateParts[1].PadLeft(2, '0')

        $compDate = Get-DateFromString -DateString $rawDate

        return @{ 
            CompetitionName = $name
            Year = $year
            Month = $month
            CompetitionDate = $compDate
        }
    } else {
        throw "❌ Unable to extract metadata from filename: $FileName"
    }
}


# Define classification logic
$classification = @{
    "Monthly Medal" = { param($meta) "monthlymedals-$($meta.Year)-$($meta.Month)" }
    "Major"         = { param($meta) "majors_$($meta.Year)" }
    "Wednesday"     = { param($meta) "wednesday-$($meta.Year)-$($meta.Month)" }
    "Winter"        = { param($meta) "winter_league-$($meta.Year)-$($meta.Month)" }
}

# Main import loop
foreach ($file in $input_files) {
    $matched = $false
    foreach ($key in $classification.Keys) {
        if ($file.Name -match $key) {
            try {
                $meta = Parse-FileMetadata -FileName $file.Name
                $IndexName = & $classification[$key] $meta
                Write-Host "📄 Processing '$($file.Name)' → Index: '$IndexName', Competition: '$($meta.CompetitionName)'"

                $CsvData = Import-Csv -Path $file.FullName | Where-Object { $_.Pos -match "^\d+$" }
                $Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

                foreach ($row in $CsvData) {
                    $Document = @{
                        CompetitionName = $meta.CompetitionName
                        CompetitionDate = $meta.CompetitionDate
                        Division        = $row.Division
                        Pos             = $row.Pos
                        Name            = $row.Name
                        Gross           = $row.Gross
                        Hcp             = $row.Hcp
                        Nett            = $row.Nett
                        imported_at     = $Timestamp
                    }
                    $Responses += $Document
                }

                try {
                    $Responses | Import-ElasticsearchDataBulk -Index $IndexName -Type "event" -ElasticsearchURL "https://192.168.0.110:9200" -ElasticsearchUser elastic -ElasticsearchV8OrLater -Verbose
                } catch {
                    Write-Error "❌ Failed to import data for '$($file.Name)' into Elasticsearch: $_"
                }

                $Responses.Clear()
                $matched = $true
                break
            } catch {
                Write-Error "❌ Error processing '$($file.Name)': $_"
                break
            }
        }
    }

    if (-not $matched) {
        Write-Warning "⚠️ File '$($file.Name)' does not match any known competition types. Skipping."
    }
}
