. $PSScriptRoot\ClearDirectories.ps1
. $PSScriptRoot\ShowPrompt.ps1
. $PSScriptRoot\GetFilename.ps1
. $PSScriptRoot\GetFolderPath.ps1
. $PSScriptRoot\SaveFileAs.ps1
. $PSScriptRoot\WriteLog.ps1
. $PSScriptRoot\CompressDirectories.ps1
. $PSScriptRoot\GetFolderSize.ps1
. $PSScriptRoot\RemoveScheduledTask.ps1
. $PSScriptRoot\ClearProfiles.ps1
. $PSScriptRoot\ClearBixFixCache.ps1
#Get-ChildItem .\Modules -File | select -ExpandProperty name | where {$_ -ne 'Cleardisk.psm1'} |foreach {'. $PSScriptRoot\'+ $_}
#Get-ChildItem .\Modules\Report -File | select -ExpandProperty name | where {$_ -ne 'ServerDecom.psm1'} |foreach {'. $PSScriptRoot\Report\'+ $_}

