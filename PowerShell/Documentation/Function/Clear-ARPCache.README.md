# Clear-ARPCache

Clear the ARP cache.

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/Network/Clear-ARPCache.ps1)

## Description

Clear the Address Resolution Protocol (ARP) cache, which is used for resolution of internet layer addresses into link layer addresses.

![Screenshot](Images/Clear-ARPCache.png?raw=true "Clear-ARPCache")

**Administrative rights are required to execute this command!**

## Syntax

```powershell
Clear-ARPCache [<CommonParameters>]
```

## Example

```powershell
PS> Clear-ARPCache
```

## Further information

* [Netsh commands for Interface IP - Technet](https://technet.microsoft.com/en-us/library/bb490943.aspx)
* [Address Resolution Protocol - Wikipedia](https://en.wikipedia.org/wiki/Address_Resolution_Protocol)