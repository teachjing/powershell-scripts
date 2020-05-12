#Authenticates to Graph API using a Personal Access Token (PAT)
function Invoke-AuthenticateGraph-PAT ( $authvariables ) {

    $oAuthUri = "https://login.windows.net/$($authvariables.tenantId)/oauth2/token"

    $authBody = [Ordered] @{
        resource = "$($authvariables.resourceAppIdUri)"
        client_id = "$($authvariables.appId)"
        client_secret = "$($authvariables.appSecret)"
        grant_type = 'client_credentials'
    }

    $authResponse = Invoke-RestMethod -Method Post -Uri $oAuthUri -Body $authBody -ErrorAction Stop
    $aadToken = $authResponse.access_token

    return $aadToken

}

