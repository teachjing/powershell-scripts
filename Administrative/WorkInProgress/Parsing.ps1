$LogFilePath = "$env:windir\setupact.log"

$LogContent = Get-Content -Path $LogFilePath |  ## This Gets the Content of the log file and pipes to for loop.
    ForEach-Object {
	    # Splits Content by each line
        $line = $_

        # split the text with ":" delimiter 
        $infos = $line -split '\t'

        # create ordered hashtable and add information into hash table 
        $hashtable = [Ordered]@{}
        $hashtable.Date = $infos[0]
        $hashtable.Next = $infos[1]

        New-Object -TypeName PSObject -Property $hashtable
    }

$LogContent | Out-GridView