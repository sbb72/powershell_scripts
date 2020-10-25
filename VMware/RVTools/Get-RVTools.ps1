# -----------------------------------------------------
#$Output = $strDate+"_"+$VCServer
Function createdirectory {
    param ($folderpath,
        $newfolder)
    Write-Host "Creating folder $folderpath$newfolder"
    New-Item -ItemType Directory "$folderpath$newfolder"
}


#Variables
$strDate = Get-date -f dd-MM-yyyy
$sdmdev = "\\glkasad14140v\d$\incoming_reports\RVTools\"
$sdmprod = "\\glkasad14141v\d$\incoming_reports\RVTools\"
$XlsxDir1 = "D:\RVTools\" #add servername as folder $Output = $XlsxDir1+"RvToolsLog.csv"
$ServerlistErrorLog = "D:\RVTools\" + $strDate + "_Error.log"
$rvtoolslog = @()


#Get Server list
try {
    $Servers = Get-Content -Path "D:\RVTools\Serverlist.txt" -ErrorAction stop 
}
catch { New-Item -Path $ServerlistErrorLog -ItemType File -Force $_.exception.message | Out-File -FilePath $ServerlistErrorLog write-host $_.exception.message EXIT }


Foreach ($VCServer in $Servers) {

    $rvtoolsdata = New-Object psobject -Property @{ Date = Get-date -f dd-MM-yyyy_HH:mm Server=""
        ServerList                                       = ""
        ExportFailed                                     = ""
        CopytoDev                                        = ""
        CopytoProd                                       = ""
    }


    $XlsxFile1 = $strdate + "_" + $VCServer + ".xlsx"
    $rvtoolsdata.Server = $VCServer
    If (Test-Path "$XlsxDir1$VCServer") {
        Write-Host "EXISTS"
    }
    ELSE {
        Write-Host "Creating folder $XlsxDir1$VCServer"
        createdirectory -folderpath $XlsxDir1 -newfolder $VCServer
    }

    # cd to RVTools directory
    $RVToolsPath = "C:\Program Files (x86)\Robware\RVTools" # Set RVTools path
    set-location $RVToolsPath

    # Start cli of RVTools
    Write-Host "Start export for vCenter $VCServer" -ForegroundColor DarkYellow
    $Arguments = "-s $VCServer -c ExportAll2xlsx -d ""$XlsxDir1$VCServer"" -f $XlsxFile1 -DBColumnNames -ExcludeCustomAnnotations"

    Write-Host $Arguments

    $Process = Start-Process -FilePath ".\RVTools.exe" -ArgumentList $Arguments -NoNewWindow -Wait -PassThru

    if ($Process.ExitCode -eq -1) {
        $rvtoolsdata.ExportFailed = "YES"
        Write-Host "Error: Export failed! RVTools returned exitcode -1, probably a connection error! Script is stopped" -ForegroundColor Red
        #exit 1
    }
    ELSE {
        $rvtoolsdata.ExportFailed = "NO"
        #Copying to dev
        If (Test-Path "$sdmdev$VCServer") {
            Write-Host "EXISTS"
            try {
                Copy-Item "$XlsxDir1$VCServer\$XlsxFile1" "$sdmdev$VCServer" -Force -ErrorAction stop
                $rvtoolsdata.CopytoDev = "OK"
            }
            catch {
                $rvtoolsdata.CopytoDev = "FAILED"
            }
        }
        ELSE {
            Write-Host "Creating folder $sdmdev$VCServer"
            createdirectory -folderpath $sdmdev -newfolder $VCServer
            try {
                Copy-Item "$XlsxDir1$VCServer\$XlsxFile1" "$sdmdev$VCServer" -Force
                $rvtoolsdata.CopytoDev = "OK"
            }
            catch {
                $rvtoolsdata.CopytoDev = "FAILED"
            }
        }

        #Copying to prod
        If (Test-Path "$sdmprod$VCServer") {
            try {
                Write-Host "EXISTS"
                Copy-Item "$XlsxDir1$VCServer\$XlsxFile1" "$sdmprod$VCServer" -Force -ErrorAction stop
                $rvtoolsdata.CopytoProd = "OK"
            }
            catch {
                $rvtoolsdata.CopytoProd = "FAILED"
            }
        }
        ELSE {
            Write-Host "Creating folder $sdmprod$VCServer"
            createdirectory -folderpath $sdmprod -newfolder $VCServer
            try {
                Copy-Item "$XlsxDir1$VCServer\$XlsxFile1" "$sdmprod$VCServer" -Force -ErrorAction stop
                $rvtoolsdata.CopytoProd = "OK"
            }
            catch {
                $rvtoolsdata.CopytoProd = "FAILED"
            }
        }
    }
    $rvtoolslog += $rvtoolsdata
}

return $rvtoolslog | Select Server, ServerList, Date, ExportFailed, CopytoDev, CopytoProd | Export-Csv -Path $Output -NoTypeInformation
