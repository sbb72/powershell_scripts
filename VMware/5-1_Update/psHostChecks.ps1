# Adds the powercli cmdlets
Add-PSSnapin VMware.VimAutomation.Core -erroraction SilentlyContinue

$ScriptDir = "D:\Source_Files\Sbarker\Scripts\5-5_Upgrade"
$Output = "$ScriptDir\ConnectivityTest.csv"
$ServerList = "$ScriptDir\HostList.txt"
$Hosts = Get-Content $ServerList

$LogData = @()

#Set Current Hosts Root Passwords
$HostPassword = read-host "Enter the root password" -AsSecureString
$HostCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "root", $HostPassword

foreach ($Item in $Hosts) {
    $CheckHosts = New-Object psobject -Property @{
        Host      = ""
        Connected = ""
    }
    $CheckHosts.Host = $Item
    Connect-VIServer $Item -User root -Password $HostCreds.GetNetworkCredential().Password -ErrorAction SilentlyContinue -ErrorVariable ConnectError | Out-Null
    If ($ConnectError -ne $Null) {
        $CheckHosts.Connected = "N"
        Write-host "Failed to connect to $Item" -foregroundcolor Red
    }
    Else {
        $CheckHosts.Connected = "Y"
        Write-host "$Item Worked"
    }
    Disconnect-VIserver $Item -confirm:$false -Force
    $LogData += $CheckHosts
}

$LogData | Select Host, Connected | Export-Csv $Output -NoType