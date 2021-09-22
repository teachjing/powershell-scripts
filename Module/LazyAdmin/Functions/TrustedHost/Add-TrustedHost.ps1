###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  Add-TrustedHost.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Add a trusted host (WinRM)
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
    .SYNOPSIS
    Add a trusted host (WinRM)

    .DESCRIPTION
    Add one or mulitple trusted host(s) (WinRM).

    .EXAMPLE
    Add-TrustedHost -TrustedHost "192.168.178.27", "TEST-DEVICE-02"

    Confirm
    Are you sure you want to perform this action?
    Performing the operation "Add-TrustedHost" on target "WSMan:\localhost\Client\TrustedHosts".
    [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): Y

    .LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Function/Add-TrustedHost.README.md
#>

function Add-TrustedHost
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
    param(
        [Parameter(
            Position=0,
            Mandatory=$true)]
        [String[]]$TrustedHost
    )

    Begin{
        if(-not([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
        {
            throw "Administrator rights are required to add a trusted host!"
        }
    }

    Process{
        $TrustedHost_Path = "WSMan:\localhost\Client\TrustedHosts"
        [System.Collections.ArrayList]$TrustedHosts = @()

        try{
            [String]$TrustedHost_Value = (Get-Item -Path $TrustedHost_Path).Value
            $TrustedHost_Value = (Get-Item -Path $TrustedHost_Path).Value
            $TrustedHost_ValueOrg = $TrustedHost_Value

            if(-not([String]::IsNullOrEmpty($TrustedHost_Value)))
            {
                $TrustedHosts = $TrustedHost_Value.Split(',')
            }
            
            foreach($TrustedHost2 in $TrustedHost)
            {
                if($TrustedHosts -contains $TrustedHost2)
                {
                    Write-Warning -Message "Trusted host ""$TrustedHost2"" already exists in ""$TrustedHost_Path"" and will be skipped."
                    continue
                }

                [void]$TrustedHosts.Add($TrustedHost2)

                $TrustedHost_Value = $TrustedHosts -join ","
            }

            if(($TrustedHost_Value -ne $TrustedHost_ValueOrg) -and ($PSCmdlet.ShouldProcess($TrustedHost_Path)))
            {
                Set-Item -Path $TrustedHost_Path -Value $TrustedHost_Value -Force
            }    
        }
        catch{
            throw
        }
    }

    End{

    }
}