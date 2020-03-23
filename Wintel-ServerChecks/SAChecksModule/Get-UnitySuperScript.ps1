function Get-UnitySuperScript

{
$initialDirectory = "C:\_Un1ty\superscript"
$folder = Test-Path $initialDirectory


if ($folder -eq $true) {return "Installed"}

else 

{return "Not Installed"}
}