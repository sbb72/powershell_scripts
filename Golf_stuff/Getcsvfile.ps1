$foldername = "C:\Users\Scott\Downloads\golfcsv\Wood_Bowl_(Major)_NettScoreSheet_15_03_2024.csv"

$csvdata = Import-csv -Path $foldername 

$CompDataResponse  = New-Object System.Collections.ArrayList
$Response  = New-Object System.Collections.ArrayList
Foreach ($csvline in $csvdata) 
{
    $CompDataResponse = New-Object -TypeName PSObject -Property @{
        "@timestamp" = [datetime]::UtcNow;
        "CompetitionDate" = "";
        "Format" = "";
        "TeeBox" = "";
        "GolfersName" = "";
        "Position" = "";
        "Handicap" = "";
        "ScorceGross" ="";
        "ScoreNet" = "";
    }

    #If ($($csvline.Pos) -match "^\d+$")
    If ($($csvline.Gross) -ne $null)
    {
        Write-Host "$($csvline.Name)"
        $CompDataResponse.GolfersName = $csvline.Name 
        $CompDataResponse.Position = $csvline.Pos   
        $CompDataResponse.ScorceGross = $csvline.Gross
        $CompDataResponse.ScoreNet = $csvline.Nett
        $CompDataResponse.Handicap = $csvline.Hcp

        #Get date of comp from csv file
        $csvDate = $csvdata | select-string "Date:" 
        $csvDate = $csvDate.ToString().Split(';') | Select-String Name
        #$csvDate = $csvDate.ToString("dd-MM-yyyy").Split('=')[1]
        $csvDate = Get-Date $csvDate.ToString("dd-MM-yyyy").Split('=')[1] -Format 'dd-MM-yyyy'
        $CompDataResponse.CompetitionDate = $csvDate
        #Format of play
        $csvGameFormat = $csvdata | select-string 'Score Type:'
        $csvGameFormat  = $csvGameFormat.ToString().Split(';') | Select-String Name
        $csvGameFormat = $csvGameFormat.ToString().Split('=')[1]
        $CompDataResponse.Format = $csvGameFormat
        #Tee
        $csvTeeBox = $csvdata | select-string 'Course/Tee:'
        $csvTeeBox  = $csvTeeBox.ToString().Split(';') | Select-String Name
        $csvTeeBox = ($csvTeeBox.ToString().Split('=')[1]).TrimEnd()
        $CompDataResponse.TeeBox = $csvTeeBox
        #Write-Output "Competition date was '$csvDate', played on '$csvTeeBox' tees and format was '$csvGameFormat'"
    }
    [Void]$Response.Add($CompDataResponse)
}

#$Response | Format-Table
Write-Output "There are '$(($Response | Measure-Object).Count)' objects"

#$Response = ""