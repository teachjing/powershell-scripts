###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  Split-IPv4Subnet.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Split a subnet in multiple subnets with given subnetmasks
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
    .SYNOPSIS
    Split a subnet in multiple subnets with given subnetmasks
    
    .DESCRIPTION
    Split a subnet in multiple subnets with given subnetmasks. Each new subnet contains NetworkID, Broadcast, total available IPs and usable IPs for hosts.
    
    .EXAMPLE
    Split-IPv4Subnet -IPv4Address 192.168.0.0 -CIDR 22 -NewCIDR 24

    NetworkID   Broadcast     IPs Hosts
    ---------   ---------     --- -----
    192.168.0.0 192.168.0.255 256   254
    192.168.1.0 192.168.1.255 256   254
    192.168.2.0 192.168.2.255 256   254
    192.168.3.0 192.168.3.255 256   254

    .EXAMPLE
    Split-IPv4Subnet -IPv4Address 192.168.0.0 -Mask 255.255.255.0 -NewMask 255.255.255.128

    NetworkID     Broadcast     IPs Hosts
    ---------     ---------     --- -----
    192.168.0.0   192.168.0.127 128   126
    192.168.0.128 192.168.0.255 128   126
    
    .LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Function/Split-IPv4Subnet.README.md
#>

function Split-IPv4Subnet
{
    [CmdletBinding(DefaultParameterSetName='CIDR')]
    param(
        [Parameter(
            Position=0,
            Mandatory=$true,
            HelpMessage='IPv4-Address which is in the subnet')]
        [IPAddress]$IPv4Address,

        [Parameter(
            ParameterSetName='CIDR',
            Position=1,
            Mandatory=$true,
            HelpMessage='CIDR like /24 without "/"')]
        [ValidateRange(0,31)]
        [Int32]$CIDR,

        [Parameter(
            ParameterSetName='CIDR',
            Position=2,
            Mandatory=$true,
            HelpMessage='New CIDR like /28 without "/"')]
        [ValidateRange(0,31)]
        [Int32]$NewCIDR,

        [Parameter(
            ParameterSetName='Mask',
            Position=1,
            Mandatory=$true,
            Helpmessage='Subnetmask like 255.255.255.0')]
        [ValidateScript({
            if($_ -match "^(254|252|248|240|224|192|128).0.0.0$|^255.(254|252|248|240|224|192|128|0).0.0$|^255.255.(254|252|248|240|224|192|128|0).0$|^255.255.255.(254|252|248|240|224|192|128|0)$")
            {
                return $true
            }
            else {
                throw "Enter a valid subnetmask (like 255.255.255.0)!"
            }
        })]
        [String]$Mask,

        [Parameter(
            ParameterSetName='Mask',
            Position=2,
            Mandatory=$true,
            HelpMessage='Subnetmask like 255.255.255.128')]
        [ValidateScript({
            if($_ -match "^(254|252|248|240|224|192|128).0.0.0$|^255.(254|252|248|240|224|192|128|0).0.0$|^255.255.(254|252|248|240|224|192|128|0).0$|^255.255.255.(254|252|248|240|224|192|128|0)$")
            {
                return $true
            }
            else 
            {
                throw "Enter a valid subnetmask (like 255.255.255.0)!"
            }
        })]
        [String]$NewMask  
    )

    Begin{
      
    }

    Process{
        if($PSCmdlet.ParameterSetName -eq 'Mask')
        {
            $CIDR = (Convert-Subnetmask -Mask $Mask).CIDR 
            $NewCIDR = (Convert-Subnetmask -Mask $NewMask).CIDR
        }
        
        if($CIDR -ge $NewCIDR)
        {
            throw "Subnet (/$CIDR) can't be greater or equal than new subnet (/$NewCIDR)"
        }

        # Calculate the current Subnet
        $Subnet = Get-IPv4Subnet -IPv4Address $IPv4Address -CIDR $CIDR
        
        # Get new  HostBits based on SubnetBits (CIDR) // Hostbits (32 - /24 = 8 -> 00000000000000000000000011111111)
        $NewHostBits = ('1' * (32 - $NewCIDR)).PadLeft(32, "0")

        # Convert Bits to Int64, add +1 to get all available IPs
        $NewAvailableIPs = ([Convert]::ToInt64($NewHostBits,2) + 1)

        # Convert the NetworkID to Int64
        $NetworkID_Int64 = (Convert-IPv4Address -IPv4Address $Subnet.NetworkID).Int64
        
        # Build new subnets, and return them
        for($i = 0; $i -lt $Subnet.IPs;$i += $NewAvailableIPs)
        {
            Get-IPv4Subnet -IPv4Address (Convert-IPv4Address -Int64 ($NetworkID_Int64 + $i)).IPv4Address -CIDR $NewCIDR
        }
    }

    End{

    }
}