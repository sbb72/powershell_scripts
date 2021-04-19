function Get-NetAppEvents {
    <#
        .SYNOPSIS
        A function for textracting Events from NetApp OnCommand Unified Manager.
        Tested via OnCommand Unified Manager Version: 9.5P1 only

        .DESCRIPTION
        The function establishes a connection to OnCommand Unified Managerand extracts Events from the last 23 hours.

        .PARAMETER ComputerName
        Name of the OnCommand Unified Manager to be checked.

        .PARAMETER Type
        Type of healthcheck. The default is "NetApp".

        .PARAMETER Application
        Optional. The application that the healthcheck is for.

        .PARAMETER Team
        The support team for the technology. The default is Wintel.

        .PARAMETER Criticality
        The criticality of the CI/service being tested (1 is most critical). Default for
        NetApp is 1.

        .PARAMETER CredentialFor
        Name of the credential profile to use for connecting to NetApp.  Saved using 'Write-SavedCredential -For'
        This is a mandatorty switch

        .PARAMETER $EventsinHrs
        Time range in hours searching for Events.  Default is 24hrs

        .EXAMPLE
        PS C:\> Get-NetAppEvents -ComputerName "oncmd01v" -CredentialFor "NetAppaccount" -Application "NetAppEvents"
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$ComputerName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]$Type = "NetApp",

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]$Application,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]$Team = "Wintel",

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Int]$Criticality = 1,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$CredentialFor,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Int]$EventsinHrs = 24
    )



