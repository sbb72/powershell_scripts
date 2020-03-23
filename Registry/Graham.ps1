#Declare array to hold all the information
$serverdetails = @()

#Get all the server names from the servers.txt file.
$servers = Get-Content -Path .\servers.txt

foreach ($server in $servers) {
    #check remote registry service is running
    $service = Get-Service -ComputerName $server -Name RemoteRegistry -ErrorAction SilentlyContinue
    $test = $service.Status

    if ($service.status -eq 'Running') {
        $type = [Microsoft.Win32.RegistryHive]::LocalMachine
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($type, $server)
        #Make sure our keys are null every time
        $KeyV3 = $null
        $KeyV4 = $null
        #Check for version 3 serial    
        $keyV3 = $reg.OpenSubKey("SOFTWARE\triCerat\Simplify Printing\ScrewDrivers Server v3")
        #Check for version 4 serial
        $keyV4 = $reg.OpenSubKey("SOFTWARE\triCerat\Simplify Printing\ScrewDrivers Server v4")
        #Check if there is a V3 Serial key and create an object if there is
        if ($keyV3 -ne $null) {
            $object = [pscustomobject][ordered]@{"Server Name" = $server; "Service Status" = $service.status; "V3 Licence" = $keyV3.GetValue("licenseSerial"); "V4 Licence" = $null }
            $serverdetails += $object
        }
        #Check if there is a V4 Serial Key and create an object if there is
        elseif ($keyV4 -ne $null) {
            $object = [pscustomobject][ordered]@{"Server Name" = $server; "Service Status" = $service.status; "V3 Licence" = $null; "V4 Licence" = $keyV4.GetValue("licenseSerial") }
            $serverdetails += $object
        }
    }
    else {
        #Could put some code in here to try and turn the remote registry service on?    
        $object = [pscustomobject][ordered]@{"Server Name" = $server; "Service Status" = "Stopped"; "V3 Licence" = $null; "V4 Licence" = $null }
        $serverdetails += $object
    }
}

#Ouput the information that we have gathered.
$serverdetails | ConvertTo-Html | Out-file .\results.html