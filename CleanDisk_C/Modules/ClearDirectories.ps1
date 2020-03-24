function Clear-Directories {
    [CmdletBinding()]
    param (
        $COMPUTERNAME,
        $DirectoryList,
        $LogFilePath
    )
    
    foreach ($dir in $DirectoryList){ 

        $dirpath = $dir.replace('C:\', "$COMPUTERNAME\c$\")
         
        if(test-path $dirpath){
            Write-log -Message "Clearing $dirpath" -Path $LogFilePath -Level Info
            try {
                Get-ChildItem  $dirpath -Force -ErrorAction Stop  | remove-item -Recurse  -ErrorAction Stop
            }
            catch {
                $msg = "Error occured removing sub folders of $dirpath  " + $_.exception.message
                Write-log -Message $msg -Path $LogFilePath -Level Warn
            }

        }
        
        
    }
}