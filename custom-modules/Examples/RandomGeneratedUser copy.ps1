#Be sure to allow this script to execute. Something like this.
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

#Loads the module
$moduleName = "RandomGeneratedUser"
Import-Module "..\$($moduleName).psm1" -Force #loads the module and force it to reload if changes are made.

Write-Host "`nThe following commands have been imported: "
Get-Command -Module $moduleName

#user variable created from calling function using test.com domain
$user = New-RandomGeneratedUser -domain "test.com"

#output default parsed data
$user

#outputs the json to grab other objects
#$user.json

