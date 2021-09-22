# Update-StringInFile

Replace a string in one or multiple files.

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/File/Update-StringInFile.ps1)

## Description

 Replace a string in one or multiple files.
 Binary files (*.zip, *.exe, etc.) are not touched by this script. 

![Screenshot](Images/Update-StringInFile.png?raw=true "Update-StringInFile")

## Syntax

```powershell
Update-StringInFile [-Path] <String> [-Find] <String> [-Replace] <String> [[-CaseSensitive]] [<CommonParameters>]
```

## Example 1

```powershell
PS> Update-StringInFile -Path E:\Temp\Files\ -Find "Test1" -Replace "Test2" -Verbose
       
VERBOSE: Binary files like (*.zip, *.exe, etc...) are ignored
VERBOSE: Total files with string to replace found: 3
VERBOSE: Current file: E:\Temp\Files\File_01.txt
VERBOSE: Number of strings to replace in current file: 1
VERBOSE: Current file: E:\Temp\Files\File_02.txt
VERBOSE: Number of strings to replace in current file: 1
VERBOSE: Current file: E:\Temp\Files\File_03.txt
VERBOSE: Number of strings to replace in current file: 2
```