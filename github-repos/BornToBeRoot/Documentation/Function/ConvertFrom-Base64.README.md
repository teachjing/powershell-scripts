# ConvertFrom-Base64

Convert a Base64 encoded string to a plain text string.

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/Security/ConvertFrom-Base64.ps1)

## Description

Convert a Base64 encoded string to a plain text string.

![Screenshot](Images/ConvertFrom-Base64.png?raw=true)

## Syntax

```powershell
ConvertFrom-Base64 [-Text] <String> [<CommonParameters>]
```

## Example

```powershell
PS> ConvertFrom-Base64 -Text "UwBlAHQALQBMAG8AYwBhAHQAaQBvAG4AIAAtAFAAYQB0AGgAIAAiAEUAOgBcAFQAZQBtAHAAXABGAGkAbABlAHMAXAAiADsARwBlAHQALQBDAGgAaQBsAGQASQB0AGUAbQA="

Set-Location -Path "E:\Temp\Files\";Get-ChildItem
```