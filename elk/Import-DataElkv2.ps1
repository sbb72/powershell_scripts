Import-module D:\gitlab-work\iSolve-Powershell-Module\DXC-iSolve\DXC-iSolve.psd1 -Force

$directory_input_files = "D:\Temp\2025_Comps"
$input_files = Get-ChildItem -Path $directory_input_files -Filter *.csv 

$Responses = New-Object System.Collections.Arraylist

$input_files | ForEach-Object {
  
    If ($_.Name -match 'Monthly Medal') {
        $CompetitionName = $_.Name.Split("_")[0]
        $Year = ((($_.Name.Split("_")[1]).Split(".")[0]).Split("-"))[2].ToString()
        $Month = ($_.Name.Split("_").Split("-")[2])
        $IndexName = "monthlymedals-$Year-$Month"
        #$IndexName = "monthly_medals_$Year"
        Write-Host "File name '$($_.Name)', Index name '$IndexName', Competition Name '$CompetitionName'"

        $DateString = (($_.Name.Split("_")[1]).Split(".")[0])

        # Define possible formats
        $DateFormats = @("dd/MM/yyyy", "MM/dd/yyyy", "dd-MM-yyyy", "MM-dd-yyyy", "dd.MM.yyyy", "MM.dd.yyyy")

        # Try parsing using multiple formats
        foreach ($Format in $DateFormats) {
            try {
                # Parse date as LOCAL
                $DateTime = [DateTime]::ParseExact($DateString, $Format, $null, [System.Globalization.DateTimeStyles]::None)

                # Convert to UTC **without shifting the day**
                $CompetitionDate = [DateTime]::SpecifyKind($DateTime, [System.DateTimeKind]::Utc).ToString("yyyy-MM-ddTHH:mm:ssZ")

                #Write-Host "âœ… Original: $DateString â†’ UTC: $UtcDate"
                break
            } catch {
                continue
            }
        }

    } 
    ElseIf ($_.Name -match 'Major') {
        
        $CompetitionName = $_.Name.Split("_")[0]
        $Year = ((($_.Name.Split("_")[2]).Split(".")[0]).Split("-"))[2]
        $IndexName = "majors_$Year"
        Write-Host "File name '$($_.Name)', Index name '$IndexName', Competition Name '$CompetitionName'"

        $DateString = (($_.Name.Split("_")[1]).Split(".")[0])

        # Define possible formats
        $DateFormats = @("dd/MM/yyyy", "MM/dd/yyyy", "dd-MM-yyyy", "MM-dd-yyyy", "dd.MM.yyyy", "MM.dd.yyyy")

        # Try parsing using multiple formats
        foreach ($Format in $DateFormats) {
            try {
                # Parse date as LOCAL
                $DateTime = [DateTime]::ParseExact($DateString, $Format, $null, [System.Globalization.DateTimeStyles]::None)

                # Convert to UTC **without shifting the day**
                $CompetitionDate = [DateTime]::SpecifyKind($DateTime, [System.DateTimeKind]::Utc).ToString("yyyy-MM-ddTHH:mm:ssZ")

                #Write-Host "âœ… Original: $DateString â†’ UTC: $UtcDate"
                break
            } catch {
                continue
            }
        }
    }
    ElseIf ($_.Name -match 'Wednesday') {
        
        $CompetitionName = $_.Name.Split("_")[0]
        $Year = ((($_.Name.Split("_")[2]).Split(".")[0]).Split("-"))[2]
        $Month = ($_.Name.Split("_").Split("-")[2])
        $IndexName = "winter_league-$Year-$Month"
        Write-Host "File name '$($_.Name)', Index name '$IndexName', Competition Name '$CompetitionName'"

        $DateString = (($_.Name.Split("_")[1]).Split(".")[0])

        # Define possible formats
        $DateFormats = @("dd/MM/yyyy", "MM/dd/yyyy", "dd-MM-yyyy", "MM-dd-yyyy", "dd.MM.yyyy", "MM.dd.yyyy")

        # Try parsing using multiple formats
        foreach ($Format in $DateFormats) {
            try {
                # Parse date as LOCAL
                $DateTime = [DateTime]::ParseExact($DateString, $Format, $null, [System.Globalization.DateTimeStyles]::None)

                # Convert to UTC **without shifting the day**
                $CompetitionDate = [DateTime]::SpecifyKind($DateTime, [System.DateTimeKind]::Utc).ToString("yyyy-MM-ddTHH:mm:ssZ")

                #Write-Host "âœ… Original: $DateString â†’ UTC: $UtcDate"
                break
            } 
            catch {
                continue
            }
        }
    }
    ElseIf ($_.Name -match 'Winter') {
        
        $CompetitionName = $_.Name.Split("_")[0]
        $Year = ((($_.Name.Split("_")[2]).Split(".")[0]).Split("-"))[2]
        $Month = ($_.Name.Split("_").Split("-")[2])
        $IndexName = "winter_league-$Year-$Month"
        Write-Host "File name '$($_.Name)', Index name '$IndexName', Competition Name '$CompetitionName'"

        $DateString = (($_.Name.Split("_")[1]).Split(".")[0])

        # Define possible formats
        $DateFormats = @("dd/MM/yyyy", "MM/dd/yyyy", "dd-MM-yyyy", "MM-dd-yyyy", "dd.MM.yyyy", "MM.dd.yyyy")

        # Try parsing using multiple formats
        foreach ($Format in $DateFormats) {
            try {
                # Parse date as LOCAL
                $DateTime = [DateTime]::ParseExact($DateString, $Format, $null, [System.Globalization.DateTimeStyles]::None)

                # Convert to UTC **without shifting the day**
                $CompetitionDate = [DateTime]::SpecifyKind($DateTime, [System.DateTimeKind]::Utc).ToString("yyyy-MM-ddTHH:mm:ssZ")

                #Write-Host "âœ… Original: $DateString â†’ UTC: $UtcDate"
                break
            } catch {
                continue
            }
        }
    }


    $Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

    $CsvData = Import-Csv -Path $_.Fullname | Where-Object { $_.Pos -match "^\d+$" }  # Exclude division headers

    # Build Bulk JSON Payload (Ensure newline at the end)
    #$BulkData = ""
foreach ($row in $CsvData) {
        $Document = @{
            CompetitionName = $CompetitionName
            CompetitionDate = $CompetitionDate
            Division    = $row.Division
            Pos         = $row.Pos
            Name        = $row.Name
            Gross       = $row.Gross
            Hcp         = $row.Hcp
            Nett        = $row.Nett
            #NewExact    = Convert-ToNumber -Value $row.NewExact -Type "float"
            imported_at = $Timestamp  # Add import timestamp
        } #| ConvertTo-Json -Compress
        $Responses += $Document #`n"# | ConvertTo-Json -Compress
    }

$Responses | Import-ElasticsearchDataBulk -Index $IndexName -Type "event" -ElasticsearchURL "https://192.168.0.110:9200" -ElasticsearchUser elastic -ElasticsearchV8OrLater -Verbose
$Responses.Clear() 
}



