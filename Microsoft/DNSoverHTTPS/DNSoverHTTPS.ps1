$PublicDNSServers = Get-Content -raw -Path ".\DoH-Servers.json" | ConvertFrom-Json

#Imports JSON data to get up to date Server list
#$DoHServers = iex ((new-object net.webclient).DownloadString("https://raw.githubusercontent.com/jingsta/powershell-scripts/master/Microsoft/DNSoverHTTPS/DoH-Servers.json")) | ConvertFrom-Json

#$DoHServers = $web_client.DownloadString("https://github.com/jingsta/powershell-scripts/blob/master/Microsoft/DNSoverHTTPS/DoH-Servers.json") | ConvertFrom-Json
$DoHServers

Function Invoke-Menu (){
    
    Param(
        [Parameter(Mandatory=$True)][String]$MenuTitle,
        [Parameter(Mandatory=$false)][String]$SubTitle,
        [Parameter(Mandatory=$True)][array]$MenuOptions
    )

    $MaxValue = $MenuOptions.count-1
    $Selection = 0
    $EnterPressed = $False
    
    Clear-Host

    While($EnterPressed -eq $False){
        Write-Host -Foreground Cyan "`n`nDNS over HTTPS Powershell Quick Configurator"
        Write-Host -Foreground Yellow "`n$MenuTitle"
        Write-Host -Foreground Magenta $SubTitle

        For ($i=0; $i -le $MaxValue; $i++){
            
            If ($i -eq $Selection){
                Write-Host -BackgroundColor Cyan -ForegroundColor Black "[ $($MenuOptions[$i]) ]"
            } Else {
                Write-Host "  $($MenuOptions[$i])  "
            }

        }

        $KeyInput = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown").virtualkeycode

        Switch($KeyInput){
            13{
                $EnterPressed = $True
                Return $Selection
                Clear-Host
                break
            }

            38{
                If ($Selection -eq 0){
                    $Selection = $MaxValue
                } Else {
                    $Selection -= 1
                }
                Clear-Host
                break
            }

            40{
                If ($Selection -eq $MaxValue){
                    $Selection = 0
                } Else {
                    $Selection +=1
                }
                Clear-Host
                break
            }
            Default{
                Clear-Host
            }
        }
    }
}

function New-Menu {
    Param(
        [Parameter(Mandatory=$True)][String]$MenuTitle,
        [Parameter(Mandatory=$false)][String]$SubTitle,
        [Parameter(Mandatory=$True)][array]$MenuOptions
        
    )
    
    $MenuResult = Invoke-Menu -MenuTitle $MenuTitle -MenuOptions $MenuOptions -SubTitle $SubTitle
    return $MenuResult
}

$InsiderBuildCheck = New-Menu -MenuTitle "Currently DNS over HTTPS only works in the insider build ATM, are you running an insider build?" -MenuOptions @("Yes","No")
if($InsiderBuildCheck -eq 1) {Write-Host -Foreground Red "Get on the insider build and try again"; exit} 

$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
$DohRegistryCheck = Get-ItemProperty -Path $RegPath
if(!$DohRegistryCheck.EnableAutoDoh) {
    Write-Host "Not Enabled"
    Exit
}

$DohRegistryCheck
Write-Host -Foreground Green "DNS over HTTPS 'EnableAuthDoh' Registry Item looks to be configured correctly [2]"
Write-Host "Press any key to continue..." 
Read-Host 

$InterfaceMenuOptions = @()
$NetworkInterfaces = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} |
    ForEach-Object {
       $InterfaceMenuOptions += "$($_.Name) - $($_.InterfaceDescription) - $($_.MacAddress)"
       $_
    }

## Prompt user to choose interface to configure DNS for 
$InterfaceChoiceMenu = New-Menu -MenuTitle "Please Choose which interface to configure HTTPS over DNS:" -MenuOptions $InterfaceMenuOptions
Write-Host -Foreground Green "`n$($NetworkInterfaces[$InterfaceChoiceMenu].Name) - $($NetworkInterfaces[$InterfaceChoiceMenu].MacAddress) Selected."
Write-Host "Configuring DNS Server for '$($NetworkInterfaces[$InterfaceChoiceMenu].Name)' Interface"

## Prompt user to choose DNS Server Owner Location
$DNSChoiceMenu = New-Menu -MenuTitle "Choose a Public DNS Server to configure the Interface with:" -MenuOptions $PublicDNSServers

## Confirm if customer wants to make changes
$ConfirmChanges = New-Menu -MenuTitle "Please confirm Configuration prior to change" -MenuOptions @('Yes',"No") -SubTitle "Interface: $($NetworkInterfaces[$InterfaceChoiceMenu].Name), DNS Server: $($PublicDNSServers[$DNSChoiceMenu])"
if($InsiderBuildCheck -eq 1) {exit}


Set-DnsClientServerAddress -InterfaceIndex $NetworkInterfaces[$InterfaceChoiceMenu].ifIndex -ServerAddresses ("8.8.8.8","4.4.4.4")
## Grab DNS Configuration and filter by IPv4. ##Note had to enumerate the AddressFamily because it returns as a value and not the actual text
Get-DnsClientServerAddress | Where-Object {$_.AddressFamily -eq [Microsoft.PowerShell.Cmdletization.GeneratedTypes.DnsClientServerAddress.AddressFamily]"IPv4"}

<#
Read-Prompt "Enter the name corresponding to the interface you want to set DNS: "

$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"

New-ItemProperty -Path $RegPath -Name "EnableAutoDoh" -Value 2  -PropertyType "DWORD"

Get-ItemProperty -Path $RegPath

pktmon filter remove
pktmon filter add -p 53
pktmon start --etw -m real-time

pktmon stop

netsh dns show encryption server=8.8.8.8

#>