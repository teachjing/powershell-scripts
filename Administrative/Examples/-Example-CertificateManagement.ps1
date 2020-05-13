#Be sure to allow this script to execute. Something like this.
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

#Loads the module
$moduleName = "CertificateManagement"
Import-Module ".\$($moduleName).psm1" -Force  #loads the module and force it to reload if changes are made.

Write-Host "`nThe following commands have been imported: "
Get-Command -Module $moduleName

#New-GeneratedSelfSignedCert