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