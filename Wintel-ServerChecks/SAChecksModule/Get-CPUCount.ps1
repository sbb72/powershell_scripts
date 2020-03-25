function Get-CPUCount {
    (Get-WmiObject win32_processor).numberoflogicalprocessors | foreach { $sum += $_ }  
    return $sum
}