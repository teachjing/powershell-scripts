# Find-StringInFile

Find a string in one or multiple files.

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/File/Find-StringInFile.ps1)

# Description

Find a string in one or multiple files. The search is performed recursively from the start folder.

![Screenshot](Images/Find-StringInFile.png?raw=true "Find-StringInFile")

## Syntax

```powershell
Find-StringInFile [-Path] <String> [-Search] <String> [[-CaseSensitive]] [<CommonParameters>]
``` 

## Example 1

```powershell
PS> Find-StringInFile -Path "C:\Scripts\FolderWithFiles" -Search "Test01"
       
Filename    Path                      LineNumber IsBinary Matches
--------    ----                      ---------- -------- -------
File_01.txt E:\Temp\Files\File_01.txt          1    False {Test01}
File_02.txt E:\Temp\Files\File_02.txt          1    False {TEST01}
File_03.txt E:\Temp\Files\File_03.txt          1    False {TeST01}
```

## Example 2

```powershell
PS> Find-StringInFile -Path "C:\Scripts\FolderWithFiles" -Search "TEST01" -CaseSensitive

Filename    Path                      LineNumber IsBinary Matches
--------    ----                      ---------- -------- -------
File_02.txt E:\Temp\Files\File_02.txt          1    False {TEST01}
```