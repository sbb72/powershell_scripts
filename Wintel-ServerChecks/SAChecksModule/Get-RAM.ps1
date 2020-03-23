function Get-RAM  
{
    (Get-WmiObject CIM_PhysicalMemory).capacity | foreach{$sum+=$_}  
    return $sum/1gb
 }