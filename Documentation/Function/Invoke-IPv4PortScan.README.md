# Invoke-IPv4PortScan

Powerful asynchronus IPv4 Port Scanner.

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/Network/Invoke-IPv4PortScan.ps1)

## Description

This powerful asynchronus IPv4 Port Scanner allows you to scan every Port-Range you want (500 to 2600 would work). Only TCP-Ports are scanned.

The result will contain the Port number, Protocol, Service name, Description and the Status.

![Screenshot](Images/Invoke-IPv4PortScan.png?raw=true "Invoke-IPv4PortScan")

To reach the best possible performance, this script uses a [RunspacePool](https://msdn.microsoft.com/en-US/library/system.management.automation.runspaces.runspacepool(v=vs.85).aspx). As you can see in the following screenshot, the individual tasks are distributed across all cpu cores:

![Screenshot](Images/Invoke-IPv4PortScan_CPUusage.png?raw=true "CPU usage")

## Syntax

```powershell
Invoke-IPv4PortScan [-ComputerName] <String> [[-StartPort] <Int32>] [[-EndPort] <Int32>] [[-Threads] <Int32>] [[-Force]] [[-UpdateList]] [<CommonParameters>]
```

## Example 1

```powershell
PS> Invoke-IPv4PortScan -ComputerName fritz.box -StartPort 1 -EndPort 500

Port Protocol ServiceName ServiceDescription               Status
---- -------- ----------- ------------------               ------
  21 tcp      ftp         File Transfer Protocol [Control] Open
  53 tcp      domain      Domain Name Server               Open
  80 tcp      http        World Wide Web HTTP              Open
```

## Example 2

```powershell
PS> Invoke-IPv4PortScan -ComputerName TEST-PC-01 -StartPort 1 -EndPort 500
PS> TEST-PC-01 is not reachable!
PS> Would you like to continue? (perhaps only ICMP is blocked) [yes|no]: yes

Port Protocol ServiceName ServiceDescription               Status
---- -------- ----------- ------------------               ------
  80 tcp      http        World Wide Web HTTP              Open
```