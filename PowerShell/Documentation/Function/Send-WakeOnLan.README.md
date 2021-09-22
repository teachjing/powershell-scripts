# Send-WakeOnLan

Send a network message to turn on or wake up a remote computer.

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/Network/Send-WakeOnLan.ps1)

## Description

Send a network message (magic packet) to turn on or wake up a remote computer. To wake up a client in another subnet, you can use the parameter `-UseComputer` to connect to another Windows computer and send the magic packet from there. This is necessary because magic packets are not forwarded by routers (unless you have a WoL gateway service).

A magic packet for the MAC-Address `DD:F0:0F:00:10:00` looks like:

```
255 255 255 255 255 255 221 240 15 0 16 0 221 240 15 0 16 0 221 240 15 0 16 0 221 240 15 0 16 0 221 240
15 0 16 0 221 240 15 0 16 0 221 240 15 0 16 0 221 240 15 0 16 0 221 240 15 0 16 0 221 240 15 0 16 0 221
240 15 0 16 0 221 240 15 0 16 0 221 240 15 0 16 0 221 240 15 0 16 0 221 240 15 0 16 0 221 240 15 0 16 0
```

Remote computers (-UseComputer) need WinRM enabled. To do this use `winrm quickconfig`.

![Screenshot](Images/Send-WakeOnLan.png?raw=true "Send-WakeOnLan")

## Syntax

```powershell
Send-WakeOnLan [-MACAddress] <String[]> [[-Port] <Int32>] [[-UseComputer] <String>] [[-Credential] <PSCredential>] [<CommonParameters>]
```

## Example 1

```powershell
PS> Send-WakeOnLan -MACAddress 00:00:00:00:00:00
```

## Example 2

```powershell
PS> Send-WakeOnLan -MACAddress 00:00:00:00:00:00 -UseComputer TEST-PC-01
```
