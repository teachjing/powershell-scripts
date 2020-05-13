# Documented blog around singing PowerShell Scripts by @wozzo - https://dev.to/wozzo/signing-powershell-scripts-5al7 
#
# Steps for certificate generation ##
# Run script and generate certificate (.pfx and .cer file will be generated)
# Add PFX certificate to any developer that will be signing the certs in cert:\CurrentUser\Root store aka "Trusted Root Certification Authorities"
# CERT certificate file is what your going to have to install on the machines that will be running the script
#   It uses public key to decrypt the signature and verify script is signed
#   Because it doesn't contain any private keys, cert can be freely distributed.
#   Install this cert in the cert:\LocalMachine\Root and cert:\LocalMachine\TrustedPublisher
#
#   Commands:
#       New-GeneratedSelfSignedCert (Generates certificate)       
#       Set-ScriptSignatures (Signs the script with the certificate)
#
#
function New-GeneratedSelfSignedCert {
    $CertificateName = Read-Host "Input your certificate name"
    $OutputPFXPath  = "$CertificateName.pfx"
    $OutputCERPath = "$CertificateName.cer"
    $Password = Get-Credential -UserName Certificate -Message "Enter a secure password:"
    
    $certificate = New-SelfSignedCertificate -subject $CertificateName -Type CodeSigning -CertStoreLocation "cert:\CurrentUser\My"
    $pfxCertificate = Export-PfxCertificate $certificate -FilePath $OutputPFXPath -password $Password.password
    Export-Certificate -Cert $certificate -FilePath $OutputCERPath
    Import-PfxCertificate $pfxCertificate -CertStoreLocation cert:\CurrentUser\Root -Password $password.password
    Write-Output "Private Certificate '$CertificateName' exported to $OutputPFXPath"
    Write-Output "Public Certificate '$CertificateName' exported to $OutputCERPath"
}

function Set-ScriptSignatures {
    param(
        [Parameter(Mandatory = $true)]
        [string]$pathToScripts,
        
        [Parameter(Mandatory = $true)]
        [string]$certificateName
    )

    $certificateName = "PowerShell Signing Certificate"
    $scripts = Get-ChildItem -Path "$pathToScripts\*" -Include *.ps1, *.psm1 -Recurse

    $certificate = @(Get-ChildItem cert:\CurrentUser\My -codesign | Where-Object { 

    $_.issuer -like "*$certificateName*" } )[0]

    foreach ($script in $scripts)
    {
        Write-Host "Signing $script"
        Set-AuthenticodeSignature $script -Certificate $certificate
    }
}