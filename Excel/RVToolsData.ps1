$test = Import-Excel -Path "D:\Data\git-repo\powershell-scripts\Excel\RVToolsReports\28-09-2021_UK19-MGT-VCS02.xlsx" -WorkSheetname 'vHost' -HeaderName 'vHostName','vHostCpuModel','vHostCpuMhz' -StartRow 2 
$test1 = Import-Excel -Path "D:\Data\git-repo\powershell-scripts\Excel\RVToolsReports\28-09-2021_uk18-mgt-vcs02.xlsx" -WorkSheetname 'vHost' -HeaderName 'vHostName','vHostCpuModel','vHostCpuMhz'

$test| Export-Excel .\Test.xlsx -WorksheetName 'Array1' -NoHeader -Append
$test1| Export-Excel .\Test.xlsx -WorksheetName 'Array1' -NoHeader -Append

$Report = @()

Foreach ($Item in $Test) {

    
    $RVData = new-object PSObject -property @{
        HostName = $Item.vHostName
        CPUModel    = $Item.vHostCpuModel 
        CPUMhz = $Item.vHostCpuMhz
    }

    $Report += $RVData
}
$Report | Export-Excel .\Test.xlsx -WorksheetName 'Array2' -NoHeader -StartRow 1