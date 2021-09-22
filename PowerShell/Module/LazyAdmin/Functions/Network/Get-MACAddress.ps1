###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  Get-MACAddress.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Get the MAC-Address from a remote computer
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
    .SYNOPSIS
    Get the MAC-Address from a remote computer

    .DESCRIPTION   
    Get the MAC-Address from a remote computer. If the MAC-Address could be resolved, the result contains the ComputerName, IPv4-Address and the MAC-Address of the system. Otherwise it returns null. To resolve the MAC-Address your computer need to be in the same subnet as the remote computer (Layer 2). If the result return null, try the parameter "-Verbose" to get more details.

    .EXAMPLE
    Get-MACAddress -ComputerName TEST-PC-01
    
    ComputerName IPv4Address    MACAddress        Vendor
    ------------ -----------    ----------        ------
    TEST-PC-01   192.168.178.20 1D-00-00-00-00-F0 Cisco Systems, Inc

    .EXAMPLE
    Get-MACAddress -ComputerName TEST-PC-01, TEST-PC-02
    
    ComputerName IPv4Address    MACAddress        Vendor
    ------------ -----------    ----------        ------
    TEST-PC-01   192.168.178.20 1D-00-00-00-00-F0 Cisco Systems, Inc
    TEST-PC-02   192.168.178.21 1D-00-00-00-00-F1 ASUSTek COMPUTER INC.

    .LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Function/Get-MACAddress.README.md
#>

function Get-MACAddress
{
    [CmdletBinding()]
    param(
        [Parameter(
            Position=0,
            Mandatory=$true,
            HelpMessage='ComputerName or IPv4-Address of the device which you want to scan')]
        [String[]]$ComputerName
    )

    Begin{
        
    }

    Process{
        foreach($ComputerName2 in $ComputerName)
        {
            $LocalAddress = @("127.0.0.1","localhost",".")

            # Check if ComputerName is a local address, replace it with the computername
            if($LocalAddress -contains $ComputerName2)
            {
                $ComputerName2 = $env:COMPUTERNAME
            }

            # Send ICMP requests to refresh ARP-Cache
            if(-not(Test-Connection -ComputerName $ComputerName2 -Count 2 -Quiet))
            {
                Write-Warning -Message """$ComputerName2"" is not reachable via ICMP. ARP-Cache could not be refreshed!"
            }
            
            # Check if ComputerName is already an IPv4-Address, if not... try to resolve it
            $IPv4Address = [String]::Empty
            
            if([bool]($ComputerName2 -as [System.Net.IPAddress]))
            {
                $IPv4Address = $ComputerName2
            }
            else
            {
                # Get IP from Hostname (IPv4 only)
                try{
                    $AddressList = @(([System.Net.Dns]::GetHostEntry($ComputerName2)).AddressList)
                    
                    foreach($Address in $AddressList)
                    {
                        if($Address.AddressFamily -eq "InterNetwork") 
                        {					
                            $IPv4Address = $Address.IPAddressToString 
                            break					
                        }
                    }					
                }
                catch{ 
                    if([String]::IsNullOrEmpty($IPv4Address))
                    {
                        Write-Error -Message "Could not resolve IPv4-Address for ""$ComputerName2"". MAC-Address resolving has been skipped. (Try to enter an IPv4-Address instead of the Hostname!)" -Category InvalidData

                        continue
                    }
                }	
            }
        
            # Try to get MAC from IPv4-Address
            $MAC = [String]::Empty
        
            
            # +++ ARP-Cache +++
            $Arp_Result = (arp -a).ToUpper()
        
            foreach($Line in $Arp_Result)
            {
                if($Line.TrimStart().StartsWith($IPv4Address))
                {
                    # Some regex magic
                    $MAC = [Regex]::Matches($Line,"([0-9A-F][0-9A-F]-){5}([0-9A-F][0-9A-F])").Value
                }
            }

            # +++ NBTSTAT +++ (try NBTSTAT if ARP-Cache is empty)                                   
            if([String]::IsNullOrEmpty($MAC))
            {                           
                $Nbtstat_Result = nbtstat -A $IPv4Address | Select-String "MAC"

                try{
                    $MAC = [Regex]::Matches($Nbtstat_Result, "([0-9A-F][0-9A-F]-){5}([0-9A-F][0-9A-F])").Value
                }
                catch{
                    if([String]::IsNullOrEmpty($MAC))
                    {
                        Write-Error -Message "Could not resolve MAC-Address for ""$ComputerName2"" ($IPv4Address). Make sure that your computer is in the same subnet as $ComputerName2 and $ComputerName2 is reachable." -Category ConnectionError
                        
                        continue
                    }
                }
            }
           
            [String]$Vendor = (Get-MACVendor -MACAddress $MAC | Select-Object -First 1).Vendor 
         
            [pscustomobject] @{
                ComputerName = $ComputerName2
                IPv4Address = $IPv4Address
                MACAddress = $MAC
                Vendor = $Vendor
            }
        }   
    }

    End{

    }
}