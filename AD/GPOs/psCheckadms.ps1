$logData = @()
$logDate = Get-Date -f ddMMyyyy
$logFile = "F:\Sbarker\GPO\"+$logDate+"_GPOChecks.csv"
$gpos = Get-Childitem -Path "E:\sysvol\domain\Policies\" -directory | Select Name
#$gpos = "{4498FB88-E496-4E82-890E-90B4A89FDE29}","{44DB6954-6028-40E2-B47C-FFB2A66B45C8}","{4585B08E-A8C9-4BAA-A97C-56062AA1E63B}"

foreach ($gpo in $gpos) {

$GPOadmChecks = New-Object psobject -Property @{
GPOName = ""
GPOStatus =""
GPOID = ""
ADMFiles= ""
}
$gpo = $gpo.name
    #Get ID to use later
    Write-Host "1.Checking $gpo"
    $gpoid = $($gpo).Replace("{", "")
    $gpoid = $gpoid.Replace("}", "")
    
    if (test-path "E:\sysvol\domain\Policies\$gpo\Adm\*.adm") {
    $GPOadmChecks.ADMFiles = "Yes"
    }
    else {
    $GPOadmChecks.ADMFiles = "No"
    }
    $gpoinfo = get-gpo -Guid $gpoid | Select displayname, id, gpostatus
    $GPOadmChecks.GPOName = $gpoinfo.DisplayName
    $GPOadmChecks.GPOid = $gpoinfo.id
    $GPOadmChecks.GPOStatus = $gpoinfo.gpostatus

$LogData += $GPOadmChecks
}
$LogData | Select GPOName,GPOStatus,GPOID,ADMFiles | Export-CSV -Path $logFile -NoType
