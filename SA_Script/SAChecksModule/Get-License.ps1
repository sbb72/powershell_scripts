function Get-License {
    Process {
        try {$wpa = Get-CimInstance -ClassName SoftwareLicensingProduct | Where-Object PartialProductKey | Select-Object Name, ApplicationId, LicenseStatus
        } catch {
            $status = New-Object ComponentModel.Win32Exception ($_.Exception.ErrorCode)
            $wpa = $null}
                Foreach ($Item in $wpa.Name) {
                $out = New-Object psobject -Property @{
                Status = [string]::Empty;
                Product = $Item}
                if ($wpa) {
                    :outer foreach($item in $wpa) {
                        switch ($item.LicenseStatus) {
                            0 {$out.Status = "Unlicensed"}
                            1 {$out.Status = "Licensed"; break outer}
                            2 {$out.Status = "Out-Of-Box Grace Period"; break outer}
                            3 {$out.Status = "Out-Of-Tolerance Grace Period"; break outer}
                            4 {$out.Status = "Non-Genuine Grace Period"; break outer}
                            5 {$out.Status = "Notification"; break outer}
                            6 {$out.Status = "Extended Grace"; break outer}
                            default {$out.Status = "Unknown value"}
                        }
                    }
                } else {$out.Status = $status.Message}
                $out
            }
    }
}