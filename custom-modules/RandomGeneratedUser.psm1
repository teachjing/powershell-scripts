#Powershell Get and Post from URL
#This script will make a GET request to randomuser.me api and generate a random user
#You can pass a domain to generate a random user for a domain for your lab

function New-RandomGeneratedUser {
    Param (
        [Parameter(Mandatory=$true)]  [String]$domain = "user@test.com" #default
    )

    $user = New-Object PSCustomObject
    $randomuser = (Invoke-RestMethod -Uri https://randomuser.me/api/?nat=US).results ##query API
    $fullname = $randomuser.name.first + " " + $randomuser.name.last
    Write-Host -ForeGround "green" "`n'$($fullname)' user has been created using from https://randomuser.me."

	#objects to extract from API
    $filterlist = @('name','gender','location','phone','dob','picture')

	#For each object in list add to user array
    ForEach ($item in $filterlist) {
        $value = $randomuser.$($item) #grabs value of item in filterlist array
        $user | Add-Member -MemberType NoteProperty -Name $item -Value $value #pushes value to user array.
    }
    $parsedUserData = New-Object PSCustomObject
    $parsedUserData | Add-Member -MemberType NoteProperty -Name domain -Value $domain
    $parsedUserData | Add-Member -MemberType NoteProperty -Name password -Value "$(([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | sort {Get-Random})[0..15] -join '')"
    $parsedUserData | Add-Member -MemberType NoteProperty -Name fullname -Value $fullname
    $parsedUserData | Add-Member -MemberType NoteProperty -Name email -Value $("$($randomuser.name.first).$($randomuser.name.last)@$($domain)")
    $parsedUserData | Add-Member -MemberType NoteProperty -Name mailnickname -Value $("$($randomuser.name.first).$($randomuser.name.last)").ToLower()
    $parsedUserData | Add-Member -MemberType NoteProperty -Name streetAddress -Value $("$($randomuser.location.street.number) $($randomuser.location.street.name)")
    $parsedUserData | Add-Member -MemberType NoteProperty -Name city -Value $("$($randomuser.location.city)")
    $parsedUserData | Add-Member -MemberType NoteProperty -Name state -Value $("$($randomuser.location.state)")
    $parsedUserData | Add-Member -MemberType NoteProperty -Name country -Value $("$($randomuser.location.country)")
    $parsedUserData | Add-Member -MemberType NoteProperty -Name phone -Value $("$($randomuser.phone)")
    $parsedUserData | Add-Member -MemberType NoteProperty -Name pictures -Value $("$($randomuser.picture.large)")

    $parsedUserData | Add-Member -MemberType NoteProperty -Name json -Value $randomuser
    return $parsedUserData
}
