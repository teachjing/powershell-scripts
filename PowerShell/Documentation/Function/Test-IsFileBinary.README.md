# Test-IsFileBinary 

Test if a file is binary.

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/File/Test-IsFileBinary.ps1)

## Description

Test if a file is binary like .exe or .zip.

![Screenshot](Images/Test-IsFileBinary.png?raw=true "Test-IsFileBinary")

## Syntax

```powershell
Test-IsFileBinary [-FilePath] <String> [<CommonParameters>]
``` 

## Example 1

```powershell
PS> Test-IsFileBinary -FilePath "E:\Temp\Files\File_04.zip"

True
```

## Example 2

```powershell
PS> Test-IsFileBinary -FilePath "E:\Temp\Files\File_01.txt"

False
```

## Further information

* [How to identify the file content as ascii or binary - Stackoverflow](https://stackoverflow.com/questions/277521/how-to-identify-the-file-content-as-ascii-or-binary/277568#277568)
* [Search script that ignores binary files - Stackoverflow](https://stackoverflow.com/questions/1077634/powershell-search-script-that-ignores-binary-files/1080976#1080976)