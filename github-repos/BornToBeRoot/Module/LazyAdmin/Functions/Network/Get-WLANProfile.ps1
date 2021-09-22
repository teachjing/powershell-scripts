###############################################################################################################
# Language     :  PowerShell 5.0
# Filename     :  Get-WLANProfile.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Get WLAN profiles, include password as SecureString or as plain text
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
    .SYNOPSIS
    Get WLAN profiles, include password as SecureString or as plain text
   
   	.DESCRIPTION
    Get WLAN profiles on your local system, include Name, SSID, Authentication and Password as secure string or plain text. You don't need an additional application, which is full of advertising.	And for learning purposes it shows, how easy it is to find out the WLAN password, if you have  physical/remote access to the computer. 
	
	All this just by parsing the output of netsh.exe, which can be called without admin permissions.      

    .EXAMPLE
    Get-WLANProfile

	Name              SSID               Authentification    Password
	----              ----               ---------------     ------
	MyHomeNetwork01   MyHomeNetwork      WPA2-Personal       System.Security.SecureString
	MyHomeNetwork02   MyHomenetwork5G    WPA2-Personal       System.Security.SecureString
	
    .EXAMPLE
    Get-WLANProfile -ShowPassword
       
	Name              SSID               Authentification    Password
	----              ----               ---------------     ------
	MyHomeNetwork01   MyHomeNetwork      WPA2-Personal       MyPassword123456789
	MyHomeNetwork02   MyHomenetwork5G    WPA2-Personal       MyPassword987654321   
	   
    .LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Function/Get-WLANProfile.README.md
#>

function Get-WLANProfile
{
	[CmdletBinding()]
	param(
		[Parameter(
			Position=0,
			HelpMessage='Indicates that the password appears in plain text')]
		[Switch]$ShowPassword,
		
		[Parameter(
			Position=1,
			HelpMessage='Filter WLAN-Profiles by Name or SSID')]
		[String]$Search,

		[Parameter(
			Position=2,
			HelpMessage='Exact match, when filter WLAN-Profiles by Name or SSID')]
		[Switch]$ExactMatch
	)

	Begin{

	}

	Process{
		# Get all WLAN Profiles from netsh
		$Netsh_WLANProfiles = (netsh WLAN show profiles)

		# Some vars to filter netsh results
		$IsProfile = 0
		$WLAN_Names = @()
		
		# Filter result and get the wlan profile names
		foreach($Line in $Netsh_WLANProfiles)
		{
			if((($IsProfile -eq 2)) -and (-not([String]::IsNullOrEmpty($Line))))
			{
				$WLAN_Names += $Line.Split(':')[1].Trim()
			}
		
			if($Line.StartsWith("---"))
			{
				$IsProfile += 1
			}
		}

		# Get details from every wlan profile, using the name (ssid/password/authentification/etc.)
		foreach($WLAN_Name in $WLAN_Names)
		{
			$Netsh_WLANProfile = (netsh WLAN show profiles name="$WLAN_Name" key=clear)
		
			# Counter to filter netsh result... (useful for multiple languages / split would only work for one language )
			$InProfile = 0
			$IsConnectivity = 0
			$IsSecurity = 0
		
			foreach($Line in $Netsh_WLANProfile)
			{
				if((($InProfile -eq 2)) -and (-not([String]::IsNullOrEmpty($Line))))
				{			
					
					if($IsConnectivity -eq 1) 
					{ 
						$WLAN_SSID = $Line.Split(':')[1].Trim()
						$WLAN_SSID = $WLAN_SSID.Substring(1,$WLAN_SSID.Length -2)
					}

					$IsConnectivity += 1
				}

				if((($InProfile -eq 3)) -and (-not([String]::IsNullOrEmpty($Line))))
				{			
					if($IsSecurity -eq 0) # Get the authentication mode
					{
						$WLAN_Authentication = $Line.Split(':')[1].Trim()
					}
					elseif($IsSecurity -eq 3) # Get the password
					{
						$WLAN_Password_PlainText = $Line.Split(':')[1].Trim()
					}
				
					$IsSecurity += 1   
				}
		
				if($Line.StartsWith("---"))
				{
					$InProfile += 1
				}   
			}

			# As SecureString or plain text
			if($ShowPassword) 
			{
				$WLAN_Password = $WLAN_Password_PlainText
			}
			else
			{
				$WLAN_Password = ConvertTo-SecureString -String "$WLAN_Password_PlainText" -AsPlainText -Force
			}

			# Built the custom PSObject
			$WLAN_Profile = [pscustomobject] @{
				Name = $WLAN_Name
				SSID = $WLAN_SSID
				Authentication = $WLAN_Authentication
				Password = $WLAN_Password
			}

			# Add the custom PSObject to the array
			if($PSBoundParameters.ContainsKey('Search'))
			{
				if((($WLAN_Profile.Name -like $Search) -or ($WLAN_Profile.SSID -like $Search)) -and (-not($ExactMatch) -or ($WLAN_Profile.Name -eq $Search) -or ($WLAN_Profile.SSID -eq $Search)))
				{
					$WLAN_Profile
				} 
			}
			else
			{
				$WLAN_Profile
			}        
		}
	}

	End{
		
	}
}