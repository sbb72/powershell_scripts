
$vcservices = "vctomcat","vpxd"
$Servers = Get-Content -Path "G:\SBarker\vCenter_Checks\ServerList.txt"
$short_date = Get-Date -uformat "%Y%m%d"
$Output = "G:\SBarker\vCenter_Checks\vCenterService_Check_"+$short_date+".csv"
$LogData = @()

Function GetService ([String]$service){
    TRY {
        If (Get-Service -ComputerName $Server | Where-Object {$_.Name -eq $service} -ErrorAction STOP) {
        $vCenterLog.$service = "Y"
        $servicestaus = Get-Service -ComputerName $Server -Name $service | Select Name, Status
            If ($($servicestaus.status) -eq "Running") {
            Write-Host "$Server Service $service is $($servicestaus.status)" 
            $vCenterLog.$service = $($servicestaus.status)
            }
            ELSE {
                Try {
                Get-Service -ComputerName $Server -Name $service | Start-Service
                Write-Host "Starting $service on $server"
                }
                Catch {
                $vCenterLog.$service = "Service on $Server status is $($servicestaus.status)"
                Write-Host "Service on $Server status is $($servicestaus.status)"
                }
            $vCenterLog.$service = $($servicestaus.status)
            }
        }
        ELSE {
        Write-Host "$service doesn't exist on $Server"
        $vCenterLog.$service = "N"
        }
    }
    CATCH {
    Write-Host "Issue with $service Service on $Server" 
    }
}

ForEach ($Server in $Servers) {
$vCenterLog = New-Object psobject -Property @{
Servername = ""
Ping =""
vpxd=""
vctomcat=""
}

$vCenterLog.Servername = "$Server"
Write-Host "Checking $Server" -ForegroundColor Green

    If (Test-Connection -computername $Server -count 1 -quiet) {
    $vCenterLog.Ping = "OK"
        ForEach ($service in $vcservices) {
        GetService $service

       }
    }
    ELSE{
    $vCenterLog.Ping = "Failed"
    Write-Host "Ping failed for $Server"
    }

$LogData += $vCenterLog
}

$LogData | Select-Object Servername,Ping,vpxd,vctomcat | Export-CSV -Path $Output -NoType