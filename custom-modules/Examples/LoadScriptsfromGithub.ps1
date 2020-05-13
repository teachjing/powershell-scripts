#Script URL Location
$scriptURLs = @(
    "https://raw.githubusercontent.com/jingsta/powershell-scripts/master/custom-modules/RandomGeneratedUser.psm1",
    "https://raw.githubusercontent.com/jingsta/powershell-scripts/master/custom-modules/ConvertFrom-EncodedSafeLinks.psm1"
)

#Imports module from github repo directly without cloning
iex ((new-object net.webclient).DownloadString("https://raw.githubusercontent.com/jingsta/powershell-scripts/master/custom-modules/RandomGeneratedUser.psm1"))

New-RandomGeneratedUser -domain "blah.com"

ConvertFrom-EncodedSafeLinks