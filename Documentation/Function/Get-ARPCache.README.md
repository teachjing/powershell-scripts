# Get-ARPCache

Get the ARP cache.

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/Network/Get-ARPCache.ps1)

## Description

Get the Address Resolution Protocol (ARP) cache, which is used for resolution of internet layer addresses into link layer addresses.

![Screenshot](Images/Get-ARPCache.png?raw=true "Get-ARPCache")

## Syntax

```powershell
Get-ARPCache [<CommonParameters>]
```

## Example 1

```powershell
PS> Get-ARPCache

Interface      IPv4Address     MACAddress        Type
---------      -----------     ----------        ----
192.168.56.1   192.168.56.255  FF-00-00-00-00-FF static
192.168.56.1   224.0.0.22      01-00-5E-00-00-16 static
192.168.56.1   239.255.255.250 01-00-00-00-00-FA static
192.168.178.22 192.168.178.1   5C-00-00-00-00-77 dynamic
192.168.178.22 192.168.178.255 FF-00-00-00-00-FF static
192.168.178.22 224.0.0.22      01-00-00-00-00-16 static
192.168.178.22 239.255.255.250 01-00-00-00-00-FA static
```

## Example 2

```powershell
PS> Get-ARPCache | Where-Object {$_.Interface -eq "192.168.178.22"}

Interface      IPv4Address     MACAddress        Type
---------      -----------     ----------        ----
192.168.178.22 192.168.178.1   5C-00-00-00-00-77 dynamic
192.168.178.22 192.168.178.255 FF-00-00-00-00-FF static
192.168.178.22 224.0.0.22      01-00-00-00-00-16 static
192.168.178.22 239.255.255.250 01-00-00-00-00-FA static
```

## Further information

* [ARP - Technet](https://technet.microsoft.com/en-us/library/bb490864.aspx)
* [Address Resolution Protocol - Wikipedia](https://en.wikipedia.org/wiki/Address_Resolution_Protocol)