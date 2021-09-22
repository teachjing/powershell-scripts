$Server = '10.60.0.67'

$Severity = '1' #0=EMERG 1=Alert 2=CRIT 3=ERR 4=WARNING 5=NOTICE  6=INFO  7=DEBUG
$Facility = '22' #(16-23)=LOCAL0-LOCAL7

$Hostname= 'Test-DC01'
$Message = 'This is a test powershell message'

# Create a UDP Client Object
$UDPCLient = New-Object System.Net.Sockets.UdpClient
$UDPCLient.Connect($Server, 514)

# Calculate the priority
$Priority = ([int]$Facility + [int]$Severity)

#Time format the SW syslog understands
$Timestamp = Get-Date -Format "MMM dd HH:mm:ss"

# Assemble the full syslog formatted message
$FullSyslogMessage = "<{0}>{1} {2} {3}" -f $Priority, $Timestamp, $Hostname, $Message

# create an ASCII Encoding object
$Encoding = [System.Text.Encoding]::ASCII

# Convert into byte array representation
$ByteSyslogMessage = $Encoding.GetBytes($FullSyslogMessage)

# Send the Message
$UDPCLient.Send($ByteSyslogMessage, $ByteSyslogMessage.Length)

$ByteSyslogMessage