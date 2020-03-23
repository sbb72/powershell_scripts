function Get-FileName ($initialDirectory, $title)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = $title
    $OpenFileDialog.InitialDirectory = $initialDirectory
    #$OpenFileDialog.Filter = "Json (*.Json) | *.Json"
    $OpenFileDialog.ShowDialog() | Out-Null
    return $OpenFileDialog.FileName
} 