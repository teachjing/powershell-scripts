###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  Get-WindowsProductKey.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Get the Windows product key and some usefull informations about the system
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
    .SYNOPSIS    
    Get the Windows product key and some usefull informations about the system

    .DESCRIPTION    
    Get the Windows product key from a local or remote system and some informations like Serialnumber, Windows version, Bit-Version etc. from one or more computers. Remote computers need WinRM enabled. To do this use "winrm quickconfig".
        
    Basic Logic found on: http://powershell.com/cs/blogs/tips/archive/2012/04/30/getting-windows-product-key.aspx          
                
    .EXAMPLE        
    Get-WindowsProductKey

	ComputerName   : TEST-PC-01
	WindowsVersion : Microsoft Windows 10 Pro
	CSDVersion     :
	BitVersion     : 64-bit
	BuildNumber    : 10586
	ProductID      : 00000-00000-00000-00000
	ProductKey     : XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
	
    .EXAMPLE
    Get-WindowsProductKey -ComputerName TEST-PC-01,TEST-PC-02
	
	ComputerName   : TEST-PC-01
	WindowsVersion : Microsoft Windows 10 Pro
	CSDVersion     :
	BitVersion     : 64-bit
	BuildNumber    : 10586
	ProductID      : 00000-00000-00000-00000
	ProductKey     : XXXXX-XXXXX-XXXXX-XXXXX-XXXXX

	ComputerName   : TEST-PC-02
	WindowsVersion : Microsoft Windows 10 Pro
	CSDVersion     :
	BitVersion     : 64-bit
	BuildNumber    : 10586
	ProductID      : 00000-00000-00000-00000
	ProductKey     : XXXXX-XXXXX-XXXXX-XXXXX-XXXXX

    .LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Function/Get-WindowsProductKey.README.md
#>

function Get-WindowsProductKey
{
	[CmdletBinding()]
	param(
		[Parameter(
			Position=0,
			HelpMessage='ComputerName or IPv4-Address of the remote computer')]
		[String[]]$ComputerName = $env:COMPUTERNAME,

		[Parameter(
			Position=1,
			HelpMessage='Credentials to authenticate agains a remote computer')]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.CredentialAttribute()]
		$Credential
	)

	Begin{
		$LocalAddress = @("127.0.0.1","localhost",".","$($env:COMPUTERNAME)")

		[System.Management.Automation.ScriptBlock]$Scriptblock = {
			$ProductKeyValue = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").digitalproductid[0x34..0x42]
			$Wmi_Win32OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -Property Caption, CSDVersion, Version, OSArchitecture, BuildNumber, SerialNumber

			[pscustomobject] @{
				ProductKeyValue = $ProductKeyValue
				Wmi_Win32OperatingSystem = $Wmi_Win32OperatingSystem				
			}
		}
	}

	Process{   
		foreach($ComputerName2 in $ComputerName) 
		{              
			$Chars="BCDFGHJKMPQRTVWXY2346789" 

			# Don't use Invoke-Command on local machine. Prevent errors if WinRM is not configured
			if($LocalAddress -contains $ComputerName2)
			{
				$ComputerName2 = $env:COMPUTERNAME
 
				$Scriptblock_Result = Invoke-Command -ScriptBlock $Scriptblock
			}
			else
			{
				if(-not(Test-Connection -ComputerName $ComputerName2 -Count 2 -Quiet))
				{
					Write-Error -Message "$ComputerName2 is not reachable via ICMP!" -Category ConnectionError
					continue
				}

				try {
					if($PSBoundParameters['Credential'] -is [System.Management.Automation.PSCredential])
					{
						$Scriptblock_Result = Invoke-Command -ScriptBlock $Scriptblock -ComputerName $ComputerName2 -Credential $Credential -ErrorAction Stop
					}
					else
					{					    
						$Scriptblock_Result = Invoke-Command -ScriptBlock $Scriptblock -ComputerName $ComputerName2 -ErrorAction Stop
					}
				}
				catch {
					Write-Error -Message "$($_.Exception.Message)" -Category ConnectionError
					continue	
				}
			}
		
			$ProductKey = ""

			for($i = 24; $i -ge 0; $i--) 
			{ 
				$r = 0 

				for($j = 14; $j -ge 0; $j--) 
				{ 
					$r = ($r * 256) -bxor $Scriptblock_Result.ProductKeyValue[$j] 
					$Scriptblock_Result.ProductKeyValue[$j] = [math]::Floor([double]($r/24)) 
					$r = $r % 24 
				}
	
				$ProductKey = $Chars[$r] + $ProductKey 

				if (($i % 5) -eq 0 -and $i -ne 0) 
				{ 
					$ProductKey = "-" + $ProductKey 
				} 
			} 

			[pscustomobject] @{
				ComputerName = $ComputerName2
				Caption = $Scriptblock_Result.Wmi_Win32OperatingSystem.Caption
				CSDVersion = $Scriptblock_Result.Wmi_Win32OperatingSystem.CSDVersion
				WindowsVersion = $Scriptblock_Result.Wmi_Win32OperatingSystem.Version
				OSArchitecture = $Scriptblock_Result.Wmi_Win32OperatingSystem.OSArchitecture
				BuildNumber = $Scriptblock_Result.Wmi_Win32OperatingSystem.BuildNumber
				SerialNumber = $Scriptblock_Result.Wmi_Win32OperatingSystem.SerialNumber
				ProductKey = $ProductKey
			}     
		}   
	}

	End{
		
	}
}