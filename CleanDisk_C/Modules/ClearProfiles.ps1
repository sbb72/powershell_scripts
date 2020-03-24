function Clear-Profiles {
    [CmdletBinding()]
    param (
        $Computername,
        $DelProfExeLocation,
        $LogFilePath
    )
    
    try {
        $DestFilePath =  "C$\Support\CDrive_Clean"
        if( !(Test-Path "\\$Computername\$DestFilePath")){
            New-Item "\\$Computername\$DestFilePath" -itemtype Dir -ErrorAction stop
        }
        Copy-Item $DelProfExeLocation "\\$Computername\$DestFilePath" -ErrorAction stop

        #Delete Profiles
        $arg = " /c:$Computername /u /d:45 /ed:Admin* /ed:zGKRADMIN /ed:*svc* /ed:soe-load /ed:*.NET* /ed:*Stratus*" 
        $cmd = "\\$Computername\$DestFilePath\" + 'DelProf2.exe' + $arg
        Invoke-Expression $cmd 
    }
    catch {
        $msg = "Error copying delprof2.exe: " + $_.exception.message
        Write-log $msg -Path $LogFilePath -Level Error
    }
}

