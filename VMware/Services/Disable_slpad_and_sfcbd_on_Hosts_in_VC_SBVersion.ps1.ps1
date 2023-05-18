#vCenter FQDN or IP Address
$vcenter = ""

#Username
#This could be username@domain.net or just username depending on version of vCenter
$UserName = ""

#Change to true if you want to test the script or just run a report.
$WhatIfPreference = $true

#File name of Export
$ResultFilename = "C:\Temp\ESXiServiceStatus_Post_Disable_" + (Get-Date).tostring("dd_MM_yyyy") +".csv"

$ModuleCheck = Get-Module -ListAvailable -Name VMware.VimAutomation.Core
if($ModuleCheck) { 
    Import-Module -Name VMware.VimAutomation.Core -Force 
}
else {
    #Set-ItemProperty -Path "REGISTRY::\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing" -Name State -Value 146944
    try
    { Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue }
    catch
    {
        #Set-ItemProperty -Path "REGISTRY::\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing" -Name State -Value 146432
        Write-Verbose "Unable to find/load the VMware PowerCLI module or Powershell Snappin, error message: $($_.Exception.Message)"
    }
    Set-ItemProperty -Path "REGISTRY::\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing" -Name State -Value 146432
}
$ErrorActionPreference = "Stop"

#Read VC Credentials
Try {
    $VCCred = Get-Credential -UserName $UserName -Message "Please enter Password of $User Account"
    
}
Catch {

    Write-Host "Failed to connect to vCenter, error message: $($_.Exception.Message)"
}

#Connect to vCenter Server
$VCConnection = Connect-VIServer -Server $vcenter -Credential $VCCred | Out-Null

# List ESXiHosts in Cluster with Connected Status
$ESXiHosts = Get-VMHost -State Connected

$slpdfound = "No"
$Services =  "slpd","sfcbd-watchdog"
$Response = @()

