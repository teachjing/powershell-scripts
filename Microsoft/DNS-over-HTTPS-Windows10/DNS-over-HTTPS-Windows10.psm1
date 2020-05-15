#Downloads updated list from github repo
function Get-OnlineServersJSON {
    Param (
        [Parameter(Mandatory=$true)]  [Object[]]$Uri
    )
    Write-Host "`nRetrieving DOH Server list from '$($Uri)'"
    Try {
            (New-Object System.Net.WebClient).DownloadString($Uri) | ConvertFrom-Json
            #$response = (New-Object System.Net.WebClient).DownloadString($Uri) | ConvertFrom-Json
            return $response
        } Catch {
            Write-Host -ForegroundColor Red "Had a problem downloading JSON from github repo"
        }
}

# This function will download from a provided local file
function Get-LocalFileJSON {
    Param (
        [Parameter(Mandatory=$true)]  [Object[]]$Path
    )
        Write-Host -ForegroundColor Yellow "`nDownloading DoH server list from local file"
    Try {
        $response = Get-Content -Raw -Path $Path | ConvertFrom-Json
        return $response
    } Catch {
        Write-Host -ForegroundColor Red "Had a problem downloading servers from local file"
        Exit
    }
}

function Get-DoHRegistrySettings {

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

}