###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  ConvertTo-Base64.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Convert a text (command) to an Base64 encoded string
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
    .SYNOPSIS
    Convert a text (command) to an Base64 encoded string

    .DESCRIPTION
    Convert a text (command) to an Base64 encoded string.

    .EXAMPLE
    ConvertTo-Base64 -Text 'Set-Location -Path "E:\Temp\Files\";Get-ChildItem'

    UwBlAHQALQBMAG8AYwBhAHQAaQBvAG4AIAAtAFAAYQB0AGgAIAAiAEUAOgBcAFQAZQBtAHAAXABGAGkAbABlAHMAXAAiADsARwBlAHQALQBDAGgAaQBsAGQASQB0AGUAbQA=

    powershell.exe -NoProfile -EncodedCommand "UwBlAHQALQBMAG8AYwBhAHQAaQBvAG4AIAAtAFAAYQB0AGgAIAAiAEUAOgBcAFQAZQBtAHAAXABGAGkAbABlAHMAXAAiADsARwBlAHQALQBDAGgAaQBsAGQASQB0AGUAbQA="

        Directory: E:\Temp\Files


    Mode                LastWriteTime         Length Name
    ----                -------------         ------ ----
    -a----        8/21/2016   5:54 PM              5 File_01.txt
    -a----        8/20/2016  12:54 AM              9 File_02.txt
    -a----        8/20/2016  12:08 AM             14 File_03.txt
    -a----        6/24/2016   5:01 PM            120 File_04.zip
    -a----        8/20/2016  12:54 AM             14 File_05.txt       
    
    .LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Function/ConvertTo-Base64.README.md
#>

function ConvertTo-Base64
{
    [CmdletBinding(DefaultParameterSetName='Text')]
    param(
        [Parameter(
            ParameterSetName='Text',
            Mandatory=$true,
            Position=0,
            HelpMessage='Text (command), which is to be converted to a Base64 encoded string')]
        [String]$Text,

        [Parameter(
            ParameterSetName='File',
            Mandatory=$true,
            Position=0,
            HelpMessage='Path to the file where the text (command) is stored, which is to be converterd to a Base64 encoded string')]
        [String]$FilePath
    )

    Begin{

    }

    Process{
        switch ($PSCmdlet.ParameterSetName) 
        {
            "Text" {
                $TextToConvert = $Text
            }

            "File" {
                if(Test-Path -Path $FilePath -PathType Leaf)
                {
                    $TextToConvert = Get-Content -Path $FilePath
                }
                else 
                {
                    throw "No valid file path entered... Check your input!"
                }
            }                                   
        }

        try{
            # Convert plain text to bytes
            $BytesToConvert = [Text.Encoding]::Unicode.GetBytes($TextToConvert)

            # Convert Bytes to Base64
            $EncodedText = [Convert]::ToBase64String($BytesToConvert)
        }
        catch{
            throw
        }

        if($EncodedText.Length -gt 8100)
        {
            Write-Warning -Message "Encoded command may be to long to run via ""-EncodedCommand"" of PowerShell.exe"    
        }

        $EncodedText
    }

    End{

    }
}