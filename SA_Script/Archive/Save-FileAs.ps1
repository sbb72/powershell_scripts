Function Save-FileAs ($Title, $FileTypeFilter)
{
    $SaveDialog= New-Object -Typename System.Windows.Forms.SaveFileDialog
    $SaveDialog.Filter = "html (*.html) | *.html"
    $SaveDialog.Title = $Title
    $SaveDialog.ShowDialog()
    return $SaveDialog.FileName
}