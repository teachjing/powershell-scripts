# Create a new object
$Result = New-Object -TypeName PSObject
Add-Member -InputObject $Result -MemberType NoteProperty -Name Parameter1 -Value Result1
Add-Member -InputObject $Result -MemberType NoteProperty -Name Parameter2 -Value Result2
return $Result

###################################################################################################

# Create a new object
$Results = @()

foreach($Line in $Lines)
{
    $Result = New-Object -TypeName PSObject
    Add-Member -InputObject $Result -MemberType NoteProperty -Name Parameter1 -Value $Line.Result1
    Add-Member -InputObject $Result -MemberType NoteProperty -Name Parameter2 -Value $Line.Result2
    $Results += $Result
}

return $Results