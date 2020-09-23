
$Servers = Get-Content -Path c:\temp\servers.txt
$LogFile = "c:\temp\hyper-v_test.csv"
$LogData = @()

ForEach ($Server in $Servers) { 

$HypervCheck = New-Object psobject -Property @{
    Server = ""
    Ping = ""
    LogicalCPU  = $LogicalCPU
    PhysicalCPU = $PhysicalCPU
    CoreNr      = $Core
    HyperThreading = $($LogicalCPU -gt $PhysicalCPU)
}
    if (Test-Connection -ComputerName $Server -Count 2 -Quiet) {
    Write-Host "$Server--Ping OK" -ForegroundColor Green
    $HypervCheck.Server = $Server
    $HypervCheck.Ping = "OK"

    # Get the Processor information from the WMI object
    $Proc = [object[]]$(get-WMIObject Win32_Processor -ComputerName $Server)
 
    #Perform the calculations
    $Core = $Proc.count
    $HypervCheck.LogicalCPU = $($Proc | measure-object -Property NumberOfLogicalProcessors -sum).Sum
    $HypervCheck.PhysicalCPU = $($Proc | measure-object -Property NumberOfCores -sum).Sum
    }
    ELSE {
    Write-Host "$Server--Ping Failed" -ForegroundColor Red
    $HypervCheck.Server = $Server
    $HypervCheck.Ping = "No"
    }
 $LogData += $HypervCheck

}

$LogData | Select Server,ping,HyperThreading,PhysicalCPU,CoreNr,LogicalCPU | Export-Csv $LogFile -NoTypeInformation
