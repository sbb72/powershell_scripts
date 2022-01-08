param (
    [string]$SearchString,              # e.g. JndiLookup.class
    [string]$Path,                      # Path to scan, if not specified will scan all drives
    [string[]]$ExcludeFilesWithName,    # e.g. patched versions of files such as log4j-core-2.16.0.jar
    [switch]$InteractiveMode,           # Shows output of drive scanning
    [switch]$Remediate                  # Removes found files from archives, if not set will display only
)

# Required param - $SearchString
if([String]::IsNullOrEmpty($SearchString))
{
    Write-Host "Invalid search string supplied" -ForegroundColor Red
    exit 1
}

function RemoveItemFromZip {
    param (
        [string]$ZipArchivePath, # Path to either the zip file root, or a directory within a zip file
        [string]$ItemName,       # Name of the item to be removed
        [string]$TempLocation,   # Location to move files to before removing
        [object][ref]$Shell      # COM Shell.Application reference        
    )

    # Obtain reference to the namespace of the shell at the required location
    $namespace = $Shell.NameSpace($ZipArchivePath) 

    # Search for items directly under the specified path
    ($namespace.Items()) | Where-Object { $_.Name -like $ItemName } | ForEach-Object {
        #Item found, move it out of the zip and remove it
        Write-Host "Removing $($_.Path)" -ForegroundColor Red
        $Shell.Namespace($TempLocation).MoveHere($_)
        Remove-Item (Join-Path $TempLocation $_.Name)
    }        
    
    # For any directories under the specified path, run recursively
    ($namespace.Items()) | Where-Object { $_.Type -eq 'File Folder'} | Foreach-Object {
        RemoveItemFromZip -ZipArchivePath $($_.Path) -ItemName $ItemName -TempLocation $Templocation -Shell ([ref]$Shell)
    }

}

# Set search location by path, or run all drives if not specified
$searchLocations = @()
if($null -ne $Path)
{
    # Path Specified manually
    $searchLocations += $Path
}
else 
{
    # Scan all drives
    $localDrives = get-psdrive -PSProvider "FileSystem" 
    foreach ($drive in $localDrives)
    {
        $searchLocations += $drive.Root
    }
}

# Scan search locations
$foundFiles = $null
foreach ($location in $searchLocations)
{
    if($InteractiveMode)
    {
        Write-Host -ForegroundColor Green "Searching " $location
    }
    $foundFiles += (get-childitem -Path $location -include @('*.jar','*.war','*.ear') -Exclude $ExcludeFilesWithName -Recurse -ErrorAction SilentlyContinue)
}  

if($null -eq $foundFiles)
{
    Write-Host "No jar, war, or ear files found" -ForegroundColor Green
}
else 
{
    # Archive files found, check contents for a match and collate results
    $foundItems = @()
    foreach ($file in $foundFiles)
    {
        $stringResult = $null
        $stringResult = ($file | Select-String -Pattern $SearchString)
        if ($null -ne $stringResult)
        {
            $itemPath = "$($file.Directory)\$($file.Name)"
            Write-Host $itemPath -ForegroundColor Magenta
            $foundItems += $itemPath
        }
    }

    if($null -eq $foundItems -or $foundItems.Length -eq 0)
    {
        Write-Host "No matches found" -ForegroundColor Green
    }
    elseif($Remediate -eq $true)
    {
        # Remediate by removing the file from the archive
        foreach($archive in $foundItems)
        {
            # To remove files from a jar, war, or ear, use the Shell.Application COM object and
            # move them using the shell to a temporary location before deleting the item with PowerShell.
            # Before we can use the shell to access the archive, it must first be renamed
            # temporarily with a .zip file extension

            # Directory to move the files to (parent directory of the archive)
            $tmpLocation = Split-Path -Path $archive 

            # Temporary name of the file while it is being accessed
            $tmpFileName = "$((Get-Item -Path $archive).Name).zip"

            try
            {
                Rename-Item -Path $archive -NewName $tmpFileName
                $shell = New-Object -COM 'Shell.Application'
                RemoveItemFromZip -ZipArchivePath "$($archive).zip" -ItemName $SearchString -TempLocation $tmpLocation -Shell ([ref]$shell)
            
                # Once complete, restore the original file extension
                Rename-Item -Path "$($archive).zip" -NewName $archive
            }
            catch 
            {
                "An error occured remediating $archive"
            }
        }
    }
}