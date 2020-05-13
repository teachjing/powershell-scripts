function Invoke-ServiceCheck {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$serviceName
    )

    if (Get-Service | Where-Object {$_.Status -contains $serviceName}) {
        $service = Get-Service | Where-Object {$_.Status -contains $serviceName}
        Write-Host "`nService Status is $($service.status)"

        if ($service.status -eq "Stopped") {
            Write-Host "Service Stopped. Starting..."
            Start-Service $serviceName
        } 
    } else {
        Throw "`nService $serviceName not found..."
    }
}
