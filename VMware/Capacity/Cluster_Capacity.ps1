#$cred = Get-Credential
$AllData =@{}
$vCenters = "vc0001"
Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer $vCenters #-Credential $cred

$global:DefaultVIServers | Select Name,Version | ft -a  $Alldatas = New-Object -TypeName System.Collections.ArrayList foreach($cluster in Get-Cluster){

    $esx = $cluster | Get-VMHost

    $ds = Get-Datastore -VMHost $esx | where {$_.Type -eq "VMFS"}



    $Alldata = Select-Object -InputObject $Cluster -Property `
        @{N="VCname";E={$cluster.Uid.Split(':@')[1]}},

        @{N="DCname";E={(Get-Datacenter -Cluster $cluster).Name}},

        @{N="Clustername";E={$cluster.Name}},

        @{N="Total Physical Memory (MB)";E={($esx | Measure-Object -Property MemoryTotalMB -Sum).Sum}},

        @{N="Configured Memory MB";E={($esx | Measure-Object -Property MemoryUsageMB -Sum).Sum}},

        @{N="Available Memroy (MB)";E={($esx | Measure-Object -InputObject {$_.MemoryTotalMB - $_.MemoryUsageMB} -Sum).Sum}},

        @{N="Total CPU (Mhz)";E={($esx | Measure-Object -Property CpuTotalMhz -Sum).Sum}},

        @{N="Configured CPU (Mhz)";E={($esx | Measure-Object -Property CpuUsageMhz -Sum).Sum}},

        @{N="Available CPU (Mhz)";E={($esx | Measure-Object -InputObject {$_.CpuTotalMhz - $_.CpuUsageMhz} -Sum).Sum}},

        @{N="Total Disk Space (MB)";E={($ds | where {$_.Type -eq "VMFS"} | Measure-Object -Property CapacityMB -Sum).Sum}},

        @{N="Configured Disk Space (MB)";E={($ds | Measure-Object -InputObject {$_.CapacityMB - $_.FreeSpaceMB} -Sum).Sum}},

        @{N="Available Disk Space (MB)";E={($ds | Measure-Object -Property FreeSpaceMB -Sum).Sum}}

        $Alldatas.Add($Alldata)

}

$AllDatas| Export-Csv .\Test.csv -NoTypeInformation