foreach ($ESXiHost in $ESXiHosts) {
$vmsacompliant = "No"
$ServiceStatus = new-object PSObject
$ServiceStatus | add-member -type NoteProperty -Name HostName -Value $ESXiHost.Name

Write-Host "Checking $($ESXiHost.Name)"

    foreach ($Service in $Services) {
    Write-Host "Checking service $Service"

    Add-member -InputObject $ServiceStatus -MemberType NoteProperty -Name "HostName" -Value $($ESXiHost.Name) -Force
        Try {
            $ESXiService = Get-VMHost -Name $($ESXiHost.Name) | Get-VMHostService | Where {$_.Key -eq "$Service"} -ErrorAction Stop # $ESXiHost  "sfcbd-watchdog" baevthmds182.greenlnk.net
            #$ESXiService = Get-VMHost -Name baevthmds182.greenlnk.net | Get-VMHostService | Where {$_.Key -eq "sfcbd-watchdog"} -ErrorAction Stop # $ESXiHost  "sfcbd-watchdog" baevthmds182.greenlnk.net
            If (!$ESXiService) {
                If ($Service -eq "slpd") {
                    $slpdfound = "No"
                }
                Write-Host "Service $Service doesn't exist on $($ESXiHost.Name)"
                
                
                $ServiceStatus | add-member -type NoteProperty -Name $Service"_StartupPolicy" -Value "Not found"
                $ServiceStatus | add-member -type NoteProperty -Name $Service"_CurrentStatus" -Value "Not found"
            }
            Else {
                If ($Service -eq "slpd") {
                    $slpdfound = "Yes"
                }
                Write-Host "Changing state and policy of $Service service on $ESXiHost "

                 Try {
                    Get-VMHost -Name $ESXiHost | Get-VMHostService | Where {$_.Key -eq "$Service"} | Set-VMHostService -Policy Off -Confirm:$false -WhatIf:$WhatIfPreference -ErrorAction Stop -Verbose
                    Get-VMHost -Name $ESXiHost | Get-VMHostService | Where {$_.Key -eq "$Service"} | Stop-VMHostService -Confirm:$false -WhatIf:$WhatIfPreference -ErrorAction Stop -Verbose
                   
                }
                Catch {
                    
                    Write-Host "Error : $($_.Exception.Message)"
                }
                Try {
                     $FireWallCIM = Get-vmhost -Name $($ESXiHost.Name) | Get-VMHostFirewallException | Where {$_.Name -eq "CIM SLP"}
                     Get-vmhost -Name $($ESXiHost.Name) | Get-VMHostFirewallException | Where {$_.Name -eq "CIM SLP"} | Set-VMHostFirewallException -Enabled $false -ErrorAction Stop -Verbose -WhatIf:$WhatIfPreference
                     $FireWallCIM = Get-vmhost -Name $($ESXiHost.Name) | Get-VMHostFirewallException | Where {$_.Name -eq "CIM SLP"}
                }
                Catch {
                    
                    Write-Host "Error : $($_.Exception.Message)"
                }
                #Getting status to add to the report

                $ServiceStatus | add-member -type NoteProperty -Name $Service"_StartupPolicy" -Value $ESXiService.Policy
                $ServiceStatus | add-member -type NoteProperty -Name $Service"_CurrentStatus" -Value $ESXiService.Running
                $ServiceStatus | add-member -type NoteProperty -Name "CIM SLP Firewall" -Value $($FireWallCIM.Enabled)
                   
            }
        
        }
        Catch {
            Write-Host "Error : $($_.Exception.Message)"
        }

    }
    #If SLP was found
    if ($slpdfound -eq "Yes") {
        $ESXiServiceslpd = Get-VMHost -Name $($ESXiHost.Name) | Get-VMHostService | Where {$_.Key -eq "slpd"} -ErrorAction Stop # $ESXiHost  "sfcbd-watchdog" baevthmds182.greenlnk.net
        $ESXiServicesfcbd = Get-VMHost -Name $($ESXiHost.Name) | Get-VMHostService | Where {$_.Key -eq "sfcbd-watchdog"} -ErrorAction Stop # $ESXiHost  "sfcbd-watchdog" baevthmds182.greenlnk.net	
		
        if ( ($($ESXiServiceslpd.Policy) -eq "off") -and ($($ESXiServiceslpd.Running) -eq "stopped") -and ($($ESXiServicesfcbd.Policy) -eq "off") -and ($($ESXiServicesfcbd.Running) -eq "stopped") ) {
            
				$vmsacompliant = "Yes"
			}
		    elseif ($slpdfound -eq "No") {
			echo "Here"
			$vmsacompliant = "SLP service needs to be checked/set manually"
            }
    }
    $ServiceStatus | add-member -type NoteProperty -Name VMSA-2021-0014_Compliant -Value $vmsacompliant
 $Response += $ServiceStatus     
}
$Response | Select HostName,slpd_StartupPolicy,slpd_CurrentStatus,sfcbd-watchdog_StartupPolicy,sfcbd-watchdog_CurrentStatus,VMSA-2021-0014_Compliant | Format-Table


try
{
    $Response | Select HostName,slpd_StartupPolicy,slpd_CurrentStatus,sfcbd-watchdog_StartupPolicy,sfcbd-watchdog_CurrentStatus,VMSA-2021-0014_Compliant | export-csv $ResultFilename -notype -ErrorAction Stop -WhatIf:$false
    Write-Host "Please check the final result file - " + $ResultFilename
}

catch
{
    $ResultFilename = "ESXiServiceStatus_Post_Disable" + (Get-Date).tostring("dd-MM-yyyy-hh-mm-ss") + ".csv"
    $VMSAServiceStatus | export-csv $ResultFilename -notype
    $result = Get-Item $ResultFilename
    Write-Host "Please check the final result file saved in current directory - " $result.fullname
}

$VCConnection = Disconnect-VIServer -Server $vcenter -confirm:$false
