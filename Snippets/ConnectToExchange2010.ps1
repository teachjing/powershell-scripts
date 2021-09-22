# Connect to the Exchange 2010 Server
. 'C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1'

Connect-ExchangeServer -auto

# Execute your commands

Get-MailBox -Identity USERNAME

<# Known Bugs
1) When using RemoteExchange.ps1 and Import-Module ActiveDirectory,
   Exchange commands are failing, if ActiveDirectory commands used previously.
   Removing the the ActiveDirectory Module don't work... Commands have to be
   executed in a separat script or runspace.
#>
