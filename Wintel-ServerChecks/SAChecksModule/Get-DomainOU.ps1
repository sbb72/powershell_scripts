function Get-DomainOU {
    try{
    $FullOUpath = (([adsisearcher]"(&(name=$env:computername)(objectclass=computer))").FindAll().path)
    $startingChar = ($FullOUpath | Select-String -Pattern "OU=").Matches.Index
    $FullOUpath = $FullOUpath.Substring($startingChar,$FullOUpath.Length-$startingChar)
    }
    catch{
        Write-Error $_.exception.message
        return $_.exception.message
    }
    return $FullOUpath.split(',')[0].trimstart('OU=')
}