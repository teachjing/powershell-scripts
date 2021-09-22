###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  Get-TrustedHost.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Get trusted hosts (WinRM)
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
    .SYNOPSIS
    Get trusted hosts (WinRM)

    .DESCRIPTION
    Get trusted hosts (WinRM).

    .EXAMPLE
    Get-TrustedHost

    TrustedHost
    -----------
    192.168.178.28
    172.16.1.*
    Windows7x64

    .LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Function/Get-TrustedHost.README.md
#>

function Get-TrustedHost
{
    [CmdletBinding()]
    param(
      
    )

    Begin{
    }

    Process{
        $TrustedHost_Path = "WSMan:\localhost\Client\TrustedHosts"

        try{
            [String]$TrustedHost_Value = (Get-Item -Path $TrustedHost_Path).Value
        }
        catch{
            throw
        }

        if([String]::IsNullOrEmpty($TrustedHost_Value))
        {            
            return
        }

        foreach($TrustedHosts in $TrustedHost_Value.Split(','))
        {
            [pscustomobject] @{
                TrustedHost = $TrustedHosts
            }
        }                                    
    }

    End{

    }
}