#Downloads updated list from github repo
Import-Module "..\..\custom-modules\MenuSystem.psm1" -Force  ## This module provides the menu interface
Import-Module ".\DNS-over-HTTPS-Windows10.psm1" -Force  ## This is the main module for DoH on Windows 10
$LocalServersFile = "./MyLocalFile.json"  ## Local DoH Server list file
$OnlineServersURL = "https://raw.githubusercontent.com/jingsta/powershell-scripts/master/Microsoft/DNS-over-HTTPS-Windows10/DoH-Servers.json"  ## Online Github Server List

#Verify if user is using Windows Insider Build
$InsiderBuildCheck = New-Menu -MenuTitle "Currently DNS over HTTPS only works in the insider build ATM, are you running an insider build?" -MenuOptions @("Yes","No")
if($InsiderBuildCheck -eq 1) {Write-Host -Foreground Red "Get on the insider build and try again"; exit} 

## This will check the registry and verify setting is correct. 
Get-DoHRegistrySettings  ## In the public release this would not be necessary, but right now its required for insider build. 

# Identifies network interfaces for user to select from
$InterfaceMenuOptions = @()
$NetworkInterfaces = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} |    ## identify interfaces
    ForEach-Object {
       $InterfaceMenuOptions += "$($_.Name) - $($_.InterfaceDescription) - $($_.MacAddress)"
       $_
    }

## Prompt user to choose interface to configure DNS over HTTPS (DOH)
$InterfaceChoiceMenu = New-Menu -MenuTitle "Please Choose which interface to configure HTTPS over DNS:" -MenuOptions $InterfaceMenuOptions
Write-Host -Foreground Green "`n$($NetworkInterfaces[$InterfaceChoiceMenu].Name) - $($NetworkInterfaces[$InterfaceChoiceMenu].MacAddress) Selected."
Write-Host "Configuring DNS Server for '$($NetworkInterfaces[$InterfaceChoiceMenu].Name)' Interface"

## Prompt user to choose DNS Server Owner Location 'Online Github or Local file'
$DnsSourceLocation = New-Menu -MenuTitle "Choose a source location to grab DoH Servers from:" -MenuOptions ( "Online - Github Repo '$($OnlineServersURL)'", "Local file $($LocalServersFile)" )
if ($DnsSourceLocation -eq 0) {
    $RetrievedServers = Get-OnlineServersJSON -Uri $OnlineServersURL
} else {
    $RetrievedServers = Get-LocalFileJSON -Path $LocalServersFile
}

#Goes through list of servers and builds menu
$ServerListChoices = @()
ForEach ($server in $RetrievedServers) {
    $ServerListChoices += "$($server.Name) - $($server.Type)"
    if ($server.Type -eq "dynamic") {
        $server | Add-Member -MemberType NoteProperty -Name "IPv4" -Value @()
        [System.Net.Dns]::GetHostAddresses($server.DomainName) | foreach { $server.IPv4 += $_.IPAddressToString }
    }
}

#Prompts user to choose DoH Server from list
$DNSAddresses = @()
$SelectedServer = New-Menu -MenuTitle "Choose a Public DNS Server to configure the Interface with:" -MenuOptions $ServerListChoices
ForEach ($IP in $RetrievedServers[$SelectedServer].IPv4) { $DNSAddresses += ([IPAddress]$IP).IPAddressToString }
ForEach ($IP in $RetrievedServers[$SelectedServer].IPv6) { $DNSAddresses += ([IPAddress]$IP).IPAddressToString }

## Confirm if customer wants to make DNS Configuration change to selected interface
$ConfirmChanges = New-Menu `
    -MenuTitle "Please confirm Configuration prior to change" `
    -MenuOptions @('Yes',"No") `
    -SubTitle "`nInterface: $($NetworkInterfaces[$InterfaceChoiceMenu].Name)`nDNS Server: $($RetrievedServers[$SelectedServer].Name) `nIPv4 Address: $($RetrievedServers[$SelectedServer].IPv4)`nIPv6 Address: $($RetrievedServers[$SelectedServer].IPv6)`n"

#This removes any DNS Configuration and adds the DNS settings
Set-DnsClientServerAddress -InterfaceIndex $NetworkInterfaces[$InterfaceChoiceMenu].ifIndex -ResetServerAddresses
Set-DnsClientServerAddress -ServerAddresses $DNSAddresses -InterfaceIndex $NetworkInterfaces[$InterfaceChoiceMenu].ifIndex
Write-Host -ForegroundColor Yellow "`n$($NetworkInterfaces[$InterfaceChoiceMenu].Name) interface configured with $($RetrievedServers[$SelectedServer].Name) IPv4/IPv6 addresses."
Get-DnsClientServerAddress | 
    Where-Object {$_.InterfaceAlias -eq $($NetworkInterfaces[$InterfaceChoiceMenu].Name)} | 
    Format-Table

<#

pktmon filter remove
pktmon filter add -p 53
pktmon start --etw -m real-time

pktmon stop

netsh dns show encryption server=8.8.8.8

#>