function Get-MakeAndModel
{
    return (Get-WMIObject -class Win32_ComputerSystem).Manufacturer + " " + (Get-WMIObject -class Win32_ComputerSystem).Model
}