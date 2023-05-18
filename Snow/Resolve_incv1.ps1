# Script to bulk update/resolve Service Now incidents
# Requires the DXC-iSolve module installed https://github.dxc.com/UK-Core-Delivery/iSolve-Powershell-Module
# Requires Snow credentials cached in registry using Write-SavedCredential
# Yasin Kara (DXC) (August 2021)

# Import module
Import-Module DXC-iSolve -Function Update-SnowIncident

# Define variables
$SnowUrl = "cscqa.service-now.com"
$ClosureCode = "Solved (Permanently)"
$ClosureNotesMsg = "xRBA Testing"

# Path to text file containing list of incidents refs, looks for txt file alongside .ps1 file
$Incidents = Get-Content D:\Data\git-repo\powershell-scripts\Snow\inc_numbers.txt

# Count the total number of incidents in the list
$Total = $Incidents.Count

# Initiate progress counter
$Counter = 0

# Loop through each incident in list
foreach ($INC in $Incidents)

{ 
    # Increment the counter for each loop
    $Counter++

    Write-Host "Trying to close $INC"
    # Make the API call to update incident
    Get-SnowIncident -Url $SnowUrl -Number 'INC6712715' -CredentialFor 'Snow-Set-csc.service-now.com' -Verbose
    
    Update-SnowIncident -Url $SnowUrl -Number $INC -Resolve -CloseCode $ClosureCode -CloseNotes $ClosureNotesMsg -ReturnStatus -Verbose -ErrorAction SilentlyContinue

    # Output to console the progress counter
    Write-Output "$Counter incident(s) updated from a total of $Total"
}