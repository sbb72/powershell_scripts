Function Get-Reportingdata {
    <#

.SYNOPSIS
A function tp produce Billing report for the legacy environemnts in "$billingFolder\Script\Serverlist.txt" file.

.DESCRIPTION
The script will run commands against a list of vCenters

.PARAMETER vCenterServer

.EXAMPLE
>Check the if vCenter can be connected to and VMs list retrieve
Get-Reportingdata

#>
    $strDate = Get-date -f ddMMyyyy
    $billingFolder = "D:\Billing_Data\"
    #$outputfile = $billingFolder+$strDate+"_"
    $billingFolder = "D:\Billing_Data\"
    $errorlog = @()
    $errorlogpath = "$billingFolder$strDate" + "ErrorLog.csv"

    $vcs = get-content -path "$billingFolder\Script\Serverlist.txt"

    Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue


    $billingreport = @()

    Foreach ($vc in $vcs) {
        $errordata = New-Object -TypeName PSObject -Property @{ Date = Get-date -f dd-MM-yyyy vCenter =""
            Connected                                                = ""
            Error                                                    = ""
        }
        try {
            $errordata.vCenter = $vc
            Connect-VIServer -Server $vc -force -ErrorAction Stop
            Write-Host "connecting $vc"
            $errordata.Connected = "OK"
        }
        catch {
            Write-Host "Connecting to $vc Failed"
            $errordata.Connected = "Connecting to $vc Failed"
            write-host $_.exception.message
            $errordata.Error = $_.exception.message
        }

        #Check folder exists
        If (Test-Path "$billingFolder$VC") {
            Write-Host "EXISTS"
        }
        ELSE {
            New-Item -ItemType Directory "$billingFolder$VC" | Out-Null
        }

        $vms = Get-VM
        Foreach ($vm in $vms) {
            $billingdata = New-Object -TypeName PSObject -Property @{
                "Virtual Machine"         = ""
                PowerState                = ""
                CPUs                      = ""
                "Mem(MB)"                 = ""
                "Guest Full Name"         = ""
                Disks                     = ""
                "Prov.Space(GB)"          = ""
                "Used.Space(GB)"          = ""
                "Description (Cloud)"     = "NA"
                "Organisation (Cloud)"    = "NA"
                "Organisation vDC(Cloud)" = "NA"
            }
            $vmdata = Get-VM -name $VM
            $VMView = Get-vm -Name $VM | Get-View

            $billingdata."Virtual Machine" = $vmdata.name
            $billingdata.Powerstate = $vmdata.Powerstate
            $billingdata.CPUs = $vmdata.NumCPU
            $billingdata."Mem(MB)" = $vmdata.MemoryMB
            $billingdata."Guest Full Name" = $vmdata.Guest.OSFullName
            $billingdata.Disks = (Get-VM -Name $vm | Get-Harddisk).count
            $billingdata."Prov.Space(GB)" = [math]::round((Get-VM -Name $vm | Get-Harddisk | measure-object capacityGB -sum).sum)
            $billingdata."Used.Space(GB)" = [math]::round((get-vm -name $vm).usedSpaceGB)

            $billingreport += $billingdata

        }
        $billingreport | Select "Virtual Machine", PowerState, CPUs, "Mem(MB)", "Guest Full Name", Disks, "Prov.Space(GB)", "Used.Space(GB)", "Description (Cloud)", "Organisation (Cloud)", "Organisation vDC(Cloud)" | Export-Csv -Path "$billingFolder$vc\$strdate-$vc.csv" -NoTypeInformation
        $billingreport = @();
        $billingdata = @();
        $vms = $null
        Write-Host "Disconnecting $vc"
        Disconnect-VIServer -Server * -Force -Confirm:$false
    }

    $errorlog += $errordata
    $errorlog | Select vCenter, Date, Connected, Error |  Export-csv -path $errorlogpath -Append -NoTypeInformation 
}


function sendreport {

    Param
    ([Switch]$sendemailreport
    )

    <#
.SYNOPSIS
Get data produced from the 'Get-Reportingdata' function.

.PARAMETER vCenterServer

Get the latest file per vCenter in "D:\Billing_Data" sub folders

.PARAMETER
Running the function without a parameter will create the report but not send it via smtp

.PARAMETER sendmailreport
Creates the report and sends the report to pre-defined mailbox

.DESCRIPTION
.EXAMPLE
>Check the if vCenter can be connected to and VMs list retrieve
Get-Reportingdata -Sendemailreport

#>
    #Create a csv with headers
    $strDate = Get-date -f ddMMyyyy
    $outputfile = "D:\Billing_Data\Report\$strDate-LegacyBillingv1.csv"
    $newcsv = {} | Select "Virtual Machine", "PowerState", "CPUs", "Mem(MB)", "Guest Full Name", "Disks", "Prov.Space(GB)", "Used.Space(GB)", "Description (Cloud)", "Organisation (Cloud)", "Organisation vDC(Cloud)" | Export-csv -Path $outputfile -NoTypeInformation -Delimiter ","


    #Get the latest file from each vCenter
    $mergefiles = @()
    $folders = Get-ChildItem -path "D:\Billing_Data" -Recurse -directory -Exclude "Report", "Script" | Select Name

    Foreach ($Item in $folders) {
        $csvfiles = Get-ChildItem "D:\Billing_Data\$($Item.name)" -file | sort { $_.CreationTime } | Select -Last 1
        $mergefiles += $($csvfiles.FullName)
    }

    #Merge all exports into one file to send to the billing team
    foreach ($file in $mergefiles) {
        Write-host $file
        $file | Import-Csv | Select-Object -Skip 1 | Export-Csv $outputfile -Append -NoTypeInformation
    }

    #Send report for SMTP
    If ($sendemailreport) {
        write-host "Sending email"
        $reportdate = get-date -Format D
        $from = ""
        $to = ""
        $smtpserver = ""
        $Subject = "Legacy Billing Report - $reportdate"

        Send-MailMessage -From $from -To $to -SmtpServer $smtpserver -subject $Subject -Attachments $outputfile
    }
}
