Import-Module ".\MenuModule.psm1" -Force
Import-Module ".\Get-DOHServers.psm1" -Force

$Servers = Get-DOHServers
$Servers | Format-Table

