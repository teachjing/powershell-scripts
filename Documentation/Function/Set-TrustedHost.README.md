# Set-TrustedHost

Set a trusted host (WinRM).

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/TrustedHost/Set-TrustedHost.ps1)

## Description

Set one or mulitple trusted host(s) (WinRM).

![Screenshot](Images/Set-TrustedHost.png?raw=true "Set-TrustedHost")

**Administrative rights are required to execute this command!**

## Syntax

```powershell
Set-TrustedHost [-TrustedHost] <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## Example

```powershell
PS> Set-TrustedHost -TrustedHost "192.168.178.28", "TEST-DEVICE-01"

Confirm
Are you sure you want to perform this action?
Performing the operation "Add-TrustedHost" on target "WSMan:\localhost\Client\TrustedHosts".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): Y

PS> Get-TrustedHost

TrustedHost
-----------
192.168.178.28
TEST-DEVICE-01
```