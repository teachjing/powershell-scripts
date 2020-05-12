function Invoke-CustomModuleTest {
    Write-Host "Test from Custom Module"
}

function Get-CustomModules {
    Param (
        [Parameter(Mandatory=$true)]  [Object[]]$modules
    )
    Write-Host "`nGet-CustomModules function called to load:`n"
    Write-Host $modules.list | Format-List; Write-Host ""

    ForEach ($module in $modules.list) {
        $modulePath = Join-Path $modules.path $module
        $moduleName = [io.path]::GetFileNameWithoutExtension($modulePath)
        Import-Module $modulePath -Force #Turns on verbose and forces reload of custom module if changes are made.
    }
    #Get-Module | Where-Object {$_.Name -contains $moduleName }
    Export-ModuleMember -Function * -Alias * #Exports Modules loaded by this function
}

function Invoke-CheckModuleDependencies ( [string]$module ) {

    Write-Host "$($module) module passed to function"
    
    #Check if module is imported
    if (Get-Module -Name $module) {
        Write-Host "$($module) Module exists"
        Import-Module $module -Force
    } 
    else {
        Write-Host "Module does not exist"

        #Checks if module is installed
        Try {
            Get-InstalledModule -Name $module -ErrorAction Stop
            Write-Host "Module is installed"    
            Import-Module $module -Force
        }
        Catch {
            Install-Module $module -Force
            Write-Host "`nModule is installed"
            Import-Module $module -Force
        }
    }

}