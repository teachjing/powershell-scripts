# Get-LastBootTime

Get the time when a computer is booted. 

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/Windows/Get-LastBootTime.ps1)

## Description

Get the time when a computer is booted. 

![Screenshot](Images/Get-LastBootTime.png?raw=true "Get-LastBootTime")

## Syntax

```powershell
Get-LastBootTime [[-ComputerName] <String[]>] [[-Credential] <PSCredential>] [<CommonParameters>]
```

## Example 1

```powershell
Get-LastBootTime -ComputerName Windows7x64

ComputerName LastBootTime
------------ ------------
Windows7x64  8/21/2016 3:25:29 PM
```