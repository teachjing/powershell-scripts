# Get-RandomPassword

Generate passwords with a freely definable number of characters.

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/Security/Get-RandomPassword.ps1)

## Description

Generate passwords with a freely definable number of characters. You can also select which chars you want to use (upper case, lower case, numbers and special chars).

![Screenshot](Images/Get-RandomPassword.png?raw=true "Get-RandomPassword")

## Syntax 

```powershell
Get-RandomPassword [[-Length] <Int32>] [[-Count] <Int32>] [[-DisableLowerCase]] [[-DisableUpperCase]] [[-DisableNumbers]] [[-DisableSpecialChars]] [<CommonParameters>]

Get-RandomPassword [[-Length] <Int32>] [[-CopyToClipboard]] [[-DisableLowerCase]] [[-DisableUpperCase]] [[-DisableNumbers]] [[-DisableSpecialChars]] [<CommonParameters>]
```

## Example 1

```powershell
PS> Get-RandomPassword -DisableSpecialChars

Password
--------
Rzxy48Nu
```

## Example 2

```powershell
PS> Get-RandomPassword -Length 6 -Count 10

Count Password
----- --------
    1 xxy&x9
    2 $sX9nr
    3 0(@60w
    4 aCNlaP
    5 eY$MLi
    6 R?V0U6
    7 -C9mSu
    8 -Beat*
    9 h_DaVc
   10 u+H}%]
```