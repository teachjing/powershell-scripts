# PowerShell

My collection of useful functions, scripts, snippets and templates written by myself.

## Description

Automate all the Things!

## Module

#### How to install the module?

1. Download the [latest Release](https://github.com/BornToBeRoot/PowerShell/releases/latest)
2. Copy the folder [Module\LazyAdmin](Module/LazyAdmin) to `C:\Users\%username%\Documents\WindowsPowerShell\Modules\`
3. Open up a PowerShell as an admin and set the execution policy: `Set-ExecutionPolicy RemoteSigned`
4. Import the Module with the command `Import-Module LazyAdmin` (Maybe add this command to your PowerShell profile) 

#### Available functions:

**Folder: [File](Module/LazyAdmin/Functions/File)**

| Function | Description | Help |
| :--- | :--- | :---: | 
| [Find-StringInFile](Module/LazyAdmin/Functions/File/Find-StringInFile.ps1) | Find a string in one or multiple files | [:book:](Documentation/Function/Find-StringInFile.README.md) |
| [Test-IsFileBinary](Module/LazyAdmin/Functions/File/Test-IsFileBinary.ps1) | Test if a file is binary | [:book:](Documentation/Function/Test-IsFileBinary.README.md) |
| [Update-StringInFile](Module/LazyAdmin/Functions/File/Update-StringInFile.ps1) | Replace a string in one or multiple files | [:book:](Documentation/Function/Update-StringInFile.README.md)

**Folder: [Software](Module/LazyAdmin/Functions/Software)**

| Function | Description | Help | 
| :--- | :--- | :---: |
| [Get-InstalledSoftware](Module/LazyAdmin/Functions/Software/Get-InstalledSoftware.ps1) | Get all installed software with DisplayName, Publisher and UninstallString | [:book:](Documentation/Function/Get-InstalledSoftware.README.md) |

**Folder: [Network](Module/LazyAdmin/Functions/Network)**

| Function | Description | Help |
| :--- | :--- | :---: |
| [Clear-ARPCache](Module/LazyAdmin/Functions/Network/Clear-ARPCache.ps1) | Clear the ARP cache | [:book:](Documentation/Function/Clear-ARPCache.README.md) |
| [Convert-IPv4Address](Module/LazyAdmin/Functions/Converter/Convert-IPv4Address.ps1) | Convert an IPv4-Address to Int64 and vise versa | [:book:](Documentation/Function/Convert-IPv4Address.README.md) |
| [Convert-Subnetmask](Module/LazyAdmin/Functions/Converter/Convert-Subnetmask.ps1) | Convert a subnetmask to CIDR and vise versa | [:book:](Documentation/Function/Convert-Subnetmask.README.md) |
| [Get-ARPCache](Module/LazyAdmin/Functions/Network/Get-ARPCache.ps1) | Get the ARP cache | [:book:](Documentation/Function/Get-ARPCache.README.md) |
| [Get-IPv4Subnet](Module/LazyAdmin/Functions/Network/Get-IPv4Subnet.ps1) | Calculate a subnet based on an IP-Address and the subnetmask or CIDR | [:book:](Documentation/Function/Get-IPv4Subnet.README.md) |
| [Get-MACAddress](Module/LazyAdmin/Functions/Network/Get-MACAddress.ps1) | Get the MAC-Address from a remote computer | [:book:](Documentation/Function/Get-MACAddress.README.md) |
| [Get-MACVendor](Module/LazyAdmin/Functions/Network/Get-MACVendor.ps1) | Get Vendor from a MAC-Address | [:book:](Documentation/Function/Get-MACVendor.README.md) |
| [Get-WLANProfile](Module/LazyAdmin/Functions/WLAN/Get-WLANProfile.ps1) | Get WLAN profiles, include password as SecureString or as plain text | [:book:](Documentation/Function/Get-WLANProfile.README.md) |
| [Invoke-IPv4NetworkScan](Module/LazyAdmin/Functions/Network/Invoke-IPv4NetworkScan.ps1) | Powerful asynchronus IPv4 Network Scanner to scan an IP-Range or subnet | [:book:](Documentation/Function/Invoke-IPv4NetworkScan.README.md) |
| [Invoke-IPv4PortScan](Module/LazyAdmin/Functions/Network/Invoke-IPv4PortScan.ps1) | Powerful asynchronus IPv4 Port Scanner to scan a TCP Port-Range | [:book:](Documentation/Function/Invoke-IPv4PortScan.README.md) |
| [Send-WakeOnLan](Module/LazyAdmin/Functions/Network/Send-WakeOnLan.ps1) | Send a network message to turn on or wake up a remote computer | [:book:](Documentation/Function/Send-WakeOnLan.README.md) |
| [Split-IPv4Subnet](Module/LazyAdmin/Functions/Network/Split-IPv4Subnet.ps1) | Split a subnet in multiple subnets with given subnetmasks | [:book:](Documentation/Function/Split-IPv4Subnet.README.md) |

**Folder: [Security](Module/LazyAdmin/Functions/Security)**

| Function | Description | Help |
| :--- | :--- | :---: |
| [ConvertFrom-Base64](Module/LazyAdmin/Functions/Converter/ConvertFrom-Base64.ps1) | Convert a Base64 encoded string to a plain text string | [:book:](Documentation/Function/ConvertFrom-Base64.README.md) |
| [ConvertTo-Base64](Module/LazyAdmin/Functions/Converter/ConvertTo-Base64.ps1) | Convert a text (command) to an Base64 encoded string | [:book:](Documentation/Function/ConvertTo-Base64.README.md) |
| [Get-RandomPassword](Module/LazyAdmin/Functions/Security/Get-RandomPassword.ps1) | Generate passwords with a freely definable number of characters | [:book:](Documentation/Function/Get-RandomPassword.README.md) |
| [Get-RandomPIN](Module/LazyAdmin/Functions/Security/Get-RandomPIN.ps1) | Generate PINs with freely definable number of numbers | [:book:](Documentation/Function/Get-RandomPIN.README.md) |

**Folder: [TrustedHost](Module/LazyAdmin/Functions/TrustedHost)**

| Function | Description | Help |
| :--- | :--- | :---: |
| [Add-TrustedHost](Module/LazyAdmin/Functions/TrustedHost/Add-TrustedHost.ps1) |Add a trusted host (WinRM) | [:book:](Documentation/Function/Add-TrustedHost.README.md) |
| [Get-TrustedHost](Module/LazyAdmin/Functions/TrustedHost/Get-TrustedHost.ps1) | Get trusted hosts (WinRM) | [:book:](Documentation/Function/Get-TrustedHost.README.md) |
| [Remove-TrustedHost](Module/LazyAdmin/Functions/TrustedHost/Remove-TrustedHost.ps1) | Remove a trusted host (WinRM) | [:book:](Documentation/Function/Remove-TrustedHost.README.md) |
| [Set-TrustedHost](Module/LazyAdmin/Functions/TrustedHost/Set-TrustedHost.ps1) | Set a trusted host (WinRM) | [:book:](Documentation/Function/Set-TrustedHost.README.md) |

**Folder: [Windows](Module/LazyAdmin/Functions/Windows)**

| Function | Description | Help |
| :--- | :--- | :---: |
| [Get-LastBootTime](Module/LazyAdmin/Functions/Windows/Get-LastBootTime.ps1) | Get the time when a computer is booted | [:book:](Documentation/Function/Get-LastBootTime.README.md) |
| [Get-WindowsProductKey](Module/LazyAdmin/Functions/Windows/Get-WindowsProductKey.ps1) | Get the Windows product key and some usefull informations about the system | [:book:](Documentation/Function/Get-WindowsProductKey.README.md) |

**Folder: [Other](Module/LazyAdmin/Functions/Other)**

| Function | Description | Help |
| :--- | :--- | :---: |
| [Get-ConsoleColor](Module/LazyAdmin/Functions/Other/Get-ConsoleColor.ps1) | Get all available console colors | [:book:](Documentation/Function/Get-ConsoleColor.README.md) |

## Scripts

| Script | Description | Help |
| :--- | :--- | :---: |
| [Convert-ROT13](Scripts/Convert-ROT13.ps1) | Rotate lower and upper chars by n places (Caesar cipher) | [:book:](Documentation/Script/Convert-ROT13.README.md) |
| [Convert-ROT47](Scripts/Convert-ROT47.ps1) | Rotate ascii chars by n places (Caesar cipher) | [:book:](Documentation/Script/Convert-ROT47.README.md) |
| [OptimizePowerShellStartup.ps1](Scripts/OptimizePowerShellStartup.ps1) | Optimize PowerShell startup by reduce JIT compile time with ngen.exe | [:book:](Documentation/Script/OptimizePowerShellStartup.README.md) |

## Snippets 

| Snippet | Description | 
| :--- | :--- |
| [ConnectToExchange2010.ps1](Snippets/ConnectToExchange2010.ps1) | Connect to Exchange 2010 Management Shell in script |
| [CredentialParameter.ps1](Snippets/CredentialParameter.ps1) | Parameter to pass credentials into a function/script |
| [DefaultDisplayPropertySet.ps1](Snippets/DefaultDisplayPropertySet.ps1) | Set the default properties of an object |
| [New-Object.ps1](Snippets/New-Object.ps1) | Create a new PSObject with custom properties |
| [PressAnyKeyToContinue.ps1](Snippets/PressAnyKeyToContinue.ps1) | Wait until the user pressed a key | 
| [PromptForChoice.ps1](Snippets/PromptForChoice.ps1) | Prompt for choice |
| [PSCustomObject.ps1](Snippets/PSCustomObject.ps1) | Create a new PSObject with custom properties (faster than New-Object/Add-Member) |
| [RewriteInLine.ps1](Snippets/RewriteInLine.ps1) | Rewrite in Line (Write-Host "xx% complete") |
| [SelfElevatingScript.ps1](Snippets/SelfElevatingScript.ps1) | Self elevate a PowerShell script/console with parameters |
| [Send-MailMessage.ps1](Snippets/Send-MailMessage.ps1) | Send a mail message via PowerShell |

## Regex

| Regex | Description |
| :--- | :--- |
| [IPv4Address.ps1](Regex/IPv4Address.ps1) | Validate an IPv4-Address like 192.168.1.0 |
| [MACAddress.ps1](Regex/MACAddress.ps1) | Validate a MAC-Address like 00:00:00:00:00:00 or 00-00-00-00-00-00 or 000000000000 |
| [Subnetmask.ps1](Regex/Subnetmask.ps1) | Validate an Subnetmask like 255.255.255.0 |

## Templates

| Template | Description |
| :--- | :--- |
| [Default.ps1](Templates/Default.ps1) | Default template for new scripts |
| [Default.README.md](Templates/Default.README.md) | Default template for documentation on GitHub |
| [RunspacePool.ps1](Templates/RunspacePool.ps1) | RunspacePool template - run code asynchron (faster than PSJobs) |
| [ScheduledTask_Logging.ps1](/Templates/ScheduledTask_Logging.ps1) | Template to run a script as scheduled task with logging | 
