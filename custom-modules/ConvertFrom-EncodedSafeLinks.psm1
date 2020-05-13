function ConvertFrom-EncodedSafeLinks
{
    Param ([String] $decode)

    Write-Host "`nConverting Encoded URL"
    Add-Type -AssemblyName System.Web   #This allows you to use HTTP Decoder
    ## Create Response object
    $response = New-Object PSObject -Property @{
        EncodedURL      = $decode 
        DecodedURL      = $DecodedURL
        URL             = ""
        Email           = ""
    }

    if ($response.URL = "") {
        Write-Host "No encoded Safe-Links URL provided.... Decoding example URL"
        $response.URL = "https://nam06.safelinks.protection.outlook.com/?url=https%3A%2F%2Fhello.goldbelly.com%2Fz%2Fssbeffn33%3Fuid%3Ddafacbca-d517-4a80-a4cb-3bb061344d1f%26mid%3D64419369-75d9-4c26-a92c-f2b1ba518bab%26bsft_mime_type%3Dhtml%26bsft_ek%3D2020-05-12T18%253A01%253A40Z&data=02%7C01%7CJing.Nghik%40microsoft.com%7C0cb47ddd20a14e0ee98308d7f6a0772c%7C72f988bf86f141af91ab2d7cd011db47%7C1%7C0%7C637249041371411854&sdata=PJeh33RcvuWx4bCl%2BEe7Fj1Ek207Ty5OhKGHxOCTDeI%3D&reserved=0"
    } 

    $DecodedURL = [System.Web.HttpUtility]::UrlDecode($decode)  
    $response.DecodedURL = $DecodedURL

    ## Parse URL String
    $foundsite = $DecodedURL -match 'url=(.*)&data'
    $response.URL = $Matches.1

    ## Parse Email String
    $foundemail= $DecodedURL -match 'data=02\|01\|([^\|]*)\|' 
    $response.email = $Matches.1

    return $response
}