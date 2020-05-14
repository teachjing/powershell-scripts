# This script uses the Office 365 ATP Recommended Configuration Analyzer (ORCA)
# You can find more information here:
#       Github - https://github.com/cammurray/orca
#       LinkedIn Article - Reviewing your Office ATP configuration - https://www.linkedin.com/pulse/reviewing-your-office-atp-configuration-cam-murray/
#       
#       Tool Requires Requires EXO-Connect Session - https://aka.ms/exops-docs which will be installed by script
#

function O365-checkcredentials() {
    Param (
        [Parameter(Mandatory=$false)]  [String]$upn #default
    )

    Write-host -Foreground Yellow "`nChecking if authenticated to O365"
    $o365session = Get-PSSession | where-object {$_.name -like '*ExchangeOnline*'}
    if ($o365session) {
        write-host 'Sessions Exists!'
    } else {
        write-host 'No sessions looks to exist. Lets create one.'
        #$UserCredentials = Get-Credential
        #Get-PSSession | Remove-PSSession
        $Session = Connect-ExchangeOnline -UserPrincipalName $upn -ShowProgress $true 
        #$Session = New-PSSession -name 'O365-Session' -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredentials -Authentication Basic -AllowRedirection
        
    } 
}

## Check dependencies and update modules ##
$dependencies = @('ExchangeOnlineManagement', 'ORCA')
ForEach ($module in $dependencies) {
    if ($exist = Get-Module $module) {
        Write-Host -ForegroundColor Green "$($module) is installed. Updating."
    } else {
        Write-Host -ForegroundColor Yellow "$($module) not installed, please standby while I install/update."
        Install-Module $module
    }
    Update-Module $module
    Import-Module $module
}
Get-Module | Where-Object {$_.Name -in $dependencies}

##Compatability and dependency check
$WinRMRunning = (Get-Service 'WinRM').Status

if ($WinRMRunning -ne "Running") {
    $enablePSRemoting = Read-Host -Prompt "WinRM is not detected to be running, Press enter to install."
    Enable-PSRemoting -Force    ## https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting?view=powershell-7
    winrm get winrm/config/client/auth
} else {
    Write-Host "WinRM looks to be running..."
}

O365-checkcredentials  ## Checks if user connected to Exchange Online Remote Powershell Session

Get-ORCAReport  ## Generates report after verification

