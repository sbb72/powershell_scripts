function Get-HPiLOInfo
{
  <#
    .SYNOPSIS
    Retrieves iLO management controller firmware information
    for HP servers.
    Shamelessly Ctrl-C'd and Ctrl-V'd from https://perhof.wordpress.com/2014/03/11/gather-hp-ilo-information-using-powershell/
  
    .DESCRIPTION
    The Get-HPiLOInformation function works through WMI and requires
    that the HP Insight Management WBEM Providers are installed on
    the server that is being quiered.
  
    .PARAMETER Computername
    The HP server for which the iLO firmware info should be listed.
    This parameter is optional and if the parameter isn't specified
    the command defaults to local machine.
    First positional parameter.
  
    .EXAMPLE
    Get-HPiLOInformation
    Lists iLO firmware information for the local machine
  
    .EXAMPLE
    Get-HPiLOInformation SRV-HP-A
    Lists iLO firmware information for server SRV-HP-A
  
    .EXAMPLE
    "SRV-HP-A", "SRV-HP-B", "SRV-HP-C" | Get-HPiLOInformation
    Lists iLO firmware information for three servers
  #>
  [CmdletBinding(SupportsShouldProcess=$true)]
  Param(
  [Parameter(Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position = 1)][string]$Computername=$env:computername)
  
  Process{
  
    if ($pscmdlet.ShouldProcess("Retrieve iLO information from server " +$Computername)){
      $MpFirmwares = Get-WmiObject -Computername $ComputerName -Namespace root\hpq -Query "select * from HP_MPFirmware"
      ForEach ($fw in $MpFirmwares){
        $Mp = Get-WmiObject -Computername $ComputerName -Namespace root\hpq -Query ("ASSOCIATORS OF {HP_MPFirmware.InstanceID='" + $fw.InstanceID + "'} WHERE AssocClass=HP_MPInstalledFirmwareIdentity")
  
        $OutObject = New-Object System.Object
        $OutObject | Add-Member -type NoteProperty -name ComputerName -value $ComputerName
        $OutObject | Add-Member -type NoteProperty -name ControllerName -value $fw.Name
  
        Switch ($Mp.HealthState){
          5 {$stat = "OK"; break}
          10 {$stat = "Degraded/Warning"; break}
          20 {$stat = "Major Failure"; break}
          default {$stat = "Unknown"}
        }
        $OutObject | Add-Member -type NoteProperty -name HealthState -value $stat
        $OutObject | Add-Member -type NoteProperty -name UniqueIdentifier -value $Mp.UniqueIdentifier.Trim()
        $OutObject | Add-Member -type NoteProperty -name Hostname -value $Mp.Hostname
        $OutObject | Add-Member -type NoteProperty -name IPAddress -value $Mp.IPAddress
  
        Switch ($Mp.NICCondition){
          2 {$stat = "OK"; break}
          3 {$stat = "Disabled"; break}
          4 {$stat = "Not in use"; break}
          5 {$stat = "Disconnected"; break}
          6 {$stat = "Failed"; break}
          default {$stat = "Unknown"}
        }
        $OutObject | Add-Member -type NoteProperty -name NICCondition -value $stat
        $OutObject | Add-Member -type NoteProperty -name FirmwareVersion -value $fw.VersionString
        $OutObject | Add-Member -type NoteProperty -name ReleaseDate -value ($fw.ConvertToDateTime($fw.ReleaseDate))
  
        return $OutObject
      }
    }
  }
}
#Get-HPiLOInfo