<#
.DESCRIPTION
Get the IPconfig details of VMs before the upgrade of HW version and VMTools
.INPUTS
List
.OUTPUTS
Out put file in :\Support
.NOTES
  Version:        1.0
  Author:         SBarker
  Creation Date:  13-03-2019
  Purpose/Change: Initial script  
Version 1.0
Created Script
#>
#Define list or single server
param([string] $Server,[string] $ServerList)

$psexec = "C:\Data\Software\PSTools\psexec.exe \\"
$servers ="GBPF0Y506L"
$arg = " cmd /c ""ipconifg /all >> \\$Item\c$\Temp\ipconfig.txt"""

#works locally
foreach ($item in $Servers){

$pscmd = $psexec + $Item + $arg
Invoke-Expression $pscmd | Out-Null
}