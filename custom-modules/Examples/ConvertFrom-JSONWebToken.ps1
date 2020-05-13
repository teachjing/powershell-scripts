#Be sure to allow this script to execute. Something like this.
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

#Loads the module
$moduleName = "ConvertFrom-JSONWebToken"
Import-Module "..\$($moduleName).psm1" -Force  #loads the module and force it to reload if changes are made.

Write-Host "`nThe following commands have been imported: "
Get-Command -Module $moduleName

#user variable created from calling function using test.com domain

#Sample Token from https://www.jsonwebtoken.io/
$SampleToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImp0aSI6IjM5NGQ0NzgwLTA3NWUtNDFiYS1iZTQyLTMwMjJhZjg5MWQ5YyIsImlhdCI6MTU4OTMzNTI1NywiZXhwIjoxNTg5MzM4ODU3fQ.fuptKPDAge2cqOtAOoaqGZ6iJxu-1st1V2zhKwf-sLo"

$ConvertedToken = ConvertFrom-JSONWebToken($SampleToken)

Write-Host "`nHere is the decoded Token information"
$ConvertedToken