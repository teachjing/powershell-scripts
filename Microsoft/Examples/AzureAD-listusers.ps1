#This script will query the graph API with no module dependecies and uses stricly rest API.

Import-Module .\Modules\AuthenticateGraph.ps1

#Query Graph Module using Personal Access Token (PAT) with 
$aadToken = Graph-Authenticate-PAT -authvariables $config

#Build HTTP parameters to query
$URI = "https://api.securitycenter.windows.com/api/users/admin/machines"
$headers = @{ 
    'Content-Type' = 'application/json'
    Accept = 'application/json'
    Authorization = "Bearer $aadToken" 
}

#query Graph API and insert into $graphresponse variable
$graphresponse = Invoke-WebRequest -Method Get -Uri $URI -Headers $headers -ErrorAction Stop

#Take content that is in JSON format and converts it to a format powershell can understand
$content = ConvertFrom-Json $graphresponse.Content

#show an example of one entry from the sign-in logs
$content.value | Format-Table

