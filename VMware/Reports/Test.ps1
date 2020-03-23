Get-Datastore |

#where {($_.FreeSpaceGB/$_.CapacityGB) -le 0.13} |

Select @{N='Datacenter';E={$_.Datacenter.Name}},

    @{N='DSC';E={Get-DatastoreCluster -Datastore $_ | Select -ExpandProperty Name}},

    Name,CapacityGB,@{N='FreespaceGB';E={[math]::Round($_.FreespaceGB,2)}},

    @{N='ProvisionedSpaceGB';E={[math]::Round(($_.ExtensionData.Summary.Capacity - $_.Extensiondata.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB,2)}},

    @{N='UnCommittedGB';E={[math]::Round($_.ExtensionData.Summary.Uncommitted/1GB,2)}},

    @{N='VM';E={$_.ExtensionData.VM.Count}} |

Export-Csv report.csv -NoTypeInformation -UseCulture