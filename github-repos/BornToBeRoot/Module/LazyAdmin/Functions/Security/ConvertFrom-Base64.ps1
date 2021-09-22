###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  ConvertFrom-Base64.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Convert a Base64 encoded string to a plain text string
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
    .SYNOPSIS
    Convert a Base64 encoded string to a plain text string

    .DESCRIPTION
    Convert a Base64 encoded string to a plain text string.

    .EXAMPLE
    ConvertFrom-Base64 -Text "UwBlAHQALQBMAG8AYwBhAHQAaQBvAG4AIAAtAFAAYQB0AGgAIAAiAEUAOgBcAFQAZQBtAHAAXABGAGkAbABlAHMAXAAiADsARwBlAHQALQBDAGgAaQBsAGQASQB0AGUAbQA="

    Set-Location -Path "E:\Temp\Files\";Get-ChildItem
    
    .LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Function/ConvertFrom-Base64.README.md
#>

function ConvertFrom-Base64
{
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory=$true,
            Position=0,
            HelpMessage='Base64 encoded string, which is to be converted to an plain text string')]
        [String]$Text
    )

    Begin{

    }

    Process{
        try{
            # Convert Base64 to bytes
            $Bytes = [System.Convert]::FromBase64String($Text)

            # Convert Bytes to Unicode and return it
            [System.Text.Encoding]::Unicode.GetString($Bytes)
        }
        catch{
            throw
        }
    }

    End{

    }
}