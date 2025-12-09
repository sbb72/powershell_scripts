function Get-PlayingHandicap14HoleBetterball {
    param(
        [Parameter(Mandatory)]
        [decimal]$HandicapIndex,

        [Parameter(Mandatory)]
        [int]$SlopeRating,

        [Parameter(Mandatory)]
        [decimal]$CourseRating,

        [Parameter(Mandatory)]
        [int]$Par
    )

    # 1. Calculate Course Handicap (18 holes WHS)
    $courseHandicap = [math]::Round(($HandicapIndex * ($SlopeRating / 113)) + ($CourseRating - $Par))

    # 2. Scale to 14 holes
    $handicap14 = ($courseHandicap * 14) / 18
    $handicap14 = [math]::Round($handicap14)

    # 3. Apply Betterball allowance (85%)
    $playingHandicap = [math]::Round($handicap14 * 0.85)
    $playingHandicapfull = ($handicap14 * 0.85)
    [pscustomobject]@{
        HandicapIndex     = $HandicapIndex
        CourseHandicap18  = $courseHandicap
        CourseHandicap14  = $handicap14
        PlayingHandicap85 = $playingHandicap
        PlayingHandicapFull =$playingHandicapfull

    }
}

# ------------------ Example usage ------------------

Get-PlayingHandicap14HoleBetterball `
    -HandicapIndex 10.2 `
    -SlopeRating 126 `
    -CourseRating 67.4 `
    -Par 70
