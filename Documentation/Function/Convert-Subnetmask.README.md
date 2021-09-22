# Convert-Subnetmask

Convert a subnetmask to CIDR and vise versa.

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/Network/Convert-Subnetmask.ps1)

## Description

Convert a subnetmask like 255.255.255 to CIDR (/24) and vise versa.

![Screenshot](Images/Convert-Subnetmask.png?raw=true "Convert-Subnetmask")

## Syntax

```powershell
Convert-Subnetmask [[-CIDR] <Int32>] [<CommonParameters>]

Convert-Subnetmask [[-Mask] <IPAddress>] [<CommonParameters>]
```

## Example 1

```powershell
PS> Convert-Subnetmask -CIDR 24

Mask           CIDR
----           ----
255.255.255.0    24
```

## Example 2

```powershell
PS> Convert-Subnetmask -Mask 255.255.0.0

Mask        CIDR
----        ----
255.255.0.0   16
```
