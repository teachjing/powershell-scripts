$Folder = "C:\IntuneTest\test3"

Try {
    if(!(Test-Path -Path $Folder -ErrorAction SilentlyContinue)) {
        New-Item -Path $Folder -ItemType Directory -Force -ErrorAction Stop
    }
    Write-Host "Folder already exist"

    Return $true
}
Catch {
    Return $false
}