
#---------------------------------- Compare Function ---------------------------------------

#$DiffObject

#$RefObject
function Format-Output {

    Param(
        $results,
        $FilePath
      )
    "<head><style>td{border-bottom: 1px solid black; border-left: 1px solid black;}</style></head>" +
    '<html>' +
    '<table style="width:100%">' +
    '<tr style="background-color: white;"><td>Property</td> <td>Ref</td> <td>Diff</td> <tr>' | Out-file $FilePath -Append

    foreach ($item in $results)
    {
    
        if([string]::IsNullOrEmpty($item.RefValue)){$item.RefValue = "N/A"}
        if( [string]::IsNullOrEmpty($item.DiffValue)){$item.DiffValue = "N/A"}
        "<tr><td>"+ $item.PropertyName + "</td> <td>" +$item.DiffValue+"</td> <td style=""color:red;"">"+$item.RefValue+"</td> </tr>" |
            Out-file $FilePath -Append
   
    }
        '<table style="width:100%">'+"</html>"  |  Out-file $FilePath -Append
}

 

function Compare-Function{

    Param(
        [PSObject]$RefObject,
        [PSObject]$DiffObject,
        [array]$diffCollection 

        )

    $refObjprops = $RefObject  | Get-Member -MemberType NoteProperty | ForEach-Object Name
    $difObjprops = $DiffObject | Get-Member -MemberType NoteProperty | ForEach-Object Name
    $objprops =    $refObjprops + $difObjprops| Sort-Object | Select-Object -Unique

    
    foreach ($prop in $objprops) {
        #$prop
        if($RefObject.$prop -eq $null) {$RefObject.$prop = "Null"}
        if($DiffObject.$prop -eq $null) {$DiffObject.$prop = "Null"}
        if($RefObject.$prop.count -ne $DiffObject.$prop.count){
            $pp =  $RefObject.$prop | Get-Member -MemberType NoteProperty | ForEach-Object Name
            $pp +=  $DiffObject.$prop | Get-Member -MemberType NoteProperty | ForEach-Object Name
            $pp = $pp | Get-Unique
            $comp =  compare-object $RefObject.$prop  $DiffObject.$prop -Property $pp
            foreach($item in $comp){
                 if (($item | gm -MemberType noteproperty) -match "InputObject") {
                    $diffprops = New-Object PSObject -Property  @{
                        PropertyName=$prop
                        RefValue= ($item | Where-Object {$_.SideIndicator -eq '<='}).InputObject
                        DiffValue= ($item | Where-Object {$_.SideIndicator -eq '=>'}).InputObject
                        }
                    
                }
                else{
                    $diffprops = New-Object PSObject -Property  @{
                    PropertyName=$prop
                    RefValue= ($item | Where-Object {$_.SideIndicator -eq '<='}| Select-Object -Property * -ExcludeProperty SideIndicator) 
                    DiffValue= ($item | Where-Object {$_.SideIndicator -eq '=>'} | Select-Object -Property * -ExcludeProperty SideIndicator)
                    }

                }
            }


        }
        elseif($RefObject.$prop.GetType().isArray -and `
           $RefObject.$prop.count -ne 0 -and `
          ($RefObject.$prop  | Get-Member -MemberType NoteProperty).count -eq 0){

           $comp =  compare-object $RefObject.$prop  $DiffObject.$prop
           $diffprops = New-Object PSObject -Property  @{
            PropertyName=$prop
            RefValue= ($comp | Where-Object {$_.SideIndicator -eq '<='}).inputobject
            DiffValue= ($comp | Where-Object {$_.SideIndicator -eq '=>'}).inputobject
            }
            $diffCollection += $diffprops
    
        }
        elseif($RefObject.$prop.GetType().isArray -and $RefObject.$prop.count -ne 0 ){

            for ($i = 0; $i -lt $RefObject.$prop.Count; $i++) {
                               
                $diffCollection = Compare-Function  $RefObject.$prop[$i]  $DiffObject.$prop[$i] $diffCollection
                
            }

        }
        else{
            if(($RefObject.$prop -ne $DiffObject.$prop)  ){
                $diffprops = New-Object PSObject -Property  @{
                    PropertyName=$prop
                    RefValue= $RefObject.$prop
                    DiffValue= $DiffObject.$prop
                    }
                    $diffCollection += $diffprops
            }

        }

    }

    return $diffCollection
}
#$diffCollection1 = @()
#Compare-Function  $SACheck  $refconfig $diffCollection1

#$objprops = $SACheck   | Get-Member -MemberType NoteProperty | ForEach-Object Name
#$objprops1 = $refconfig | Get-Member -MemberType NoteProperty | ForEach-Object Name
#$objprops = $objprops | Sort-Object | Select-Object -Unique







#------------------------Get-Filename----------------------------------------------------------------------------


function Get-FileName ($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = "Select a Json file"
    $OpenFileDialog.InitialDirectory = $initialDirectory
    $OpenFileDialog.Filter = "Json (*.Json) | *.Json"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.FileName
} 