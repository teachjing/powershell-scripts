# Convert-ROT13

Rotate lower and upper chars by n places (Caesar cipher).

* [view script](https://github.com/BornToBeRoot/PowerShell/blob/master/Scripts/Convert-ROT13.ps1)

## Description

Rotate lower and upper chars by n places (Caesar cipher). By default all 26 options are converted. You can encrypt with the parameter `-Encrypt` or decrypt with the parameter `-Decrypt`, depens on what you need. Decryption is selected by default.

![Screenshot](Images/Convert-ROT13.png?raw=true "Convert-ROT13")

## Syntax

```powershell
.\Convert-ROT13.ps1 [-Text] <String> [[-Rot] <Int32[]>] [[-Decrypt]] [<CommonParameters>]

.\Convert-ROT13.ps1 [-Text] <String> [[-Rot] <Int32[]>] [[-Encrypt]] [<CommonParameters>]
``` 

## Example 1

```powershell
PS> .\Convert-ROT13.ps1 -Text "This is an encrypted string!" -Rot 7 -Encrypt

Rot Text
--- ----
  7 Aopz pz hu lujyfwalk zaypun!
```

## Example 2

```powershell
PS> .\Convert-ROT13.ps1 -Text "Aopz pz hu lujyfwalk zaypun!"

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
```

## Further information

* [Caesar cipher (rotate by n places) - Wikipedia](https://en.wikipedia.org/wiki/Caesar_cipher)
