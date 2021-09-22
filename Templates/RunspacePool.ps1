###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  RunspacePool.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Template for RunspacePool to run code async
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
    .SYNOPSIS
    Template for RunspacePool to run code async 
    
    .DESCRIPTION
    
    .EXAMPLE
        
    .EXAMPLE
    
    .LINK
    https://github.com/BornToBeRoot/PowerShell
#>

[CmdletBinding()]
param(
    # Number of concurrent threads --> depens on what code you are running / which hardware you are using
	[Parameter(
		Position=0,
		HelpMessage='Maximum number of threads at the same time (Default=100)')]
	[Int32]$Threads=100
)

Begin{
    
} 

Process{       
    ### Scriptblock (this code will run asynchron in the RunspacePool)
	[System.Management.Automation.ScriptBlock]$ScriptBlock = {
		Param(
			### ScriptBlock Parameter
			$Parameter1,
			$Parameter2
		)

		#######################################
		## Enter
		## code
		## here,
		## which
		## should
		## run
		## asynchron
		#######################################
		
		### Built custom PSObject and return it
		[pscustomobject] @{
			Parameter1 = Result1
			Parameter2 = Result2
		}		
	}

    # Create RunspacePool and Jobs	
    Write-Verbose "Setting up RunspacePool..."
   
	Write-Verbose "Running with max $Threads threads"
   
    $RunspacePool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $Threads, $Host)
    $RunspacePool.Open()
    [System.Collections.ArrayList]$Jobs = @()

    Write-Verbose "Setting up Jobs..."
        
    # Setting up jobs
	for($i = $StartRange; $i -le $EndRange; $i++)
	{
		# Hashtable to pass parameters
		$ScriptParams = @{
			Parameter1 = $Parameter1
			Parameter2 = $Parameter2
		}

        # Catch when trying to divide through zero
        try {
            $Progress_Percent =  ($i / ($EndRange - $StartRange)) * 100 # Calulate some percent 
        } 
        catch { 
            $Progress_Percent = 100 
        }

        Write-Progress -Activity "Setting up jobs..." -Id 1 -Status "Current Job: $i"  -PercentComplete ($Progress_Percent)
        
        # Create mew job
        $Job = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock).AddParameters($ScriptParams)
        $Job.RunspacePool = $RunspacePool
        
        $JobObj = [pscustomobject] @{
            RunNum = $i - $StartRange
            Pipe = $Job
            Result = $Job.BeginInvoke()
        }

        # Add job to collection
        [void]$Jobs.Add($JobObj)
    }

    Write-Verbose "Waiting for jobs to complete & starting to process results..."

    # Total jobs to calculate percent complete, because jobs are removed after they are processed
    $Jobs_Total = $Jobs.Count

    # Process results, while waiting for other jobs
    Do {
        # Get all jobs, which are completed
        $Jobs_ToProcess = $Jobs | Where-Object {$_.Result.IsCompleted}

        # If no jobs finished yet, wait 500 ms and try again
        if($Jobs_ToProcess -eq $null)
        {
            Write-Verbose "No jobs completed, wait 500ms..."

            Start-Sleep -Milliseconds 500
            continue
        }
        
        # Get jobs, which are not complete yet
        $Jobs_Remaining = ($Jobs | Where-Object {$_.Result.IsCompleted -eq $false}).Count

        # Catch when trying to divide through zero
        try {            
            $Progress_Percent = 100 - (($Jobs_Remaining / $Jobs_Total) * 100) 
        }
        catch {
            $Progress_Percent = 100
        }

        Write-Progress -Activity "Waiting for jobs to complete... ($($Threads - $($RunspacePool.GetAvailableRunspaces())) of $Threads threads running)" -Id 1 -PercentComplete $Progress_Percent -Status "$Jobs_Remaining remaining..."
    
        Write-Verbose "Processing $(if($Jobs_ToProcess.Count -eq $null){"1"}else{$Jobs_ToProcess.Count}) job(s)..."

        # Processing completed jobs
        foreach($Job in $Jobs_ToProcess)
        {       
            # Get the result...     
            $Job_Result = $Job.Pipe.EndInvoke($Job.Result)
            $Job.Pipe.Dispose()

            # Remove job from collection
            $Jobs.Remove($Job)
        
            # Check if result is null --> if not, return it
            if($Job_Result -ne $null)
            {       
                $Job_Result    
            }
        } 

    } While ($Jobs.Count -gt 0)
    
    Write-Verbose "Closing RunspacePool and free resources..."

    # Close the RunspacePool and free resources
    $RunspacePool.Close()
    $RunspacePool.Dispose()
}

End{

}
