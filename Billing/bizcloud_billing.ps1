
import-module .\ConvertToVM.psm1
add-pssnapin VMware.VimAutomation.Cloud
Add-PSSnapin VMware.VimAutomation.Core

Connect-CIServer ""
Connect-VIServer ""

$date = get-date -f dd-MM-yy_HH:m
write-host "start $date"
#$vms = Get-OrgVdc | Get-CIVApp | Get-CIVM | select name, Status,CpuCount,MemoryMB,GuestOsFullName,org, orgvdc, Description, DateCreated
$vms = Get-CIVM | select name

$logdata = @()
foreach ($item in $vms) {

    $vcddata = new-object PSObject -property @{
        VM               = ""
        Status           = ""
        CpuCount         = ""
        MemoryMB         = ""
        "Guest FullName" = ""
        orgname          = ""
        orgvdcname       = ""
        description      = ""
        datecreated      = ""
        Disks            = ""
        "Prov.Space(GB)" = ""
        "Used.Space(GB)" = ""
    }

    #$vcdvm = $($item.name).Substring(0, $($item.name).Length-39)

    $vmdata = Get-OrgVdc | Get-CIVApp | Get-CIVM | Where { $_.name -eq $($item.name) } | select name, Status, CpuCount, MemoryMB, GuestOsFullName, org, orgvdc, Description, DateCreated

    $vcddata.Status = $($Item.Status)
    $vcddata.CpuCount = $($Item.cpucount)
    $vcddata.MemoryMB = $($Item.MemoryMB)
    $vcddata."Guest FullName" = $($Item.GuestOsFullName)
    $vcddata.orgname = $($Item.org.Name)
    $vcddata.orgvdcname = $($Item.orgvdc.Name)
    $vcddata.description = $($Item.description)

    $vmcreated = Get-CIVm | Get-CIView | Where { $_.name -eq $($item.name) } | Select DateCreated
    $vcddata.datecreated = $($vmcreated.DateCreated)

    $vcvm = Get-CIVm | Where { $_.name -eq $($item.name) } | Convert-ToVM
    $vcddata.vm = $vcvm
    $vcddata.Disks = (Get-VM -Name $vcvm | Get-Harddisk).count
    $vcddata."Prov.Space(GB)" = [math]::round((Get-VM -Name $vcvm | Get-Harddisk | measure-object capacityGB -sum).sum)
    $vcddata."Used.Space(GB)" = [math]::round((get-vm -name $vcvm).usedSpaceGB)

    Write-Host "Server Name $($item.name)"
    $logdata += $vcddata
}

$date = get-date -f dd-MM-yy_HH:m
write-host "Finish $date"
$logdata | Select VM, Status, CpuCount, MemoryMB, "Guest FullName", orgname, orgvdcname, description, datecreated, disks, "Prov.Space(GB)", "Used.Space(GB)"  | Export-csv -path .\ExportBilling.csv -NoTypeInformation
