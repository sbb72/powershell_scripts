
function Get-SurfForm{
    param(
        $SurfImport
    )


    $SACheck = New-Object psobject -Property @{
        Date=(Get-Date).ToString()
        Engineer=$env:USERNAME
        Servername = ""
        Domain=""
        Model=""
        DomainOU=""
        CPUCount=0
        RAM=0
        Disks=@{}
        PagefileLocation=""
        PagefileSize=""
        OS=""
        License=""
        Network=@{}
        }
    if (-not [string]::IsNullOrEmpty($SurfImport)) {
        $checkServerExist = $SurfImport  | Where-Object {$_.Key -eq 'ServerName*'} `
        | Get-Member -MemberType NoteProperty `
        | Where-Object {($_.name -like "Server*") -and ($_.Definition -like "*$env:computername")}       
    }
    else{
        Write-Warning  "Surfimport parameter is null or empty"
        if($host.name -eq 'ConsoleHost'){
        Write-Host -NoNewLine 'Press any key to continue...'
        $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-null
        }
    
        Exit
    }


    if($checkServerExist.count -eq 0){
        Write-Warning  "The target server can not be found in the surf form. Ensure the 'Servername' field on the Surf form contains the hostname of this server"
        if($host.name -eq 'ConsoleHost'){
        Write-Host -NoNewLine 'Press any key to continue...'
        $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-null
        }
    
        Exit
    }

    for($i = 0; $i -lt $SurfImport.Count; $i++){
        if(-not[string]::IsNullOrEmpty($SurfImport[$i].key))
        {
            #$dict.Add($SurfImport[$i].Key,$SurfImport[$i].($checkServerExist.Name))
            if($SurfImport[$i].key -eq 'ServerName*' -and (-not[string]::IsNullOrEmpty($SurfImport[$i].($checkServerExist.Name))) ){
                $SACheck.Servername = $SurfImport[$i].($checkServerExist.Name)
            }
            elseif($SurfImport[$i].key -eq 'Domain*' -and (-not[string]::IsNullOrEmpty($SurfImport[$i].($checkServerExist.Name)))){
                $SACheck.Domain = $SurfImport[$i].($checkServerExist.Name)
            }
            elseif($SurfImport[$i].key -eq 'DomainOU*' -and (-not[string]::IsNullOrEmpty($SurfImport[$i].($checkServerExist.Name)))){
                $SACheck.DomainOU = $SurfImport[$i].($checkServerExist.Name)
            }
            elseif($SurfImport[$i].key -eq 'CPU Count*' -and (-not[string]::IsNullOrEmpty($SurfImport[$i].($checkServerExist.Name)))){
                $SACheck.CPUCount = $SurfImport[$i].($checkServerExist.Name)
            }
            elseif($SurfImport[$i].key -eq 'RAM*' -and (-not[string]::IsNullOrEmpty($SurfImport[$i].($checkServerExist.Name)))){
                $SACheck.RAM = $SurfImport[$i].($checkServerExist.Name)
            }
            elseif($SurfImport[$i].key -eq 'PageFileLocation*' -and (-not[string]::IsNullOrEmpty($SurfImport[$i].($checkServerExist.Name)))){
                $SACheck.PageFileLocation = $SurfImport[$i].($checkServerExist.Name)
            }
            elseif($SurfImport[$i].key -eq 'PageFileSize*' -and (-not[string]::IsNullOrEmpty($SurfImport[$i].($checkServerExist.Name)))){
                $SACheck.PageFileSize = $SurfImport[$i].($checkServerExist.Name)
            }
            elseif($SurfImport[$i].key -eq 'OS*' -and (-not[string]::IsNullOrEmpty($SurfImport[$i].($checkServerExist.Name)))){
                $SACheck.OS = $SurfImport[$i].($checkServerExist.Name)
            }
            elseif($SurfImport[$i].key -eq "License*" -and (-not[string]::IsNullOrEmpty($SurfImport[$i].($checkServerExist.Name)))){
                $SACheck.License = $SurfImport[$i].($checkServerExist.Name)
            }
            elseif ($SurfImport[$i].key -like "Disk*" -and (-not[string]::IsNullOrEmpty($SurfImport[$i].($checkServerExist.Name)))) {
                $r = $i+4
                $diskdict = @{}
                for ($i; $i -lt $r; $i++) {
                    $diskdict.Add($SurfImport[$i].key.split(" ")[1], $SurfImport[$i].($checkServerExist.Name))
                }
                # do {
                #     $diskdict.Add($SurfImport[$i].key.split(" ")[1], $SurfImport[$i].($checkServerExist.Name))
                #     $i++
                # } until ($i -eq $r)
                $diskInfo = New-Object -TypeName PSObject -Property @{
                    DeviceID = if($diskdict.'DriveLetter*'){$diskdict.'DriveLetter*'}else{"undefined"}
                    Size = $diskdict.'Size*'
                    DriveType = $diskdict.'DriveType*'
                    VolumeName = $diskdict.'VolumeName*'
                }
                #$SACheck.Disks += $diskInfo 
                $SACheck.Disks += @{$diskInfo.DeviceID= $diskInfo}
                $i--

            }
            elseif($SurfImport[$i].key -like "NIC*" -and (-not[string]::IsNullOrEmpty($SurfImport[$i].($checkServerExist.Name)))){
                $r = $i+6
                $nicdict = @{}
                for ($i; $i -lt $r; $i++) {
                    $nicdict.Add($SurfImport[$i].key.split(" ")[1], $SurfImport[$i].($checkServerExist.Name))
                }
                $nicInfo = New-Object -TypeName PSObject -Property @{
                    Description = if($nicdict.'Label*'){$nicdict.'Label*'}else{"Undefined"}
                    Ipaddress = $nicdict.'Ipaddress*'
                    IPSubnet = $nicdict.'IPSubnet*'
                    DefaultIPGateway = $nicdict.'DefaultIPGateway*'
                    DNS_Servers1 = $nicdict.'DNSServers1*'
                    DNS_Servers2 = $nicdict.'DNSServers1*'
                }
                $SACheck.Network += @{$nicInfo.Description = $nicInfo}
                $i--
            }
        }
    }

    $SACheck
}