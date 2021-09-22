###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  Convert-ROT13.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Rotate chars by n places (Caesar cipher)
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
    .SYNOPSIS
    Rotate lower and upper chars by n places (Caesar cipher)

    .DESCRIPTION
    Rotate lower and upper chars by n places (Caesar cipher). By default all 26 options are converted. You can encrypt with the parameter "-Encrypt" or decrypt with the parameter "-Decrypt", depens on what you need. Decryption is selected by default.
        
    .EXAMPLE
    .\Convert-ROT13.ps1 -Text "This is an encrypted string!" -Rot 7 -Encrypt

    Rot Text
    --- ----
      7 Aopz pz hu lujyfwalk zaypun!

    .EXAMPLE
    .\Convert-ROT13.ps1 -Text "Aopz pz hu lujyfwalk zaypun!"

    Rot Text
    --- ----
      1 Znoy oy gt ktixevzkj yzxotm!
      2 Ymnx nx fs jshwduyji xywnsl!
      3 Xlmw mw er irgvctxih wxvmrk!
      4 Wklv lv dq hqfubswhg vwulqj!
      5 Vjku ku cp gpetarvgf uvtkpi!
      6 Uijt jt bo fodszqufe tusjoh!
      7 This is an encrypted string!
      8 Sghr hr zm dmbqxosdc rsqhmf!
      9 Rfgq gq yl clapwnrcb qrpgle!
     10 Qefp fp xk bkzovmqba pqofkd!
     11 Pdeo eo wj ajynulpaz opnejc!
     12 Ocdn dn vi zixmtkozy nomdib!
     13 Nbcm cm uh yhwlsjnyx mnlcha!
     14 Mabl bl tg xgvkrimxw lmkbgz!
     15 Lzak ak sf wfujqhlwv kljafy!
     16 Kyzj zj re vetipgkvu jkizex!
     17 Jxyi yi qd udshofjut ijhydw!
     18 Iwxh xh pc tcrgneits higxcv!
     19 Hvwg wg ob sbqfmdhsr ghfwbu!
     20 Guvf vf na rapelcgrq fgevat!
     21 Ftue ue mz qzodkbfqp efduzs!
     22 Estd td ly pyncjaepo dectyr!
     23 Drsc sc kx oxmbizdon cdbsxq!
     24 Cqrb rb jw nwlahycnm bcarwp!
     25 Bpqa qa iv mvkzgxbml abzqvo!
     26 Aopz pz hu lujyfwalk zaypun!

    .LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Script/Convert-ROT13.README.md
#>

[CmdletBinding(DefaultParameterSetName='Decrypt')]
param(
    [Parameter(
        Position=0,
        Mandatory=$true,
        HelpMessage='String which you want to encrypt or decrypt')]    
    [String]$Text,

    [Parameter(
        Position=1,
        HelpMessage='Specify which rotation you want to use (Default=1..26)')]
    [ValidateRange(1,26)]
    [Int32[]]$Rot=1..26,

    [Parameter(
        ParameterSetName='Encrypt',
        Position=2,
        HelpMessage='Encrypt a string')]
    [switch]$Encrypt,
    
    [Parameter(
        ParameterSetName='Decrypt',
        Position=2,
        HelpMessage='Decrypt a string')]
    [switch]$Decrypt   
)

Begin{
    [System.Collections.ArrayList]$UpperChars = @()
    [System.Collections.ArrayList]$LowerChars = @()
 
    $UpperIndex = 1
    $LowerIndex = 1

    # Add upper case chars from ascii
    foreach($i in 65..90)
    {
        $Char = [char]$i

        [pscustomobject]$Result = @{
            Index = $UpperIndex
            Char = $Char
        }   

        [void]$UpperChars.Add($Result)

        $UpperIndex++
    }

    # Add lower case chars from ascii
    foreach($i in 97..122)
    {
        $Char = [char]$i

        [pscustomobject]$Result = @{
            Index = $LowerIndex
            Char = $Char
        }   

        [void]$LowerChars.Add($Result)

        $LowerIndex++
    }

    # Default mode is "Decrypt"
    if(($Encrypt -eq $false -and $Decrypt -eq $false) -or ($Decrypt)) 
    {        
        $Mode = "Decrypt"
    }    
    else 
    {
        $Mode = "Encrypt"
    }

    Write-Verbose -Message "Mode is set to: $Mode"
}

Process{
    foreach($Rot2 in $Rot)
    {        
        $ResultText = [String]::Empty

        # Go through each char in string
        foreach($i in 0..($Text.Length -1))
        {
            $CurrentChar = $Text.Substring($i, 1)

            if($UpperChars.Char -ccontains $CurrentChar) # Upper chars
            {
                if($Mode -eq  "Encrypt")
                {
                    [int]$NewIndex = ($UpperChars | Where-Object {$_.Char -ceq $CurrentChar}).Index + $Rot2 

                    if($NewIndex -gt $UpperChars.Count)
                    {
                        $NewIndex -= $UpperChars.Count                     
                    
                        $ResultText +=  ($UpperChars | Where-Object {$_.Index -eq $NewIndex}).Char
                    }
                    else 
                    {
                        $ResultText += ($UpperChars | Where-Object {$_.Index -eq $NewIndex}).Char    
                    }
                }
                else 
                {
                    [int]$NewIndex = ($UpperChars | Where-Object {$_.Char -ceq $CurrentChar}).Index - $Rot2 

                    if($NewIndex -lt 1)
                    {
                        $NewIndex += $UpperChars.Count                     
                    
                        $ResultText +=  ($UpperChars | Where-Object {$_.Index -eq $NewIndex}).Char
                    }
                    else 
                    {
                        $ResultText += ($UpperChars | Where-Object {$_.Index -eq $NewIndex}).Char    
                    }
                }   
            }
            elseif($LowerChars.Char -ccontains $CurrentChar) # Lower chars
            {
                if($Mode -eq "Encrypt")
                {
                    [int]$NewIndex = ($LowerChars | Where-Object {$_.Char -ceq $CurrentChar}).Index + $Rot2

                    if($NewIndex -gt $LowerChars.Count)
                    {
                        $NewIndex -=  $LowerChars.Count

                        $ResultText += ($LowerChars | Where-Object {$_.Index -eq $NewIndex}).Char
                    }
                    else 
                    {
                        $ResultText += ($LowerChars | Where-Object {$_.Index -eq $NewIndex}).Char  
                    }
                }
                else 
                {
                    [int]$NewIndex = ($LowerChars | Where-Object {$_.Char -ceq $CurrentChar}).Index - $Rot2

                    if($NewIndex -lt 1)
                    {
                        $NewIndex += $LowerChars.Count

                        $ResultText += ($LowerChars | Where-Object {$_.Index -eq $NewIndex}).Char
                    }
                    else 
                    {
                        $ResultText += ($LowerChars | Where-Object {$_.Index -eq $NewIndex}).Char  
                    }      
                }
            }
            else 
            {
                $ResultText += $CurrentChar  
            }
        } 
            
        [pscustomobject] @{
            Rot = $Rot2
            Text = $ResultText
        }
    }
}

End{

}
        