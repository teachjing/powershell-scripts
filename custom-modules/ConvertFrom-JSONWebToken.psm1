function ConvertFrom-JSONWebToken {

[cmdletbinding()]
param(
[Parameter(Mandatory = $true)]
[string]$Token,

[Alias("ih")]
[switch]$IncludeHeader
)

# Validate as per https://tools.ietf.org/html/rfc7519
# Access and ID tokens are fine, Refresh tokens will not work
if (!$Token.Contains(".") -or !$Token.StartsWith("eyJ")) { Write-Error "Invalid token" -ErrorAction Stop }

# Extract header and payload
$tokenheader, $tokenPayload = $Token.Split(".").Replace("-", "+").Replace("_", "/")[0..1]

# Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
while ($tokenheader.Length % 4) { Write-Debug "Invalid length for a Base-64 char array or string, adding ="; $tokenheader += "=" }
while ($tokenPayload.Length % 4) { Write-Debug "Invalid length for a Base-64 char array or string, adding ="; $tokenPayload += "=" }

Write-Debug "Base64 encoded (padded) header:`n$tokenheader"
Write-Debug "Base64 encoded (padded) payoad:`n$tokenPayload"

# Convert header from Base64 encoded string to PSObject all at once
$header = [System.Text.Encoding]::ASCII.GetString([system.convert]::FromBase64String($tokenheader)) | ConvertFrom-Json
Write-Debug "Decoded header:`n$header"

# Convert payload to string array
$tokenArray = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($tokenPayload))
Write-Debug "Decoded array in JSON format:`n$tokenArray"

# Convert from JSON to PSObject
$tokobj = $tokenArray | ConvertFrom-Json
Write-Debug "Decoded Payload:"

if($IncludeHeader) {$header}
return $tokobj
}
