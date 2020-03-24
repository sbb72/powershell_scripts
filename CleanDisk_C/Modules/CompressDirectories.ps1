function Compress-Directories {
    [CmdletBinding()]
    param (
        $ComputerName,
        $ListofDirectories
    )
    
    foreach ($dir in $ListofDirectories) {
        $remotePAth = "\\$ComputerName\" + $dir.Replace('C:','C$')
        if(Test-path $remotePAth){
            $command =   @"
.\PsExec.exe \\$ComputerName -s -d -h cmd /s  /c "compact /C /S:$dir /I /Q" 
"@
            Invoke-Expression $command
        }
        

    }
}


# $ComputerName = 'glkxa0002v'
# $dir = 'C:\Windows\Logs'
# Compress-Directories  -ComputerName 'glkxa0003v' -ListofDirectories @('C:\Windows\Logs')