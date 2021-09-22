# Split-IPv4Subnet

Split a subnet in multiple subnets with given subnetmasks.

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/Network/Split-IPv4Subnet.ps1)

## Description

Split a subnet in multiple subnets with given subnetmasks. Each new subnet contains NetworkID, Broadcast, total available IPs and usable IPs for hosts. 

![Screenshot](Images/Split-IPv4Subnet.png?raw=true "Split-IPv4Subnet")

## Syntax

```powershell
Split-IPv4Subnet [-IPv4Address] <IPAddress> [-CIDR] <Int32> [-NewCIDR] <Int32> [<CommonParameters>]

Split-IPv4Subnet [-IPv4Address] <IPAddress> [-Mask] <String> [-NewMask] <String> [<CommonParameters>]
```

## Example 1

```powershell
PS> Split-IPv4Subnet -IPv4Address 192.168.0.0 -CIDR 22 -NewCIDR 24

NetworkID   Broadcast     IPs Hosts
---------   ---------     --- -----
192.168.0.0 192.168.0.255 256   254
192.168.1.0 192.168.1.255 256   254
192.168.2.0 192.168.2.255 256   254
192.168.3.0 192.168.3.255 256   254
```

## Example 2

```powershell
PS> Split-IPv4Subnet -IPv4Address 192.168.0.0 -Mask 255.255.255.0 -NewMask 255.255.255.128
    
NetworkID     Broadcast     IPs Hosts
---------     ---------     --- -----
192.168.0.0   192.168.0.127 128   126
192.168.0.128 192.168.0.255 128   126
```