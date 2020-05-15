#Downloads updated list from github repo
$DoHServersURL = "https://raw.githubusercontent.com/jingsta/powershell-scripts/master/Microsoft/DNSoverHTTPS/DoH-Servers.json"
$LocalServersFile = "./MyLocalFile.json"

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
        Write-Host -Foreground Cyan "`n`nDNS over HTTPS (DoH) Powershell Quick Configurator"
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
            37{
                If ($Selection -eq 0){
                    $Selection = $MaxValue
                } Else {
                    $Selection -= 1
                }
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
            39{
                If ($Selection -eq $MaxValue){
                    $Selection = 0
                } Else {
                    $Selection +=1
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

#Verify if user is using Windows Insider Build
$InsiderBuildCheck = New-Menu -MenuTitle "Currently DNS over HTTPS only works in the insider build ATM, are you running an insider build?" -MenuOptions @("Yes","No")
if($InsiderBuildCheck -eq 1) {Write-Host -Foreground Red "Get on the insider build and try again"; exit} 

#Check registry to see if DoH is configured properly for Insider Build
$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
$DohRegistryCheck = Get-ItemProperty -Path $RegPath
if(!$DohRegistryCheck.EnableAutoDoh) {
    Read-Host "Not Enabled, Press Enter to add registry key"
    New-ItemProperty -Path $RegPath -Name "EnableAutoDoh" -Value 2  -PropertyType "DWORD"
}
Write-Host -ForegroundColor Black -BackgroundColor Yellow "`nRegistry Settings at '$($RegPath)'"
$DohRegistryCheck
Write-Host -Foreground Green "DNS over HTTPS 'EnableAuthDoh' Registry Item looks to be configured correctly [2]"
Write-Host "Press any key to continue..." 
Read-Host 

# Map Interfaces
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

## Prompt user to choose DNS Server Owner Location
$DnsSourceLocation = New-Menu -MenuTitle "Choose a source location to grab DoH Servers from:" -MenuOptions ( "Online - Github Repo '$($DoHServersURL)'", "Local file $($LocalServersFile)" )
if ($DnsSourceLocation -eq 0) {
    Write-Host -Foreground Yellow "`nDownloading DoH server list from Github"
    Write-Host "`tURL: '$($DoHServersURL)'`n"
    Try {
        $DoHServers = (New-Object System.Net.WebClient).DownloadString($DoHServersURL) | ConvertFrom-Json
    } Catch {
        Write-Host -ForegroundColor Red "Had a problem downloading JSON from github repo"
        Exit
    }
} else {
    Write-Host -ForegroundColor Yellow "`nDownloading DoH server list from local file"
    Try {
        $DoHServers = Get-Content -Raw -Path $LocalServersFile | ConvertFrom-Json
    } Catch {
        Write-Host -ForegroundColor Red "Had a problem downloading servers from local file"
        Exit
    }
}

#Goes through list of servers and builds menu
$DownloadedServerList = @()
$DNSAddresses = @()
ForEach ($server in $DoHServers) {
    $DownloadedServerList += "$($server.Name) - $($server.Type)"
    if ($server.Type -eq "static") {
    } else {
        $server | Add-Member -MemberType NoteProperty -Name "IPv4" -Value @()
        [System.Net.Dns]::GetHostAddresses($server.DomainName) | foreach { $server.IPv4 += $_.IPAddressToString }
    }
}

$SelectedServer = New-Menu -MenuTitle "Choose a Public DNS Server to configure the Interface with:" -MenuOptions $DownloadedServerList
ForEach ($IP in $DoHServers[$SelectedServer].IPv4) { $DNSAddresses += ([IPAddress]$IP).IPAddressToString }
ForEach ($IP in $DoHServers[$SelectedServer].IPv6) { $DNSAddresses += ([IPAddress]$IP).IPAddressToString }

## Confirm if customer wants to make changes
$ConfirmChanges = New-Menu -MenuTitle "Please confirm Configuration prior to change" -MenuOptions @('Yes',"No") -SubTitle "`nInterface: $($NetworkInterfaces[$InterfaceChoiceMenu].Name)`nDNS Server: $($DoHServers[$SelectedServer].Name) `nIPv4 Address: $($DoHServers[$SelectedServer].IPv4)`nIPv6 Address: $($DoHServers[$SelectedServer].IPv6)`n"

#This removes any DNS Configuration and adds the new info
Set-DnsClientServerAddress -InterfaceIndex $NetworkInterfaces[$InterfaceChoiceMenu].ifIndex -ResetServerAddresses
Set-DnsClientServerAddress -ServerAddresses $DNSAddresses -InterfaceIndex $NetworkInterfaces[$InterfaceChoiceMenu].ifIndex

#Set-DnsClientServerAddress -InterfaceIndex $NetworkInterfaces[$InterfaceChoiceMenu].ifIndex -ServerAddresses $($DoHServers[$SelectedServer].IPv6)
## Grab DNS Configuration and filter by IPv4. ##Note had to enumerate the AddressFamily because it returns as a value and not the actual text

Write-Host -ForegroundColor Yellow "`n$($NetworkInterfaces[$InterfaceChoiceMenu].Name) interface configured with $($DoHServers[$SelectedServer].Name) IPv4/IPv6 addresses."
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