# ConvertTo-Base64

Convert a text (command) to an Base64 encoded string.

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/Security/ConvertTo-Base64.ps1)

## Description

Convert a text (command) to an Base64 encoded string.

![Screenshot](Images/ConvertTo-Base64.png?raw=true)

## Syntax

```powershell
ConvertTo-Base64 [-Text] <String> [<CommonParameters>]

ConvertTo-Base64 [-FilePath] <String> [<CommonParameters>]
```

## Example

```powershell
PS> ConvertTo-Base64 -Text 'Set-Location -Path "E:\Temp\Files\";Get-ChildItem'

UwBlAHQALQBMAG8AYwBhAHQAaQBvAG4AIAAtAFAAYQB0AGgAIAAiAEUAOgBcAFQAZQBtAHAAXABGAGkAbABlAHMAXAAiADsARwBlAHQALQBDAGgAaQBsAGQASQB0AGUAbQA=

PS> powershell.exe -NoProfile -EncodedCommand "UwBlAHQALQBMAG8AYwBhAHQAaQBvAG4AIAAtAFAAYQB0AGgAIAAiAEUAOgBcAFQAZQBtAHAAXABGAGkAbABlAHMAXAAiADsARwBlAHQALQBDAGgAaQBsAGQASQB0AGUAbQA="

    Directory: E:\Temp\Files


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        8/21/2016   5:54 PM              5 File_01.txt
-a----        8/20/2016  12:54 AM              9 File_02.txt
-a----        8/20/2016  12:08 AM             14 File_03.txt
-a----        6/24/2016   5:01 PM            120 File_04.zip
-a----        8/20/2016  12:54 AM             14 File_05.txt
```