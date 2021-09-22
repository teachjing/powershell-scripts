# Create a new PSCustomObject
$Result = [pscustomobject] @{
    Result1 = $Result1
    Result2 = $Result2
}

Return $Result

###################################################################################################

# Array with PSCustomObject
[System.Collections.ArrayList]$Results = @()

foreach($Item in $Items)
{
    $Result = [pscustomobject] @{
        Result1 = $Item.Result1
        Result2 = $Item.Result2
    }

    [void]$Results.Add($Result)
}

Return $Results