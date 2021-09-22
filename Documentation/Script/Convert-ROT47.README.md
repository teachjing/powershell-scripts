# Convert-ROT47

Rotate ascii chars by n places (Caesar cipher).

* [view script](https://github.com/BornToBeRoot/PowerShell/blob/master/Scripts/Convert-ROT47.ps1)

## Description

Rotate ascii chars by n places (Caesar cipher). You can encrypt with the parameter `-Encrypt` or decrypt with the parameter `-Decrypt`, depens on what you need. Decryption is selected by default.

Try the parameter `-UseAllAsciiChars` if you have a string with umlauts which e.g. exist in the German language.

![Screenshot](Images/Convert-ROT47.png?raw=true "Convert-ROT47")

## Syntax

```powershell
.\Convert-ROT47.ps1 [-Text] <String> [[-Rot] <Int32[]>] [[-Decrypt]] [[-UseAllAsciiChars]] [<CommonParameters>]

.\Convert-ROT47.ps1 [-Text] <String> [[-Rot] <Int32[]>] [[-Encrypt]] [[-UseAllAsciiChars]] [<CommonParameters>]
``` 

## Example 1

```powershell
PS> .\Convert-ROT47.ps1 -Text "This is an encrypted string!" -Rot 7 -Encrypt

Rot Text
--- ----
  7 [opz pz hu lujy"w{lk z{ypun(
```

## Example 2

```powershell
PS> .\Convert-ROT47.ps1 -Text '[opz pz hu lujy"w{lk z{ypun(' -Rot (5..10)

Rot Text
--- ----
  5 Vjku ku cp gpet{rvgf uvtkpi#
  6 Uijt jt bo fodszqufe tusjoh"
  7 This is an encrypted string!
  8 Sghr hr `m dmbqxosdc rsqhmf~
  9 Rfgq gq _l clapwnrcb qrpgle}
 10 Qefp fp ^k bk`ovmqba pqofkd|
```

## Example 3

```powershell
PS> .\Convert-ROT47.ps1 -Text "Beispiel: Cäsar-Verschlüsselung - Sprache Deutsch!" -Rot 3 -UseAllAsciiChars -Encrypt

Rot Text
--- ----
  3 Ehlvslho= Fçvdu0Yhuvfkoÿvvhoxqj 0 Vsudfkh Ghxwvfk$
```

## Example 4

```powershell
PS> .\Convert-ROT47.ps1 -Text "Ehlvslho= Fçvdu0Yhuvfkoÿvvhoxqj 0 Vsudfkh Ghxwvfk$" -Rot (1..4) -UseAllAsciiChars

Rot Text
--- ----
  1 Dgkurkgn< Eæuct/Xgtuejnþuugnwpi / Urtcejg Fgwvuej#
  2 Cfjtqjfm; Dåtbs.Wfstdimýttfmvoh . Tqsbdif Efvutdi"
  3 Beispiel: Cäsar-Verschlüsselung - Sprache Deutsch!
  4 Adhrohdk9 Bãr`q,Udqrbgkûrrdktmf , Roq`bgd Cdtsrbg
```

## Further information

* [Caesar cipher (rotate by n places) - Wikipedia](https://en.wikipedia.org/wiki/Caesar_cipher)
