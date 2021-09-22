###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  Add-TrustedHost.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Set a trusted host (WinRM)
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
    .SYNOPSIS
    Set a trusted host (WinRM)

    .DESCRIPTION
    Set one or mulitple trusted host(s) (WinRM).

    .EXAMPLE
    Set-TrustedHost -TrustedHost "192.168.178.27", "TEST-DEVICE-02"

    Confirm
    Are you sure you want to perform this action?
    Performing the operation "Add-TrustedHost" on target "WSMan:\localhost\Client\TrustedHosts".
    [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): Y

    .LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Function/Set-TrustedHost.README.md
#>

function Set-TrustedHost
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
            throw "Administrator rights are required to set a trusted host!"
        }
    }

    Process{
        $TrustedHost_Path = "WSMan:\localhost\Client\TrustedHosts"

        try{
            $TrustedHost_Value = $TrustedHost -join ","

            if($PSCmdlet.ShouldProcess($TrustedHost_Path))
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