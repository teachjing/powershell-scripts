# Get-RandomPIN

Generate PINs with freely definable number of numbers.

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/Security/Get-RandomPIN.ps1)

# Description

Generate PINs with freely definable number of numbers. You can also set the smallest and greatest possible number. 

![Screenshot](Images/Get-RandomPIN.png?raw=true "Get-RandomPIN")

## Syntax 

```powershell
Get-RandomPIN [[-Length] <Int32>] [[-Count] <Int32>] [[-Minimum] <Int32>] [[-Maximum] <Int32>] [<CommonParameters>]

Get-RandomPIN [[-Length] <Int32>] [[-CopyToClipboard]] [[-Minimum] <Int32>] [[-Maximum] <Int32>] [<CommonParameters>]
```

## Example 1

```powershell
PS> Get-RandomPIN -Length 6

PIN
---
18176072

```

## Example 2

```powershell
PS> Get-RandomPIN -Length 6 -Count 5 -Minimum 4 -Maximum 8

Count PIN
----- ---
    1 767756
    2 755655
    3 447667
    4 577646
    5 644665
```