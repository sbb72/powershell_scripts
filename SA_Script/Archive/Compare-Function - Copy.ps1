function Compare-Function{

    Param(
        [PSObject]$SurfForm,
        [PSObject]$ServerConfig
        )
    $diffCollection = @() 
    $refObjprops = $SurfForm  | Get-Member -MemberType NoteProperty | ForEach-Object Name
    $difObjprops = $ServerConfig | Get-Member -MemberType NoteProperty | ForEach-Object Name
    $objprops =    $refObjprops + $difObjprops| Sort-Object | Select-Object -Unique

    
    foreach ($prop in $objprops) {
        #$prop
        if($SurfForm.$prop -eq $null) {$SurfForm.$prop = "Null"}
        if($ServerConfig.$prop -eq $null) {$ServerConfig.$prop = "Null"}       
        if($SurfForm.$prop.GetType().isArray){
            for ($i = 0; $i -lt $SurfForm.$prop.Count; $i++) {
                               
                if($SurfForm.$prop[$i].gettype().name -eq 'PSCustomObject'){
                    $pp =  $SurfForm.$prop[$i] | Get-Member -MemberType NoteProperty | ForEach-Object Name
                    $pp +=  $ServerConfig.$prop[$i] | Get-Member -MemberType NoteProperty | ForEach-Object Name
                    $pp = $pp | Get-Unique
                    $comp =  compare-object $SurfForm.$prop[$i]  $ServerConfig.$prop[$i] -Property $pp
                    foreach($item in $comp){
                        if (($item | gm -MemberType noteproperty) -match "InputObject") {
                            $diffprops = New-Object PSObject -Property  @{
                                PropertyName=$prop
                                SurfForm= ($item | Where-Object {$_.SideIndicator -eq '<='}).InputObject
                                ServerConfig= ($item | Where-Object {$_.SideIndicator -eq '=>'}).InputObject
                                }
                            
                        }
                        else{
                            $diffprops = New-Object PSObject -Property  @{
                            PropertyName=$prop
                            SurfForm= $($item | Where-Object {$_.SideIndicator -eq '<='}| Select-Object -Property * -ExcludeProperty SideIndicator) 
                            ServerConfig= $($item | Where-Object {$_.SideIndicator -eq '=>'} | Select-Object -Property * -ExcludeProperty SideIndicator)
                            }
                            $diffCollection += $diffprops
        
                        }
                    }
                }
                else{
                $diffCollection = Compare-Function  $SurfForm.$prop[$i]  $ServerConfig.$prop[$i] $diffCollection
                }
                
            } 
        }
        else{
            if(($SurfForm.$prop -ne $ServerConfig.$prop)  ){
                $diffprops = New-Object PSObject -Property  @{
                    PropertyName=$prop
                    SurfForm= $SurfForm.$prop
                    ServerConfig= $ServerConfig.$prop
                    }
                    $diffCollection += $diffprops
                }
        }

    }

    return $diffCollection
}