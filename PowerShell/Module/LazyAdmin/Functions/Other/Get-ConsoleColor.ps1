###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  Get-ConsoleColor.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Get all available console colors
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
    .SYNOPSIS
    Get all available console colors 

    .DESCRIPTION
    Get all available console colors. A preview how they look (foreground and background) can be displayed with the parameter "-Preview".

    .EXAMPLE
    Get-ConsoleColor

    ConsoleColor
    ------------
           Black
        DarkBlue
       DarkGreen
        DarkCyan
         DarkRed
     DarkMagenta
      DarkYellow
            Gray
        DarkGray
            Blue
           Green
            Cyan
             Red
         Magenta
          Yellow
           White

    .LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Function/Get-ConsoleColor.README.md
#>

function Get-ConsoleColor
{
    [CmdletBinding()]
    param(
        
    )

    Begin{

    }

    Process{
        $Colors = [Enum]::GetValues([ConsoleColor])

        foreach($Color in $Colors)
        {
            [pscustomobject] @{
                ConsoleColor = $Color
            }
        }
    }

    End{

    }
}