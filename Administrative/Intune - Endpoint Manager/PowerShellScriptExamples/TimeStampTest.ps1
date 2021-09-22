
Try {
    ## Create folder if doesn't exist
    $logPath = 'C:\test\TimeStampTest.log'
    if (-not (Test-Path $logPath)) {
        New-Item -ItemType File -Path $logPath -Force
    }

    ## Write timestamp to log
    Write-Output "$(Get-Date) - Same Test Command from Endpoint Manager" | Out-File -FilePath $logPath -Append

    return $true
    }
Catch {
    return $false
}