#Be sure to allow this script to execute. Something like this.
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

#Loads the module
$moduleName = "ConvertFrom-EncodedSafeLinks"
Import-Module "..\$($moduleName).psm1" -Force  #loads the module and force it to reload if changes are made.

Write-Host "`nThe following commands have been imported: "
Get-Command -Module $moduleName

#user variable created from calling function using test.com domain

#Sample Token from https://www.jsonwebtoken.io/
$EncodedURL = "https://nam06.safelinks.protection.outlook.com/?url=https%3A%2F%2Fhello.goldbelly.com%2Fz%2Fssbeffn33%3Fuid%3Ddafacbca-d517-4a80-a4cb-3bb061344d1f%26mid%3D64419369-75d9-4c26-a92c-f2b1ba518bab%26bsft_mime_type%3Dhtml%26bsft_ek%3D2020-05-12T18%253A01%253A40Z&data=02%7C01%7CJing.Nghik%40microsoft.com%7C0cb47ddd20a14e0ee98308d7f6a0772c%7C72f988bf86f141af91ab2d7cd011db47%7C1%7C0%7C637249041371411854&sdata=PJeh33RcvuWx4bCl%2BEe7Fj1Ek207Ty5OhKGHxOCTDeI%3D&reserved=0"

$Converted = ConvertFrom-EncodedSafeLinks($EncodedURL)

Write-Host "`nHere is the decoded information"
Write-Host "Your Email is $($Converted.email)"
Write-Host "Your URL is $($Converted.URL)"

