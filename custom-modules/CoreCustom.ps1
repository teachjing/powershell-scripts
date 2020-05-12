#Be sure to allow this script to execute. Something like this.
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

#path where all the customModules are located
$CoreCustomPath = Join-Path (Get-Location).path "CoreCustom.psm1"
$CoreCustomName = [io.path]::GetFileNameWithoutExtension($CoreCustomPath)

#Loads the custom Module Loader
Import-Module "$($(Get-Location).path)\CoreCustom.psm1" -Force #loads the module and force it to reload if changes are made.

#Specifies the path and custom modules to load
$customModules = New-Object PSCustomObject
    $customModules | Add-Member -MemberType NoteProperty -Name "path" -Value (Get-Location).Path
    $customModules | Add-Member -MemberType NoteProperty -Name "list" -Value @(
        "RandomGeneratedUser.psm1"
    )

# Loads modules and imports it into the script
Get-CustomModules -modules $customModules #Loads modules from customModules object
Get-Module -Name $CoreCustomName | Import-Module

Write-Host "`nThe following list are the exported commands: "
Get-Command -Module $CoreCustomName

