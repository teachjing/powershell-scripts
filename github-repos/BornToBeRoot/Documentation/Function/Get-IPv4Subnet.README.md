# Get-IPv4Subnet

Calculate a subnet based on an IP-Address and the subnetmask or CIDR.

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/Network/Get-IPv4Subnet.ps1)

## Description

Calculate a subnet based on an IP-Address within the subnet and the subnetmask or CIDR. 
The result includes the NetworkID, Broadcast, total available IPs and usable IPs for hosts.

![Screenshot](Images/Get-IPv4Subnet.png?raw=true "Get-IPv4Subnet")

## Syntax

```powershell
Get-IPv4Subnet [[-IPv4Address] <IPAddress>] [[-CIDR] <Int32>] [<CommonParameters>]

Get-IPv4Subnet [[-IPv4Address] <IPAddress>] [[-Mask] <IPAddress>] [<CommonParameters>]
```

## Example 1

```powershell
PS> Get-IPv4Subnet -IPv4Address 192.168.24.96 -CIDR 27

NetworkID     Broadcast      IPs Hosts
---------     ---------      --- -----
192.168.24.96 192.168.24.127  32    30
```

## Example 2

```powershell
PS> Get-IPv4Subnet -IPv4Address 192.168.1.0 -Mask 255.255.255.0 | Select-Object -Property *

NetworkID : 192.168.1.0
FirstIP   : 192.168.1.1
LastIP    : 192.168.1.254
Broadcast : 192.168.1.255
IPs       : 256
Hosts     : 254
```
