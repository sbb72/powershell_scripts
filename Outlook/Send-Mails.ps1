Function Global:Send-Email {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [String]$Address = "",
        [Parameter(Mandatory = $False, Position = 1)]
        [String]$Subject = "xHF",
        [Parameter(Mandatory = $False, Position = 2)]
        [String]$Body = "Pontypool"
        
    )
    Begin {
        Clear-Host
        # Add-Type -assembly "Microsoft.Office.Interop.Outlook"
    }
    Process {
        # Create an instance Microsoft Outlook
        $Outlook = New-Object -ComObject Outlook.Application
        $Mail = $Outlook.CreateItem(0)
        $Mail.To = "$Address"
        $Mail.Subject = $Subject
        $Mail.Body = $Body
        $Mail.Attachments.Add("D:\Data\temp\DXC_Page3.jpg")
        # $Mail.HTMLBody = "When is swimming?"
        # $File = "D:\CP\timetable.pdf"
        # $Mail.Attachments.Add($File)
        $Mail.Send()
    } # End of Process section
    End {
        # Section to prevent error message in Outlook
        $Outlook.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Outlook)
        $Outlook = $null
    } # End of End section!
} # End of function

# Example of using this function
Send-Email #-Address deck@swimmingpool.com