#regular expression used to decode URL string into different parts
$url_parts_regex = '^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?' # See Remarks
    #Example string https://test.google.com/whatever?parameter1=test&parameter2=blah
    #Match[2] = to match scheme http:ftp. Match any character not in the set [:/?#] all the way till you see a colon ":"
    #Match[4] = to match servername
    #Match[5] = to match path
    #Match[7] = to match query string

function Invoke-DecodeURL{
    Param (
        [Parameter(Mandatory=$True)][String]$url
    )

    #Query the URL string
    if ($url -match $url_parts_regex) {
        $url_parts = @{
            'decodedURL' = [System.Web.HttpUtility]::UrlDecode($url)
            'Scheme' = $Matches[2];
            'Server' = $Matches[4];
            'Path' = $Matches[5];
            'QueryString' = $Matches[7]
            'QueryStringParts' = @{}
        }
        ## If URL has query string, break down to individual parameters
        if ( $url_parts.QueryString.Count -gt 0 ) {
            foreach ($qs in $url_parts.QueryString.Split('&')) {    ## splits string by '&' delimiter
                $qs_key, $qs_value = $qs.Split('=') ## identifies the hash key and value
                $url_parts.QueryStringParts.Add(
                    [uri]::UnescapeDataString($qs_key),
                    [uri]::UnescapeDataString($qs_value)
                ) | Out-Null
            }
        }
        return $url_parts
    } else {
        Throw [System.Management.Automation.ParameterBindingException] "Invalid URL Supplied"
    }
}