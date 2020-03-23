Get-Datastore |

Select Name,FreeSpaceGB,CapacityGB,

    @{N='DateTime';E={Get-Date}},

    @{N='CanonicalName';E={$_.ExtensionData.Info.Vmfs.Extent[0].DiskName}},

    @{N='LUN';E={

        $esx = Get-View -Id $_.ExtensionData.Host[0].Key -Property Name

        $dev = $_.ExtensionData.Info.Vmfs.Extent[0].DiskName

        $esxcli = Get-EsxCli -VMHost $esx.Name -V2

        $esxcli.storage.nmp.path.list.Invoke(@{'device'=$dev}).RuntimeName.Split(':')[-1].TrimStart('L')}} | Export-CSV .\luninfo.csv -NoTypeInformation