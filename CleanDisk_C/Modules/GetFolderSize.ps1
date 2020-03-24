<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-FolderSize
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Path,

        [Parameter(Mandatory=$false)]
       [switch]$Recurse,

       $SizeBiggerThan = 15
    )

    Begin
    {
      $source =  @'
       using System;
       public class folder{
       public string FolderName;
       public double FolderSize; 
       public double ConvertToMB(double size)
       {           
          double sizeinGB = (size / 1024f) / 1024f;
          return Math.Round(sizeinGB, 2);          
       }
       }

'@
        try{Add-Type -TypeDefinition $source}catch{ Write-host "Error Occured" -ForegroundColor Red}
        $foldercol = @()
        $fso = New-object -ComObject Scripting.FilesystemObject
        $folders = [System.IO.Directory]::GetDirectories($path)
    }
    Process
    {
      
      
      if($recurse){
              foreach($directory in $folders){

               # Write-Progress -Activity “Discovering folder sizes” -status “Currently folder: $directory” 
 
                $folder = $fso.GetFolder($directory)
                $obj = New-Object folder
                $obj.FolderName = $directory
                $obj.FolderSize = $obj.ConvertToMB($folder.size)

                $foldercol += $obj
                $obj = $null
                }
        }
        else{
               # Write-Progress -Activity “Discovering the folder size” -status “Currently folder: $path” 
 
                $folder = $fso.GetFolder($path)
                $obj = New-Object folder
                $obj.FolderName = $path
                $obj.FolderSize = $obj.ConvertToMB($folder.size)

                $obj
                $obj = $null
            }



    }
    End
    {
        $foldercol #| Sort-Object FolderSize -Descending | where {$_.FolderSize -ge $SizeBiggerThan} | format-table -AutoSize
    }
}
