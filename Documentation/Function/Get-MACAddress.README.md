# Get-MACAddress

Get the MAC-Address from a remote computer

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/Network/Get-MACAddress.ps1)

## Description

Get the MAC-Address from a remote computer. If the MAC-Address could be resolved, the result contains the ComputerName, IPv4-Address and the MAC-Address of the system. Otherwise it returns null. To resolve the MAC-Address your computer need to be in the same subnet as the remote computer (Layer 2). If the result return null, try the parameter `-Verbose` to get more details.

![Screenshot](Images/Get-MACAddress.png?raw=true "Get-MACAddress")

## Syntax

```powershell
Get-MACAddress [-ComputerName] <String[]> [<CommonParameters>]
```

## Example 1

```powershell
PS> Get-MACAddress -ComputerName TEST-PC-01
    
ComputerName IPv4Address    MACAddress        Vendor
------------ -----------    ----------        ------
TEST-PC-01   192.168.178.20 1D-00-00-00-00-F0 Cisco Systems, Inc
```

## Example 2

```powershell
PS> Get-MACAddress -ComputerName TEST-PC-01, TEST-PC-02, TEST-PC-03, TEST-PC-04 -Verbose
    
VERBOSE: TEST-PC-02 is not reachable via ICMP. ARP-Cache could not be refreshed!

Could not resolve MAC-Address for TEST-PC-03 (192.168.178.21). Make sure that your computer is in the same subnet
 and TEST-PC-02 is reachable.
 
Could not resolve IPv4-Address for TEST-PC-04. MAC-Address resolving has been skipped. Try to enter an IPv4-Address
instead of the Hostname!

ComputerName IPv4Address    MACAddress        Vendor
------------ -----------    ----------        ------
TEST-PC-01   192.168.178.20 1D-00-00-00-00-F0 Cisco Systems, Inc
TEST-PC-02   192.168.178.21 1D-00-00-00-00-F1 ASUSTek COMPUTER INC.
```
