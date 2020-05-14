
# O365 Scripts

### O365-SecurityAssessment.ps1

Uses [ORCA Module](https://github.com/cammurray/orca) to quickly connect to your tenant and generate a security assessment of your configuration vs Microsoft recommendations. I go over the report in this [Youtube Video](https://www.youtube.com/watch?v=d0ZCTOrwlMI)

This script will install required dependencies for ORCA to work. Then connect to Exchange Online Powershell Session which will prompt for user authentication. After user authenticates, the script will load the ORCA module which will assess your O365 Tenant Security Configuration and output a report in HTML.

```shell
git clone https://github.com/jingsta/powershell-scripts
cd .\powershell-scripts\Microsoft\O365\
.\O365-SecurityAssessment.ps1
```
| References | Link |
| ------ | ------ |
| O365 ATP Recommended Configuration Analyzer (ORCA) | https://github.com/cammurray/orca |
| Exchange Online PowerShell V2 module | https://aka.ms/exops-docs |
| Enable-PSRemoting | [Documentation]( https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting?view=powershell-7) |

## FYI
The Exchange Online Remote PowerShell Module is not supported in PowerShell Core (macOS, Linux, or Windows Nano Server). As a workaround, you can install the module on a computer that's running a supported version of Windows (physical or virtual), and use remote desktop software to connect.

To use the new Exchange Online PowerShell V2 module (which also supports MFA), see Use the Exchange Online PowerShell V2 module.)
