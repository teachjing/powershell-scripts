###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  ScheduledTask_Logging.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Template to run a script as scheduled task with logging
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

# Path to the logfile (maybe add date)
$LogPath = "$PSScriptRoot\Log.txt"

# Enable send mail (on error)
[bool]$SendMailOnError = $true

# Mail properties
$SmtpServer = ""
$MailFrom = ""
[String[]]$MailTo = @("","")
$MailSubject = "[Script Error] Title..."



# Clear the error variable
$Error.Clear()

# Specify or import credentials (if required)
$Cred = Invoke-Expression -Command "$PSScriptRoot\Get-ManagedCredential.ps1 -FilePath $PSScriptRoot\cred.xml"

# Start logging 
Start-Transcript -Path $LogPath -Append

# Execute the script (for more details use -Verbose)
Invoke-Expression -Command "$PSScriptRoot\MYSCRIPT.ps1 -Parameter1 ""Test1"" -Parameter2 ""Test2"" -Credential `$Cred -Verbose"

if($SendMailOnError -and $Error.Count -gt 0)
{
    # Send all "$Error"
    Send-MailMessage -Subject $MailSubject -Body "$($Error | Out-String)" -SmtpServer $SmtpServer -From $MailFrom -To $MailTo 
}

# End logging
Stop-Transcript