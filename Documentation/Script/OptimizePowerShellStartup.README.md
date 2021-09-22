# OptimizePowerShellStartup.ps1

Optimize PowerShell startup by reduce JIT compile time with `ngen.exe`.

* [view script](https://github.com/BornToBeRoot/PowerShell/blob/master/Scripts/OptimizePowerShellStartup.ps1)

## Description

Optimize PowerShell startup by reduce JIT compile time with `ngen.exe`.

Script requires administrative permissions.

![Screenshot](Images/OptimizePowerShellStartup.png?raw=true "Optimize PowerShell Startup")

## Syntax

### Script

```powershell
.\OptimizePowerShellStartup.ps1 [<CommonParameters>]
``` 

## Example

```powershell
PS> .\OptimizePowerShellStartup.ps1

Start optimization...
Installing assembly C:\Windows\Microsoft.NET\Framework64\v4.0.30319\mscorlib.dll
All compilation targets are up to date.
Installing assembly C:\Windows\Microsoft.Net\assembly\GAC_MSIL\Microsoft.CSharp\v4.0_4.0.0.0__b03f5f7f11d50a3a\Microsoft.CSharp.dll
All compilation targets are up to date.
...
...
...
Installing assembly C:\Windows\Microsoft.Net\assembly\GAC_MSIL\System.Dynamic\v4.0_4.0.0.0__b03f5f7f11d50a3a\System.Dynamic.dll
All compilation targets are up to date.
Optimization finished!
Press any key to continue...
```

## Further information

* [Ngen.exe (Native Image Generator) - MSDN](https://msdn.microsoft.com/de-de/library/6t9t5wcf(v=vs.110).aspx)