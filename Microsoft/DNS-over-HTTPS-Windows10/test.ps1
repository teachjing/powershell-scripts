Import-Module "..\..\custom-modules\MenuSystem.psm1" -Force
Import-Module ".\DNS-over-HTTPS-Windows10.psm1" -Force

$Servers = Get-DOHServers
$Servers | Format-Table