Begin {
#Use TLS 1.2 when connecting to OnCommand Unified Manager 
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
    $AllProtocols = [System.Net.SecurityProtocolType]'Tls12'
    [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols 
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

    $NetAppResponse = New-Object System.Collections.Generic.List[object]

    if ($CredentialFor) {
        if (-not ($NetAppCreds = Read-SavedCredential -For $CredentialFor)) {
            # Template response for NetApp
            $NetAppResponse = New-Object -TypeName PSObject -Property @{
                "@timestamp"   = [datetime]::UtcNow;
                "Type"         = $Type;
                "Application"  = $Application;
                "Team"         = $Team;
                "Status"       = "Critical";
                "Criticality"  = $Criticality;
                "Exec_User"    = "$($env:USERDOMAIN)\$($env:USERNAME)";
                "Exec_Machine" = $env:COMPUTERNAME;
                "Message"      = "Credentials required but missing";
                "CI"           = $ComputerName;
                "Component"    = "NetApp";
                "Detail"       = "Unable to find saved credentials for '$CredentialFor', save by running 'Write-SavedCredential -For $CredentialFor' as the service account";
                "FaultArray"   = $null;
            }

            $NetAppResponse.FaultArray = New-HealthcheckResultFaultObject -HealthcheckResponse $NetAppResponse
            return $NetAppResponse
        }
        else
        { $NetAppCreds = Read-SavedCredential -For $CredentialFor }
    }
    Else {
        # Template response for NetApp
        $NetAppResponse = New-Object -TypeName PSObject -Property @{
            "@timestamp"   = [datetime]::UtcNow;
            "Type"         = $Type;
            "Application"  = $Application;
            "Team"         = $Team;
            "Status"       = "Critical";
            "Criticality"  = $Criticality;
            "Exec_User"    = "$($env:USERDOMAIN)\$($env:USERNAME)";
            "Exec_Machine" = $env:COMPUTERNAME;
            "Message"      = "Credentials required but missing";
            "CI"           = $ComputerName;
            "Component"    = "NetApp";
            "Detail"       = "Unable to find saved credentials for '$CredentialFor', save by running 'Write-SavedCredential -For $CredentialFor' as the service account";
            "FaultArray"   = $null;
        }

        $NetAppResponse.FaultArray = New-HealthcheckResultFaultObject -HealthcheckResponse $NetAppResponse
        return $NetAppResponse
    }
}

Process {
    $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($NetAppCredential.UserName):$($NetAppCredential.GetNetworkCredential().Password)"))

    $Headers = @{}
    $Headers.Add("Accept", "application/vnd.netapp.object.inventory.hal+json")
    $Headers.Add("Content-Type", "application/vnd.netapp.object.inventory.hal+json")
    $headers.Add("Authorization", "Basic $auth")

    [String]$uri = "https://$ComputerName/rest/v1/events?filter=eventState,is,NEW&triggeredTime=LAST_$EventsinHrs" + "h"

    Try {

        $response = Invoke-RestMethod -method GET -uri $uri -header $headers -ErrorAction Stop
        Write-Warning -Message $("Using URI WORKED!!""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)

    }
    Catch {

        Write-Warning -Message $("Using URI ""$uri"". Error " + $_.Exception.Message + ". Status Code " + $_.Exception.Response.StatusCode.value__)
        # Template response for NetApp
        $NetAppResponse = New-Object -TypeName PSObject -Property @{
            "@timestamp"   = [datetime]::UtcNow;
            "Type"         = $Type;
            "Application"  = $Application;
            "Team"         = $Team;
            "Status"       = "Critical";
            "Criticality"  = $Criticality;
            "Exec_User"    = "$($env:USERDOMAIN)\$($env:USERNAME)";
            "Exec_Machine" = $env:COMPUTERNAME;
            "Message"      = "Unable to complete the API call";
            "CI"           = $ComputerName;
            "Component"    = "API";
            "Detail"       = "Unable to complete thge API call, error message: $($_.Exception.Message)";
            "FaultArray"   = $null;
        }
        $NetAppResponse.FaultArray = New-HealthcheckResultFaultObject -HealthcheckResponse $NetAppResponse
        return $NetAppResponse

    }

    $Responses = New-Object System.Collections.Generic.List[object]
    $NetAppResponse = New-Object System.Collections.Arraylist
    $NetAppResponseDetail = New-Object System.Collections.Arraylist
    $NetAppResponseComponent = New-Object System.Collections.Arraylist

    foreach ($NetAppEvent in $response._embedded."netapp:eventDtoList") {

        $NetAppResponse = [PSCustomObject]@{
            "@timestamp"   = [datetime]::UtcNow;
            "Type"         = $Type;
            "Application"  = $Application;
            "Team"         = $Team;
            "Status"       = "Critical";
            "Criticality"  = $Criticality;
            "Exec_User"    = "$($env:USERDOMAIN)\$($env:USERNAME)";
            "Exec_Machine" = $env:COMPUTERNAME;
            "Message"      = @();
            "CI"           = $ComputerName;
            "Component"    = @();
            "Detail"       = @();
            "FaultArray"   = $null;

        }

        If ($NetAppEvent.Name -match "Volume Days Until Full") {
            $NetAppResponse.Criticality = "2"
            $NetAppResponse.Status = "Warning"

            $NetAppResponse.Message = $NetAppEvent.Name

            [void]$NetAppResponseDetail.Add($NetAppEvent.objectId)
            $adddatetimetodetail = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddMilliseconds($NetAppEvent.timestamp)) | get-date -Format 'dd-MM-yyyy HH:mm:ss'
            [void]$NetAppResponseDetail.Add("Date of Error: $adddatetimetodetail")
            [void]$NetAppResponseDetail.Add($NetAppEvent.state)
            [void]$NetAppResponseDetail.Add($NetAppEvent.conditionMessage)
            [void]$NetAppResponseDetail.Add($NetAppEvent.sourceFullName)


            [void]$NetAppResponseComponent.Add($NetAppEvent.impactArea)
            [void]$NetAppResponseComponent.Add($NetAppEvent.sourceResourceType)

            $NetAppResponse.Detail = [String]($NetAppResponseDetail -join "`n")
            $NetAppResponse.Component = [String]($NetAppResponseComponent -join "`n")

            $Responses.Add($NetAppResponse)
            $NetAppResponseDetail.Clear()
            $NetAppResponseComponent.Clear()

        }

        Else {
            if ($NetAppEvent.Name -match "Max Number of CIFS Connection Per User Exceeded" -or "Max CIFS Connection Exceeded")
            { }
            ELSE {
                $NetAppResponse.Message = $NetAppEvent.Name

                [void]$NetAppResponseDetail.Add($NetAppEvent.objectId)
                $adddatetimetodetail = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddMilliseconds($NetAppEvent.timestamp)) | get-date -Format 'dd-MM-yyyy HH:mm:ss'
                [void]$NetAppResponseDetail.Add("Date of Error: $adddatetimetodetail")
                [void]$NetAppResponseDetail.Add($NetAppEvent.state)
                [void]$NetAppResponseDetail.Add($NetAppEvent.conditionMessage)
                [void]$NetAppResponseDetail.Add($NetAppEvent.sourceFullName)


                [void]$NetAppResponseComponent.Add($NetAppEvent.impactArea)
                [void]$NetAppResponseComponent.Add($NetAppEvent.sourceResourceType)

                $NetAppResponse.Detail = [String]($NetAppResponseDetail -join "`n")
                $NetAppResponse.Component = [String]($NetAppResponseComponent -join "`n")

                $Responses.Add($NetAppResponse)
                $NetAppResponseDetail.Clear()
                $NetAppResponseComponent.Clear()

            }


        }

        Return $Responses
    }

}   
}
