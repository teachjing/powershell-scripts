#Downloads updated list from github repo
$DoHServersURL = "https://raw.githubusercontent.com/jingsta/powershell-scripts/master/Microsoft/DNSoverHTTPS/DoH-Servers.json"
$LocalServersFile = "./MyLocalFile.json"

function Get-DOHServers {
    Write-Host "`nRetrieving DOH Server list from 'https://raw.githubusercontent.com/jingsta/powershell-scripts/master/Microsoft/DNSoverHTTPS/DoH-Servers.json'"
    Try {
            $DoHServers = (New-Object System.Net.WebClient).DownloadString($DoHServersURL) | ConvertFrom-Json
            return $DoHServers
        } Catch {
            Write-Host -ForegroundColor Red "Had a problem downloading JSON from github repo"
            Exit
        }
}
