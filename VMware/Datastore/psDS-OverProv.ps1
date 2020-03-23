

Get-Datastore | Select Name,@{N="TotalSpaceGB";E={[Math]::Round(($_.ExtensionData.Summary.Capacity)/1GB,0)}},`
@{N="UsedSpaceGB";E={[Math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace)/1GB,0)}}, `
@{N="ProvisionedSpaceGB";E={[Math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB,0)}},`
@{N="NumVM";E={@($_ | Get-VM | where {$_.PowerState -eq "PoweredOn"}).Count}} | `
Sort Name | Export-Csv -Path C:\temp\vmds-datastore.csv -NoTypeInformation -UseCulture