<#
.DESCRIPTION
This script has been created to export vCenter information via RVTools.
Option to send the exported data vian email.
Option to copy the files to a remote UNC path
.INPUTS
List of vcenter servers you want to export information for.
.OUTPUTS
Output file stored in $outputfile location
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  25-10-2020
  Purpose/Change: Initial script  
Version 1.0
Purpose/Change: Initial script  
#>
Function createdirectory {
    param ($folderpath,
        $newfolder)
    Write-Host "Creating folder $folderpath$newfolder"
    New-Item -ItemType Directory "$folderpath$newfolder"
}

Function copyfiles {
    param ($serverpath
    )
    If (Test-Path "$serverpath$VCServer") {
        Write-Host "EXISTS"
        try {
            Copy-Item "$XlsxDir1$VCServer\$XlsxFile1" "$serverpath$VCServer" -Force -ErrorAction stop
            $rvtoolsdata.CopytoDev = "OK"
        }
        catch {
            $rvtoolsdata.CopytoDev = "FAILED"
        }
    }
    ELSE {
        Write-Host "Creating folder $serverpath$VCServer"
        createdirectory -folderpath $serverpath -newfolder $VCServer
        try {
            Copy-Item "$XlsxDir1$VCServer\$XlsxFile1" "$serverpath$VCServer" -Force -ErrorAction stop
            $rvtoolsdata.CopytoDev = "OK"
        }
        catch {
            $rvtoolsdata.CopytoDev = "FAILED"
        }
    }
}

#Variables
$strDate = Get-date -f dd-MM-yyyy
$sdmdev = "\\glkasad14140v\d$\incoming_reports\RVTools\"
$sdmprod = "\\glkasad14141v\d$\incoming_reports\RVTools\"
$XlsxDir1 = "D:\RVTools\" #add servername as folder $Output = $XlsxDir1+"RvToolsLog.csv"
$ServerlistErrorLog = "D:\RVTools\" + $strDate + "_Error.log"

$emailhash = @{
    from       = "server1@somedomain.local"
    to         = "admin@somedomain.com"
    body       = "Test body"
    subject    = "Test subject"
    smtpserver = "server1"
    attachment = "$XlsxDir1$VCServer\$XlsxFile1"
}

$rvtoolslog = @()

#Get Server list
try {
    $Servers = Get-Content -Path "D:\RVTools\Serverlist.txt" -ErrorAction stop 
}
catch { New-Item -Path $ServerlistErrorLog -ItemType File -Force $_.exception.message | Out-File -FilePath $ServerlistErrorLog write-host $_.exception.message EXIT }


Foreach ($VCServer in $Servers) {

    $rvtoolsdata = New-Object psobject -Property @{ 
        Date       = Get-date -f dd-MM-yyyy_HH:mm Server=""
        ServerList = ""
        Export     = ""
        CopytoDev  = ""
        CopytoProd = ""
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
        $rvtoolsdata.Export = "Failed"
        Write-Host "Error: Export failed! RVTools returned exitcode -1, probably a connection error! Script is stopped" -ForegroundColor Red
        #exit 1
    }
    ELSE {
        $rvtoolsdata.Export = "OK"
        #Used to copy to SDM Servers
        #Copying to dev
        copyfiles -serverpath $sdmdev
        #Copying to Prod
        copyfiles -serverpath $sdmdev
    }
    $rvtoolslog += $rvtoolsdata
    Send-MailMessage @emailhash
}

return $rvtoolslog | Select Server, ServerList, Date, Export, CopytoDev, CopytoProd | Export-Csv -Path $Output -NoTypeInformation
