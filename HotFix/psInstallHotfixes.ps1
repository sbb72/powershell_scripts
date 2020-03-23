$dir = (Get-Item -Path ".\" -Verbose).FullName

$strCount = (ls $dir *.ps1 -Name).count
$strStart = 1


 Write-Host "Installing $strCount Patches" -ForegroundColor Green
 Foreach($item in (ls $dir *.msu -Name))
 {
Write-Host "Starting Number $strStart install of the patches" -ForegroundColor Green
    echo $item
    $item = $dir + "\" + $item
    #wusa $item /quiet /norestart | Out-Null
$strStart = $strStart + 1
 }