# Get-WLANProfile

Get WLAN profiles, include password as SecureString or as plain text.

* [view function](https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/Network/Get-WLANProfile.ps1)

## Description

Get WLAN profiles on your local system, include Name, SSID, Authentication and Password as secure string or plain text. You don't need an additional application, which is full of advertising. And for learning purposes it shows, how easy it is to find out the WLAN password, if you have physical/remote access to the computer. 

All this just by parsing the output of netsh.exe, which can be called without admin permissions.  

![Screenshot](Images/Get-WLANProfile.png?raw=true "Get-WLANProfile")

_In Windows 7 there was a graphical interface in the network settings, where you could get the wlan password in plain text. In Windows 8, 8.1 and 10 this function is hidden or difficult to find._

## Syntax

```powershell
Get-WLANProfile [[-ShowPassword]] [[-Search] <String>] [[-ExactMatch]] [<CommonParameters>]
```

## Example 1

```powershell
PS> Get-WLANProfile											

Name              SSID               Authentification    Password
----              ----               ---------------     ------
MyHomeNetwork01   MyHomeNetwork      WPA2-Personal       System.Security.SecureString
MyHomeNetwork02   MyHomenetwork5G    WPA2-Personal       System.Security.SecureString
```

## Example 2

```powershell
PS> Get-WLANProfile  -ShowPassword -Search "MyHomeNetwork*"			

Name              SSID               Authentification    Password
----              ----               ---------------     ------
MyHomeNetwork01   MyHomeNetwork      WPA2-Personal       MyPassword123456789
MyHomeNetwork02   MyHomenetwork5G    WPA2-Personal       MyPassword987654321
```

## Further information

* [Netsh Command Reference - Technet](https://technet.microsoft.com/en-us/library/cc754516(v=ws.10).aspx)
* [Netsh Commands for WLAN - Technet](https://technet.microsoft.com/en-US/library/cc755301(v=ws.10).aspx)

## Inspired by

* [Get-WifiProfiles - PoshCode](http://poshcode.org/4520)
* [Get Wireless Network SSID and Password - Technet](https://blogs.technet.microsoft.com/heyscriptingguy/2015/11/23/get-wireless-network-ssid-and-password-with-powershell/)
