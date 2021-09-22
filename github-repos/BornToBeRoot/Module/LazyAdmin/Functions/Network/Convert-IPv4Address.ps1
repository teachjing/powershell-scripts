###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  Convert-IPv4Address
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Convert an IPv4-Address to Int64 and vise versa
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
    .SYNOPSIS
    Convert an IPv4-Address to Int64 and vise versa

    .DESCRIPTION
    Convert an IPv4-Address to Int64 and vise versa. The result will contain the IPv4-Address as string and Tnt64.
    
    .EXAMPLE
    Convert-IPv4Address -IPv4Address "192.168.0.1"   

    IPv4Address      Int64
    -----------      -----
    192.168.0.1 3232235521

    .EXAMPLE
    Convert-IPv4Address -Int64 2886755428

    IPv4Address         Int64
    -----------         -----
    172.16.100.100 2886755428

    .LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Function/Convert-IPv4Address.README.md
#>

function Convert-IPv4Address
{
    [CmdletBinding(DefaultParameterSetName='IPv4Address')]
    param(
        [Parameter(
            ParameterSetName='IPv4Address',
            Position=0,
            Mandatory=$true,
            HelpMessage='IPv4-Address as string like "192.168.1.1"')]
        [IPAddress]$IPv4Address,

        [Parameter(
                ParameterSetName='Int64',
                Position=0,
                Mandatory=$true,
                HelpMessage='IPv4-Address as Int64 like 2886755428')]
        [long]$Int64
    ) 

    Begin {

    }

    Process {
        switch($PSCmdlet.ParameterSetName)
        {
            # Convert IPv4-Address as string into Int64
            "IPv4Address" {
                $Octets = $IPv4Address.ToString().Split(".")
                $Int64 = [long]([long]$Octets[0]*16777216 + [long]$Octets[1]*65536 + [long]$Octets[2]*256 + [long]$Octets[3]) 
            }
    
            # Convert IPv4-Address as Int64 into string 
            "Int64" {            
                $IPv4Address = (([System.Math]::Truncate($Int64/16777216)).ToString() + "." + ([System.Math]::Truncate(($Int64%16777216)/65536)).ToString() + "." + ([System.Math]::Truncate(($Int64%65536)/256)).ToString() + "." + ([System.Math]::Truncate($Int64%256)).ToString())
            }      
        }

        [pscustomobject] @{    
            IPv4Address = $IPv4Address
            Int64 = $Int64
        }        	
    }

    End {

    }      
}