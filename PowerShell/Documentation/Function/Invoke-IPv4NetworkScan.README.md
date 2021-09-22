# Invoke-IPv4NetworkScan

Powerful asynchronus IPv4 Network Scanner.

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/Network/Invoke-IPv4NetworkScan.ps1)

## Description

This powerful asynchronus IPv4 Network Scanner for PowerShell allows you to scan every IPv4-Range you want (172.16.1.47 to 172.16.2.5 would work). But there is also the possibility to scan an entire subnet based on an IPv4-Address withing the subnet and a the subnetmask/CIDR.

The default result will contain the the IPv4-Address, Status (Up or Down) and the Hostname. Other values can be displayed via parameter (Try Get-Help for more details).

![Screenshot](Images/Invoke-IPv4NetworkScan.png?raw=true "Invoke-IPv4NetworkScan")

To reach the best possible performance, this script uses a [RunspacePool](https://msdn.microsoft.com/en-US/library/system.management.automation.runspaces.runspacepool(v=vs.85).aspx). As you can see in the following screenshot, the individual tasks are distributed across all cpu cores:

![Screenshot](Images/Invoke-IPv4NetworkScan_CPUusage.png?raw=true "CPU usage")

## Syntax

```powershell
Invoke-IPv4NetworkScan [-StartIPv4Address] <IPAddress> [-EndIPv4Address] <IPAddress> [[-Tries] <Int32>] [[-Threads] <Int32>] [[-DisableDNSResolving]] [[-EnableMACResolving]] [[-ExtendedInformations]] [[-IncludeInactive]] [[-UpdateList]] [<CommonParameters>]

Invoke-IPv4NetworkScan [-IPv4Address] <IPAddress> [-Mask] <String> [[-Tries] <Int32>] [[-Threads] <Int32>] [[-DisableDNSResolving]] [[-EnableMACResolving]] [[-ExtendedInformations]] [[-IncludeInactive]] [[-UpdateList]] [<CommonParameters>]

Invoke-IPv4NetworkScan [-IPv4Address] <IPAddress> [-CIDR] <Int32> [[-Tries] <Int32>] [[-Threads] <Int32>] [[-DisableDNSResolving]] [[-EnableMACResolving]] [[-ExtendedInformations]] [[-IncludeInactive]] [[-UpdateList]] [<CommonParameters>]
```

## Example 1

```powershell
PS> Invoke-IPv4NetworkScan -StartIPv4Address 192.168.178.0 -EndIPv4Address 192.168.178.20

IPv4Address   Status Hostname
-----------   ------ --------
192.168.178.1 Up     fritz.box
```

## Example 2

```powershell
PS> Invoke-IPv4NetworkScan -IPv4Address 192.168.178.0 -Mask 255.255.255.0 -DisableDNSResolving

IPv4Address    Status
-----------    ------
192.168.178.1  Up
192.168.178.22 Up
```

## Example 3

```powershell
PS> Invoke-IPv4NetworkScan -IPv4Address 192.168.178.0 -CIDR 25 -EnableMACResolving

IPv4Address    Status Hostname           MAC               Vendor
-----------    ------ --------           ---               ------
192.168.178.1  Up     fritz.box          XX-XX-XX-XX-XX-XX AVM Audiovisuelles Marketing und Computersysteme GmbH
192.168.178.22 Up     XXXXX-PC.fritz.box XX-XX-XX-XX-XX-XX ASRock Incorporation
```
