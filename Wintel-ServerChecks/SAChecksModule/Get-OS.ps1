function Get-OS
{
    
    $osDescriptionText = (Get-WmiObject -Class Win32_OperatingSystem).caption + " - Service Pack " + (Get-WmiObject -Class Win32_OperatingSystem).ServicePackMajorVersion
    
    #return (Get-WmiObject -Class Win32_OperatingSystem).caption
}