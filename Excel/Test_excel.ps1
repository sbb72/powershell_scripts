try {Import-Module $PSScriptRoot\..\..\ImportExcel.psd1} catch {throw ; return}

# Create example file
$xlFile = "$PSScriptRoot\ImportColumns.xlsx"
Get-Process | Export-Excel -Path $xlFile
# -ImportColumns will also arrange columns
Import-Excel -Path $xlFile -ImportColumns @(1,3,2) -NoHeader -StartRow 1
# Get only pm, npm, cpu, id, processname
Import-Excel -Path $xlFile -ImportColumns @(6,7,12,25,46) | Format-Table -AutoSize

$ex = open-excelpackage "D:\Data\git-repo\powershell-scripts\Excel\25-11-2020_glkvc0016.xlsx"

$worksheets = $ex.Workbook.Worksheets['vInfo'] | Export-Excel "D:\Data\git-repo\powershell-scripts\Excel\Testexcel.xls"
$xlsxfiles="D:\Data\git-repo\powershell-scripts\Excel\25-11-2020_glkvc0016.xlsx"
Import-Excel -Path $xlsxfiles -WorksheetName 'vInfo' -ImportColumns @(1,3,2) -DataOnly -ErrorAction Continue | Export-Excel "D:\Data\git-repo\powershell-scripts\Excel\Testexcelv1.xlsx" -Append -WorksheetName "BillingReport"

$xlsxfiles="D:\Data\git-repo\powershell-scripts\Excel\RVToolsReports\28-09-2021_UK19-MGT-VCS02.xlsx"
Import-Excel -Path $xlsxfiles -WorksheetName 'vInfo' -ImportColumns @(1,3,2) -DataOnly -ErrorAction Continue | Export-Excel "D:\Data\git-repo\powershell-scripts\Excel\Testexcelv1.xlsx" -Append -WorksheetName "BillingReport" -NoHeader -StartRow 1


$xlsxfiles="D:\Data\git-repo\powershell-scripts\Excel\RVToolsReports\15-12-2021_uk18-mgt-vcs02.xlsx"
Import-Excel -Path $xlsxfiles -WorksheetName 'vHost' -ImportColumns @(1,2,3,5,7,8,9,10,11,16,18,20,32,36,38,39,49,50,55,56,58) -DataOnly -ErrorAction Continue | Export-Excel "D:\Data\git-repo\powershell-scripts\Excel\Testexcelv1.xlsx" -Append -WorksheetName "HostInfo"

$xlsxfiles="D:\Data\git-repo\powershell-scripts\Excel\RVToolsReports\28-09-2021_UK19-MGT-VCS02.xlsx"
Import-Excel -Path $xlsxfiles -WorksheetName 'vHost' -ImportColumns @(1,2,3,7,8,9,10,11,16,18,20,32,36,38,39,49,50,55,56,58) -DataOnly -ErrorAction Continue | Export-Excel "D:\Data\git-repo\powershell-scripts\Excel\Testexcelv1.xlsx" -Append -WorksheetName "HostInfo" -NoHeader -StartRow 1

#vCenter Info
$ex = open-excelpackage $xlsxfiles
$worksheets = $ex.Workbook.Worksheets['vInfo']
$worksheets.Cells.Item(2,67).value
$worksheets.Cells.Item(2,69).value
Close-ExcelPackage -ExcelPackage $ex


#import the file into a variable
$sourceFile = import-excel $xlsxfiles -WorkSheetname 'vHost' -HeaderRow 1

#the variable behaves very similarly to a csv table now
$testcol = $sourceFile | ? {$_."Column Name" -eq "vHostCpuModel"}

$sourceFile.vHostCpuModel
$sourceFile.vHostFullName
$ex = open-excelpackage $xlsxfiles
$ex.Workbook.Worksheets.ToString('vHostCpuModel')

$ex.Workbook.Worksheets['vHost'].Cells.Item(1,2).value

$ex.Workbook.Worksheets['vHost'].Column(1)

#Find and copy colunm
$ExcelFile = Import-Excel "D:\Data\git-repo\powershell-scripts\Excel\RVToolsReports\28-09-2021_UK19-MGT-VCS02.xlsx" -WorksheetName "vHost" 
$SpecificColumn = $ExcelFile.vHostCpuModel #loads column with the header "anotherHeader" -- data stored in an array

$ex = open-excelpackage $xlsxfiles
$workSheet.InsertColumn($SpecificColumn);
$SpecificColumn

$test = Import-Excel -Path "D:\Data\git-repo\powershell-scripts\Excel\RVToolsReports\28-09-2021_UK19-MGT-VCS02.xlsx" -WorkSheetname 'vHost' -HeaderName 'vHostName','vHostCpuModel','vHostCpuMhz'

$test| Export-Excel .\Test.xlsx -WorksheetName 'Array1' -NoHeader

Open-ExcelPackage

$workSheet.InsertColumn(33, 1);

$SpecificColumn | Export-Excel .\Test.xlsx -WorksheetName 'Test'

$RVData = @{}
$RVData = new-object PSObject -property @{
    CPUModel    = ""
 
}

$RVData.CPUModel = $SpecificColumn 

$HashTable = @{}
$SpecificColumn= $ExcelFile.vHostCpuModel
$SpecificColumn.psobject.properties | ForEach-Object { 
    $HashTable[$_.Name] = $_.Value
}

$RVData | Export-Excel .\Test.xlsx -WorksheetName 'Array'