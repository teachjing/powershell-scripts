# Add-TrustedHost

Add a trusted host (WinRM).

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/TrustedHost/Add-TrustedHost.ps1)

## Description

Add one or mulitple trusted host(s) (WinRM).

![Screenshot](Images/Add-TrustedHost.png?raw=true "Add-TrustedHost")

**Administrative rights are required to execute this command!**

## Syntax

```powershell
Add-TrustedHost [-TrustedHost] <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## Example

```powershell
PS> Add-TrustedHost -TrustedHost "192.168.178.27", "TEST-DEVICE-02"

Confirm
Are you sure you want to perform this action?
Performing the operation "Add-TrustedHost" on target "WSMan:\localhost\Client\TrustedHosts".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): Y

PS> Get-TrustedHost

TrustedHost
-----------
192.168.178.28
TEST-DEVICE-01
192.168.178.27
TEST-DEVICE-02
```