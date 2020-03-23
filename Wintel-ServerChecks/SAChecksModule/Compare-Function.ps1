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
        if($SurfForm.$prop.GetType().name -eq 'Hashtable'){
            $keys = $surfFormResults.$prop.Keys
            $keys += $SACheck.$prop.Keys
            $keys = $keys | select-object -Unique
            foreach($k in $keys){
                if($SACheck.$prop.ContainsKey($k) -and $surfFormResults.$prop.ContainsKey($k)){
                $pp  =  ($SACheck.$prop[$k] | Get-Member | Where-Object {$_.MemberType -eq 'NoteProperty'}).Name
                $pp +=  ($surfFormResults.$prop[$k] | Get-Member | Where-Object {$_.MemberType -eq 'NoteProperty'}).Name
                $pp = $pp | select-object -Unique
                    foreach ($p in $pp) {
                        if($SACheck.$prop[$k].$p -ne $surfFormResults.$prop[$k].$p ){
                            
                            $diffObj = [PSCustomObject]@{
                                PropertyName =  $k +' '+ $p
                                SurfForm = $surfFormResults.$prop[$k].$p
                                ServerConfig = $SACheck.$prop[$k].$p
                            }
                            $diffCollection += $diffObj
                        }
                    }
                }
                elseif($surfFormResults.$prop.ContainsKey($k)){
                    $diffObj = [PSCustomObject]@{
                        PropertyName =  $k 
                        SurfForm =  $surfFormResults.$prop[$k] |Format-List | Out-string
                        ServerConfig = "No value returned"
                    }
                    $diffCollection += $diffObj

                }
                elseif($SACheck.$prop.ContainsKey($k)){
                    $diffObj = [PSCustomObject]@{
                        PropertyName =  $k
                        SurfForm = "No value provided"
                        #ServerConfig =  "$($SACheck.$prop[$k])".TrimStart('@{').TrimEnd('}').Replace(';', '\r\n') | out-string
                        ServerConfig =  $SACheck.$prop[$k]  | Format-List | Out-string 
                    }
                    $diffCollection += $diffObj
                }
            }
        }
        elseif($SurfForm.$prop.GetType().isArray){
            for ($i = 0; $i -lt $RefObject.$prop.Count; $i++) {

                $diffCollection = Compare-Function  $RefObject.$prop[$i]  $DiffObject.$prop[$i] $diffCollection

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