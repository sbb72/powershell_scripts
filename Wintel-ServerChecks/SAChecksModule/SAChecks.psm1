$cwd = (Get-Location).path + "\SAChecksModule\"

foreach ($pathitem in $cwd) {

    $ps1files = (Get-ChildItem -File -Path $cwd -Filter *.ps1).fullname 
    ForEach ($ps1item in $ps1files) {

        import-module $ps1item
        Write-Host $ps1item
    }
  
}