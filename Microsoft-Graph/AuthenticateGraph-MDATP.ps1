#Import authentication parameters
$configPath = Join-Path (Get-Location).path "config.json"
$configPath
$config = Get-Content $configPath | ConvertFrom-Json

Import-Module ".\AuthenticateGraph.psm1" -Force -Verbose

#Pull MDATP URL parameters to query MDATP specific resource
$authparams = $config
$authparams | Add-Member -MemberType NoteProperty -Name "signinURL" -Value $config.MDATP.signinURL
$authparams | Add-Member -MemberType NoteProperty -Name "resourceAppIdUri" -Value $config.MDATP.resourceAppIdUri

#Query Graph Module using Personal Access Token (PAT)
$aadToken = Invoke-AuthenticateGraph-PAT -authvariables $authparams

#Build HTTP parameters to query
$signin = $authparams.signinURL
$headers = @{ 
    'Content-Type' = 'application/json'
    Accept = 'application/json'
    Authorization = "Bearer $aadToken" 
}

#query Graph API and insert into $graphresponse variable
$graphresponse = Invoke-WebRequest -Method Get -Uri $signin -Headers $headers -ErrorAction Stop

#Take content that is in JSON format and converts it to a format powershell can understand
$content = ConvertFrom-Json $graphresponse.Content

#show an example of one entry from the sign-in logs
$content.value

