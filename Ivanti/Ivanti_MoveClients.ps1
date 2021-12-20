

$Clients = Import-Csv .\Ivanti_MoveClients.csv

#$regKey = "SYSTEM\CurrentControlSet\Services\scomc\Parameters\FirstServer"

$Response = @()
ForEach ($Client in $Clients) {

 $MoveClient = New-Object -TypeName PSObject -Property @{

    "Client" = "";
    "Ping" ="";
    "Server" = "";

    }
    
    Write-Host "Checking $Client"
    If ((Test-Connection -ComputerName $Client -Count 1 -Quiet) -eq "true") {
        
        Write-Host "Connectivty OK on $Client" -ForegroundColor Green
        $MoveClient.Ping = "OK"
   


        Write-host "Client is $($Client.Client)"
        $MoveClient.Client = $($Client.Client)
        Write-Host "Server is $($Client.Server)"
        $MoveClient.Server = $($Client.Server)


    }
    ELSE {
    
        Write-Host "Connectivty failed on $Client" -ForegroundColor Red
        $MoveClient.Ping = "FAIL"

    }
    $Response += $MoveClient

}


$Response | Export-Csv ".\MoveServers_$(Get-Date -format dd-MM-yyy).csv" -NoTypeInformation

#$regKey = "SYSTEM\CurrentControlSet\Services\scomc\Parameters\FirstServer"
$regKey = "SYSTEM\\CurrentControlSet\\Services\\ScDeviceEnum\\Parameters"

$Client = "ScottPC"

#Get Reg
$reg   = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$Client)
$regKeyRef  = $reg.OpenSubKey($regKey)
$Applications = $regKeyRef.GetValue('TEST')

$Applications



#Set Reg
$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computername ) 
$regKey= $reg.OpenSubKey($regKey,$true) 
$regKey.SetValue("TEST","TESTvaluesb1",[Microsoft.Win32.RegistryValueKind]::String) 




   