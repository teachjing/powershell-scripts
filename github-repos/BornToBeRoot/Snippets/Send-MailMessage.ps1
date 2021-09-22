$From = ""
$To = ""
$MailServer = ""

function SendMailMessage
{
    param(
        [String]$Subject,
        [String]$Body
    )

    Send-MailMessage -SmtpServer $MailServer -From $From -To $To -Subject $Subject -Body $Body
}

# Be sure that your mail server accepts mails from the host