###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  Update-StringInFile.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Replace a string in multiple files
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
    .SYNOPSIS
    Replace a string in one or multiple files
                 
    .DESCRIPTION         
    Replace a string in one or multiple files.
	
    Binary files (*.zip, *.exe, etc.) are not touched by this script.
	                         
    .EXAMPLE
    Update-StringInFile -Path E:\Temp\Files\ -Find "Test1" -Replace "Test2" -Verbose
       
	VERBOSE: Binary files like (*.zip, *.exe, etc...) are ignored
	VERBOSE: Total files with string to replace found: 3
	VERBOSE: Current file: E:\Temp\Files\File_01.txt
	VERBOSE: Number of strings to replace in current file: 1
	VERBOSE: Current file: E:\Temp\Files\File_02.txt
	VERBOSE: Number of strings to replace in current file: 1
	VERBOSE: Current file: E:\Temp\Files\File_03.txt
	VERBOSE: Number of strings to replace in current file: 2
	   
    .LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Function/Update-StringInFile.README.md
#>

function Update-StringInFile
{
	[CmdletBinding(SupportsShouldProcess=$true)]
	Param(
		[Parameter(
			Position=0,
			HelpMessage="Folder where the files are stored (will search recursive)")]
		[ValidateScript({
			if(Test-Path -Path $_)
			{
				return $true
			}
			else 
			{
				throw "Enter a valid path!"	
			}
		})]
		[String]$Path = (Get-Location),

		[Parameter(
			Position=1,
			Mandatory=$true,
			HelpMessage="String to find")]
		[String]$Find,
	
		[Parameter(
			Position=2,
			Mandatory=$true,
			HelpMessage="String to replace")]
		[String]$Replace,

		[Parameter(
			Position=3,
			HelpMessage="String must be case sensitive (Default=false)")]
		[switch]$CaseSensitive=$false
	)

	Begin{

	}

	Process{
		Write-Verbose -Message "Binary files like (*.zip, *.exe, etc...) are ignored"

		$Files = Get-ChildItem -Path $Path -Recurse | Where-Object { ($_.PSIsContainer -eq $false) -and ((Test-IsFileBinary -FilePath $_.FullName) -eq $false) } | Select-String -Pattern ([regex]::Escape($Find)) -CaseSensitive:$CaseSensitive | Group-Object Path 
		
		Write-Verbose -Message "Total files with string to replace found: $($Files.Count)"

		# Go through each file
		foreach($File in $Files)
		{
			Write-Verbose -Message "File:`t$($File.Name)"
			Write-Verbose -Message "Number of strings to replace in current file:`t$($File.Count)"
    
			if($PSCmdlet.ShouldProcess($File.Name))
			{
				try
				{	
					# Replace string
					if($CaseSensitive)
					{
						(Get-Content -Path $File.Name) -creplace [regex]::Escape($Find), $Replace | Set-Content -Path $File.Name -Force
					}
					else
					{
						(Get-Content -Path $File.Name) -replace [regex]::Escape($Find), $Replace | Set-Content -Path $File.Name -Force
					}
				}
				catch
				{
					Write-Error -Message "$($_.Exception.Message)" -Category InvalidData
				}
			}
		}
	}

	End{

	}
}