# Remove-TrustedHost

Remove a trusted host (WinRM).

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/TrustedHost/Remove-TrustedHost.ps1)

## Description

Remove one, multiple or all trusted host(s) (WinRM).

![Screenshot](Images/Remove-TrustedHost.png?raw=true "Remove-TrustedHost")

**Administrative rights are required to execute this command!**

## Syntax

```powershell
Remove-TrustedHost [-TrustedHost] <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]

Remove-TrustedHost [-All] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## Example 1

```powershell
Remove-TrustedHost -TrustedHost "192.168.178.27", "TEST-DEVICE-02"
```

## Example 2

```powershell
Remove-TrustedHost -All
```