# Get-MACVendor

Get Vendor from a MAC-Address.

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/Network/Get-MACVendor.ps1)

## Description

Get Vendor from a MAC-Address, based on the MAC-Address or the first 6 digits.

![Screenshot](Images/Get-MACVendor.png?raw=true "Get-MACVendor")

## Syntax

```powershell
Get-MACVendor [-MACAddress] <String[]> [<CommonParameters>]
```

## Example

```powershell
PS> Get-MACVendor -MACAddress 5C:49:79:8A:0B:77, 5C-49-79

MACAddress        Vendor
----------        ------
5C:49:79:8A:0B:77 AVM Audiovisuelles Marketing und Computersysteme GmbH
5C-49-79          AVM Audiovisuelles Marketing und Computersysteme GmbH
```
