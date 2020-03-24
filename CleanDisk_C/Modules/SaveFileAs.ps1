Function Save-FileAs ($Title, $FileTypeFilter)
{
    [reflection.assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
    $SaveDialog= New-Object -Typename System.Windows.Forms.SaveFileDialog
    $SaveDialog.Filter = "csv (*.csv) | *.csv"
    $SaveDialog.Title = $Title
    $SaveDialog.ShowDialog()
    return $SaveDialog.FileName
}