###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  Get-ARPCache.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Get the ARP cache
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
    .SYNOPSIS
    Get the ARP cache

    .DESCRIPTION
    Get the Address Resolution Protocol (ARP) cache, which is used for resolution of internet layer addresses into link layer addresses.

    .EXAMPLE
    Get-ARPCache

    Interface      IPv4Address     MACAddress        Type
    ---------      -----------     ----------        ----
    192.168.56.1   192.168.56.255  FF-00-00-00-00-FF static
    192.168.56.1   224.0.0.22      01-00-5E-00-00-16 static
    192.168.56.1   239.255.255.250 01-00-00-00-00-FA static
    192.168.178.22 192.168.178.1   5C-00-00-00-00-77 dynamic
    192.168.178.22 192.168.178.255 FF-00-00-00-00-FF static
    192.168.178.22 224.0.0.22      01-00-00-00-00-16 static
    192.168.178.22 239.255.255.250 01-00-00-00-00-FA static

    .EXAMPLE
    Get-ARPCache | Where-Object {$_.Interface -eq "192.168.178.22"}

    Interface      IPv4Address     MACAddress        Type
    ---------      -----------     ----------        ----
    192.168.178.22 192.168.178.1   5C-00-00-00-00-77 dynamic
    192.168.178.22 192.168.178.255 FF-00-00-00-00-FF static
    192.168.178.22 224.0.0.22      01-00-00-00-00-16 static
    192.168.178.22 239.255.255.250 01-00-00-00-00-FA static
    
    .LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Function/Get-ARPCache.README.md
#>

function Get-ARPCache
{
    [CmdletBinding()]
    param(

    )

    Begin{
            
    }

    Process{
        # Regex for IPv4-Address
        $RegexIPv4Address = "(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
        $RegexMACAddress = "([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})|([0-9A-Fa-f]{2}){6}"

        # Get the arp cache...
        $Arp_Result = arp -a

        foreach($line in $Arp_Result)
        {
            # Detect line where interface starts
            if($line -like "*---*")
            {            
                Write-Verbose -Message "Interface $line"

                $InterfaceIPv4 = [regex]::Matches($line, $RegexIPv4Address).Value

                Write-Verbose -Message "$InterfaceIPv4"            
            }
            elseif($line -match $RegexMACAddress)
            {            
                foreach($split in $line.Split(" "))
                {
                    if($split -match $RegexIPv4Address)
                    {
                        $IPv4Address = $split
                    }
                    elseif ($split -match $RegexMACAddress) 
                    {
                        $MACAddress = $split.ToUpper()    
                    }
                    elseif(-not([String]::IsNullOrEmpty($split)))
                    {
                        $Type = $split
                    }
                }

                [pscustomobject] @{
                    Interface = $InterfaceIPv4
                    IPv4Address = $IPv4Address
                    MACAddress = $MACAddress
                    Type = $Type
                }
            }
        }
    }

    End{

    }
}