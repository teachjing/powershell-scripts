## Connect to exchange online

Import-Module ExchangeOnlineManagement

Connect-ExchangeOnline -UserPrincipalName "blah@domain.com"

## Exports Exchange transport rules to C:\temp folder ##
$filePath = "C:\temp\ExchangeTransportRules.xml"
$file = Export-TransportRuleCollection
Set-Content -Path $filePath -Value $file.FileData -Encoding Byte

## Import Exchange Transport Rules
[Byte[]]$Data = Get-Content -Path $filePath -Encoding Byte -ReadCount 0
Import-TransportRuleCollection -FileData $Data