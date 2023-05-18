$csvfile = "D:\Temp\test_cmdb.csv"

$csvdata = Import-Csv $csvfile -ErrorAction Stop -Header '(Asset) Host Name'


#$csvdata = @{}

Try {

    $csvdata = Import-Csv $csvfile -ErrorAction Stop
    Write-Host "Imported $csvfile"

}
Catch {

    Write-Host "Cannot import file error: $($_.Exception.Message)"

}


    $csvdata | Foreach-Object { 
        $_.'(Asset) Host Name' = $_.'(Asset) Host Name'.ToString().ToLower()
        $_ 
    } | 
    Export-Csv -Path .\testsb.csv -NoTypeInformation -Force

    foreach ($grp in $csvdata[0].PSObject.Properties) {
        if ($($grp.Name) -match "(Asset)") {
            #$test = $grp.Name.trim('( )') 
            $test = $grp.Name.Replace('(','').Replace(')','')
            Write-Host $test
            #Add-AdGroupMember -Identity $grp.Name -Members $csv."$($grp.Name)"
        }
    }


    foreach($row in $csvdata){
        if (HasValue($row.MayBeNull)){
            $newColumn = $row.MayBeNull
         }
         else{
            $newColumn = $row.MightHaveAValue
         }
         #generate new output
         [psCustomObject]@{
            Id = $row.RowId;
          NewColumn = $newColumn
         }
     }

