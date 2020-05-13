#  System Helper IT
# A collection of useful Powershell scripts housed in a small GUI


# Global variable declaration
$ErrorActionPreference = SilentlyContinue
$wshell = New-Object -comObject Wscript.Shell
$dateTime = Get-Date 
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')


#Launches the session as the current user + Administrator rights
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

if ($myWindowsPrincipal.IsInRole($adminRole))
{ }
else {
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;

    $newProcess.Verb = "runas";
    $newProcess.WindowStyle = "Hidden";
    [System.Diagnostics.Process]::Start($newProcess);
    exit
}



# Verify Tool is launched with an S- Account

#Verify Log File exists and, if not, creates one.\
function logAction ($action) {
    $userPath = [Environment]::GetFolderPath("User") + "\Dyna IT Tool Log.txt"
    Add-Content "$userPath" "$dateTime | $env:UserName | $env:ComputerName | $action"
}

If (Test-Path "C:\users\$env:UserName") { }
Else { New-Item "C:\users\$env:UserName" }

If (Test-Path "C:\users\$env:UserName\Dyna IT Tool Log.txt") {
    logAction "Logged into IT System Helper Tool"
}
else {
    New-Item "C:\users\$env:UserName\Dyna IT Tool Log.txt"
    Add-Content "C:\users\$env:UserName\Dyna IT Tool Log.txt" "Log file has been created"
    Add-Content "C:\users\$env:UserName\Dyna IT Tool Log.txt" "$dateTime | $env:UserName | $env:ComputerName | $action"
}


# Tools
#Auto Logon Update Tool

function localAdminCleanupTool {
    
    Add-Type -AssemblyName System.Windows.Forms
    $wshell = New-Object -comObject Wscript.Shell
    [System.Windows.Forms.Application]::EnableVisualStyles()
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

    # Activity Log (Saves to user's Desktop)
    $logLocation = [Environment]::GetFolderPath("Desktop") + "\Local Admin Cleanup Log.txt"
    function logAction ($action) {
        $dateTime = Get-Date
        Add-Content "$logLocation" "$dateTime | $action"
    }
    # Imports line items from a .txt document list.
    function importList {
        logAction "Importing item list from text document."
        $initialDirectory = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.initialDirectory = $initialDirectory
        $OpenFileDialog.filter = "All files (*.*)| *.*"
        $OpenFileDialog.ShowDialog() | Out-Null
        $selectedFile = $OpenFileDialog.filename
        $computerList = Get-Content $selectedFile
        foreach ($computer in $computerList) {
            $itemList.Items.Add($computer)
            logAction "$computer was added to the item list. (Imported from file)"
        }
        
    }

    # Adds single user input item to item list.
    function addList {

        $computerName = [Microsoft.VisualBasic.Interaction]::InputBox('Enter a Host/User', 'Add Item')
        $itemList.Items.Add($computerName)
        logAction "$computerName was added to the item list. (Added manually)"
    }

    # Removes the currently selected item from the item list.
    function removeList {
        $computerName = $itemList.SelectedItem
        logAction "$computerName was removed from the item list."
        $index = $itemList.SelectedIndex
        $itemList.Items.RemoveAt($index)

    }
    # Clears all items from the list.
    function clearList {
        logAction "All items cleared from list."
        $itemList.Items.Clear()
    }
    function setFilePath {
        $initialDirectory = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.initialDirectory = $initialDirectory
        $OpenFileDialog.filter = "All files (*.*)| *.*"
        $OpenFileDialog.ShowDialog() | Out-Null
        $filePath = $OpenFileDialog.filename
        $filePathBox.text = $filePath
    }
    # Activates the main function of the tool, targeting each item on the item list.
    function activateTool {
        logAction "Local Admin Cleanup started."
        $msgBoxInput = $wshell.Popup("Are you sure you want to proceed?", 0, "Confirm", 0x1)
        switch ($msgBoxInput) {
            '1' { 
                logAction "User confirmed process execution."
              
                # Counters for progress bar calculation 
                $ctr = 0 
                foreach ($item in $itemList.items) { $ctr++ }
                $x = 100 / $ctr 
                $y = 0 

                # Loop to perform action on each item in the list.    
                foreach ($item in $itemList.items) {
                    $statusText.text = "Pinging $item"
                    try {
                        If (Test-Connection -ComputerName $item -quiet) {
                            logAction "$item ONLINE"
                            logAction "Attempting to remove users from $item.."
                            $statusText.text = "Assessing $item Local Admins"
                            $LocalAdminUsers = Invoke-Command -computer $item -scriptblock { Get-LocalGroupMember -group "Administrators" }
                            foreach ($user in $LocalAdminUsers) {
                                $userName = $user.Name
                                if (($userName -notlike '*zzCompanyAdmin*') -and ($userName -notlike '*Domain Admins*') -and ($userName -notlike '*SG-DYN*-DivAdmins*') -and ($userName -notlike '*SG-DYN*-SiteAdmins*') -and ($userName -notlike '*SL-DYN*-WksAdmins*') -and ($userName -notlike '*SL-DYN*-DivAdmins*') -and ($userName -notlike '*SL-DYN*-SiteAdmins*') -and ($userName -notlike '*SG-DYN*-WksAdmins*') -and ($userName -notlike '*SL-Company-GlobalDesktopAdmin*') -and ($userName -notlike '*SU-DIVSITE-LAP*')) { 
                                    $statusText.text = "Removing $userName"
                                    try {
                                        Invoke-Command -computer $item -ArgumentList $userName -scriptblock { param($userName)
                                            Remove-LocalGroupMember -group "Administrators" -Member $userName }

                                        logAction "$user removed from Local Administrators."
                                    }
                                    catch { "Error removing $userName | $_.Exception.Message" }
                                }
                            }
                       
                        }
                        Else { logAction "$item OFFLINE" }
                    
                    }
                    catch {
                        logAction "$item | $_.Exception.Message"
                    }
                    $ProgressBar.Value = $y + $x
                    $y = $y + $x
                }
   
                # Operation Completed finishing actions.
                $statusText.text = "Operation Complete"
                logAction "Operation has completed."
                Invoke-Item $logLocation
                Start-Sleep -Seconds 1
                $wshell.Popup("Local Admin Cleanup has finished running.", 0, "Local Admin Cleanup Tool")
                $statusText.text = ""
                $ProgressBar.Value = 0

            }
            '2' {
                logAction "User aborted the operation. (Confirmation declined)"
            }
        }
    }


    ################## GUI Form Elements

    $Form = New-Object system.Windows.Forms.Form
    $Form.ClientSize = '400,300' #Width,Height
    $Form.text = "Local Admin Cleanup"
    $Form.FormBorderStyle = 'Fixed3D'
    $Form.MaximizeBox = $false
    $Form.TopMost = $false

    # Generates the application icon
    [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.drawline([System.Drawing.Pens]::Red, 4, 7, 4, 15)
    $g.drawline([System.Drawing.Pens]::Red, 5, 7, 5, 14)
    $g.drawline([System.Drawing.Pens]::Red, 10, 4, 10, 15)
    $g.drawline([System.Drawing.Pens]::Red, 11, 3, 11, 14)
    $g.drawline([System.Drawing.Pens]::Red, 0, 4, 14, 4)
    $g.drawline([System.Drawing.Pens]::Red, 1, 3, 15, 3)
    $ico = [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
    $Form.Icon = $ico

    $itemList = New-Object system.Windows.Forms.ListBox
    $itemList.width = 380
    $itemList.height = 190
    $itemList.location = New-Object System.Drawing.Point(10, 10)
    $Form.Controls.Add($itemList)

    $buttonAdd = New-Object system.Windows.Forms.Button
    $buttonAdd.Text = "Add.."     
    $buttonAdd.width = 70
    $buttonAdd.height = 24
    $buttonAdd.location = New-Object System.Drawing.Point(10, 200)
    $buttonAdd.Font = 'Microsoft Sans Serif,10'
    $buttonAdd.Add_Click( { addList })
    $Form.Controls.Add($buttonAdd)

    $buttonRemove = New-Object system.Windows.Forms.Button
    $buttonRemove.Text = "Remove"     
    $buttonRemove.width = 90
    $buttonRemove.height = 24
    $buttonRemove.location = New-Object System.Drawing.Point(85, 200)
    $buttonRemove.Font = 'Microsoft Sans Serif,10'
    $buttonRemove.Add_Click( { removeList })
    $Form.Controls.Add($buttonRemove)

    $buttonClear = New-Object system.Windows.Forms.Button
    $buttonClear.Text = "Clear All"     
    $buttonClear.width = 100
    $buttonClear.height = 24
    $buttonClear.location = New-Object System.Drawing.Point(180, 200)
    $buttonClear.Font = 'Microsoft Sans Serif,10'
    $buttonClear.Add_Click( { clearList })
    $Form.Controls.Add($buttonClear)

    $buttonImport = New-Object system.Windows.Forms.Button
    $buttonImport.Text = "Import List.."     
    $buttonImport.width = 105
    $buttonImport.height = 24
    $buttonImport.location = New-Object System.Drawing.Point(285, 200)
    $buttonImport.Font = 'Microsoft Sans Serif,10'
    $buttonImport.Add_Click( { importList })
    $Form.Controls.Add($buttonImport)

    $ProgressBar = New-Object system.Windows.Forms.ProgressBar
    $ProgressBar.width = 380
    $ProgressBar.height = 17
    $ProgressBar.location = New-Object System.Drawing.Point(10, 230)
    $Form.Controls.Add($ProgressBar)

    $statusText = New-Object system.Windows.Forms.Label
    $statusText.text = ""
    $statusText.AutoSize = $true
    $statusText.width = 25
    $statusText.height = 10
    $statusText.ForeColor = "Red"
    $statusText.location = New-Object System.Drawing.Point(50, 250)
    $statusText.Font = 'Microsoft Sans Serif,10'
    $Form.Controls.Add($statusText)

    $buttonGo = New-Object system.Windows.Forms.Button
    $buttonGo.Text = "Go"     
    $buttonGo.width = 60
    $buttonGo.height = 24
    $buttonGo.location = New-Object System.Drawing.Point(170, 270)
    $buttonGo.Font = 'Microsoft Sans Serif,10'
    $buttonGo.Add_Click( { activateTool })
    $Form.Controls.Add($buttonGo)
    [void]$Form.ShowDialog()


}
function autoLogonTool {
    #
    # AutoLogon Update Tool
    # Description: Uses the Sysinternals tool AutoLogon.exe to update automatic login credentials. This will store the password in an encrypted registry string.
    # Created by Matt Pistole | Company, Algona
    #
    # Updated 02/25/2019


    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
    $wshell = New-Object -comObject Wscript.Shell
    $logLocation = [Environment]::GetFolderPath("Desktop") + "\Autologon Update Tool Log.txt"
    #Functions

    # Logs any actions performed as well as failure/success/error message to txt document (saved to current running user's user folder).
    function logAction ($action) {
        $dateTime = Get-Date
        Add-Content "$logLocation" "$dateTime | $action"
    }
    # Imports user supplied txt document to the item list.
    function importList {
        logAction "Importing item list from text document."
        $initialDirectory = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.initialDirectory = $initialDirectory
        $OpenFileDialog.filter = "All files (*.*)| *.*"
        $OpenFileDialog.ShowDialog() | Out-Null
        $selectedFile = $OpenFileDialog.filename
        $computerList = Get-Content $selectedFile
        foreach ($computer in $computerList) {
            $itemList.Items.Add($computer)
            logAction "$computer was added to the item list. (Imported from file)"
        }
        
    }

    # Adds single user input item to item list.
    function addList {

        $computerName = [Microsoft.VisualBasic.Interaction]::InputBox('Enter a Host/User', 'Add Item')
        $itemList.Items.Add($computerName)
        logAction "$computerName was added to the item list. (Added manually)"
    }

    # Removes the currently selected item from the item list.
    function removeList {
        $computerName = $itemList.SelectedItem
        logAction "$computerName was removed from the item list."
        $index = $itemList.SelectedIndex
        $itemList.Items.RemoveAt($index)

    }

    function clearList {
        logAction "All items cleared from list."
        $itemList.Items.Clear()
    }
    function setFilePath {
        $initialDirectory = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.initialDirectory = $initialDirectory
        $OpenFileDialog.filter = "All files (*.*)| *.*"
        $OpenFileDialog.ShowDialog() | Out-Null
        $filePath = $OpenFileDialog.filename
        $filePathBox.text = $filePath
    }
    # Activates the main function of the tool, targeting each item on the item list.
    function activateTool {
        logAction "AutoLogon update process started."
        $msgBoxInput = $wshell.Popup("Are you sure you want to proceed?", 0, "Confirm", 0x1)
        switch ($msgBoxInput) {
            '1' { 
                logAction "User confirmed update process execution."
          
                $newPassword = $passwordTextBox.text   
                $confirmPassword = [Microsoft.VisualBasic.Interaction]::InputBox("Enter Password Again:", "Confirm Password")
                If ($newPassword -eq $confirmPassword) {
                    logAction "User successfully confirmed password."
                }
                Else {
                    logAction "User failed to confirm password."
                    $wshell.Popup("Passwords do not match.", 0, "AutoLogon Update Tool")

                    Return
                }    
    
    
                $ctr = 0 #Progress bar counter
                foreach ($item in $itemList.items) { $ctr++ }
                $x = 100 / $ctr #Represents what portion of entire operation each item is
                $y = 0 #Used to define current progress bar status percentage

                $exeFilePath = $filePathBox.text 
                foreach ($item in $itemList.items) {

                    $Label1.text = "Verifying AD user $item.."

                    If (dsquery.exe user -samid $item) {
                        logAction "User $item located successfully."
                        $Label1.text = "Pinging $item.."
                        If (Test-Connection $item -Quiet) {
                            $Label1.text = "Ping Success"
                            logAction "Successfully pinged $item"

                            #Copy the AutoLogon.exe application to the local computer.
                            Try {
                                $Label1.text = "Copying AutoLogon.exe to local computer.."
                                Copy-Item "$exeFilePath" -Destination "\\$item\c$\users\$item\"
                                logAction "AutoLogon.exe successfully copied to $item."
                            }
                            Catch {
                                $Label1.text = "Failed to copy AutoLogon.exe to local computer"
                                logAction "Failed to copy AutoLogon.exe to $item. $_.Exception.Message"
                            }
            

                            Try { 
                                $Label1.text = "Running AutoLogon.exe on $item"
                                Invoke-Command -computername $item -scriptblock { & cmd.exe /c "C:\users\$Using:item\Autologon.exe $Using:item DOMAINNAME $Using:newPassword /accepteula" }
                                logAction "Successfully updated the AutoLogon information of $item."

                                $Hive = [Microsoft.Win32.RegistryHive]"LocalMachine";
                                $regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $item);
                                $logonKey = $regKey.OpenSubKey("SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon");
                                $keyCheck = $logonKey.GetValue('DefaultPassword')
                                if (!$keyCheck) { logAction "DefaultPassword key not found in $item registry." }
                                else { logAction "WARNING: DefaultPassword key still exists in $item registry." }
    
                            }
                            Catch {
                                $Label1.text = "Failed to run AutoLogon.exe on $item"
                                logAction "Failed to update the AutoLogon informationof $item. $_.Exception.Message"
                            }
                        }

                        Else {
                            $Label1.text = "Ping failed"
                            logAction "Unable to reach host $item."
                        }
                    }
                    Else { logAction "User $item not found." }

                    $ProgressBar.Value = $y + $x
                    $y = $y + $x

                }

                #Open the log file after completion (If selected)
                $Label1.text = "Operation Complete"
                logAction "Operation has completed."
                Invoke-Item $logLocation
                Start-Sleep -Seconds 1
                $wshell.Popup("AutoLogon Update has finished running.", 0, "AutoLogon Update Tool")
                $Label1.text = ""
                $ProgressBar.Value = 0

            }
            '2' {
                logAction "User aborted the operation. (Confirmation declined)"
            }
        }
        If ($CheckBox4.Checked) { Invoke-Item -Path "$logLocation" }
    }

    # GUI Elements

    $Form = New-Object system.Windows.Forms.Form
    $Form.ClientSize = '400,360'
    $Form.text = "Auto Logon Update Tool"
    $Form.TopMost = $false

    $itemList = New-Object system.Windows.Forms.ListBox
    $itemList.width = 380
    $itemList.height = 190
    $itemList.location = New-Object System.Drawing.Point(10, 10)
    $Form.Controls.Add($itemList)
    $itemList.add_selectedindexchanged( { getGroupMembers })
    $Form.controls.Add

    $buttonAdd = New-Object system.Windows.Forms.Button
    $buttonAdd.Text = "Add.."     
    $buttonAdd.width = 70
    $buttonAdd.height = 24
    $buttonAdd.location = New-Object System.Drawing.Point(10, 200)
    $buttonAdd.Font = 'Microsoft Sans Serif,10'
    $buttonAdd.Add_Click( { addList })
    $Form.Controls.Add($buttonAdd)

    $buttonRemove = New-Object system.Windows.Forms.Button
    $buttonRemove.Text = "Remove"     
    $buttonRemove.width = 90
    $buttonRemove.height = 24
    $buttonRemove.location = New-Object System.Drawing.Point(85, 200)
    $buttonRemove.Font = 'Microsoft Sans Serif,10'
    $buttonRemove.Add_Click( { removeList })
    $Form.Controls.Add($buttonRemove)

    $buttonClear = New-Object system.Windows.Forms.Button
    $buttonClear.Text = "Clear All"     
    $buttonClear.width = 100
    $buttonClear.height = 24
    $buttonClear.location = New-Object System.Drawing.Point(180, 200)
    $buttonClear.Font = 'Microsoft Sans Serif,10'
    $buttonClear.Add_Click( { clearList })
    $Form.Controls.Add($buttonClear)


    $buttonImport = New-Object system.Windows.Forms.Button
    $buttonImport.Text = "Import List.."     
    $buttonImport.width = 105
    $buttonImport.height = 24
    $buttonImport.location = New-Object System.Drawing.Point(285, 200)
    $buttonImport.Font = 'Microsoft Sans Serif,10'
    $buttonImport.Add_Click( { importList })
    $Form.Controls.Add($buttonImport)

    $filePathButton = New-Object system.Windows.Forms.Button
    $filePathButton.Text = "Autologon.exe Path"     
    $filePathButton.width = 135
    $filePathButton.height = 24
    $filePathButton.location = New-Object System.Drawing.Point(10, 230)
    $filePathButton.Font = 'Microsoft Sans Serif,10'
    $filePathButton.Add_Click( { setFilePath })
    $Form.Controls.Add($filePathButton)

    $filePathBox = New-Object System.Windows.Forms.TextBox
    $filePathBox.multiline = $false
    $filePathBox.text = ""
    $filePathBox.width = 230
    $filePathBox.height = 20
    $filePathBox.location = New-Object System.Drawing.Point(160, 230)
    $filePathBox.Font = 'Microsoft Sans Serif,10'
    $Form.Controls.Add($filePathBox)

    $Label0 = New-Object system.Windows.Forms.Label
    $Label0.text = "Password:"
    $Label0.AutoSize = $true
    $Label0.width = 25
    $Label0.height = 10
    $Label0.location = New-Object System.Drawing.Point(10, 255)
    $Label0.Font = 'Microsoft Sans Serif,12'
    $Form.Controls.Add($Label0)

    $passwordTextBox = New-Object System.Windows.Forms.TextBox
    $passwordTextBox.multiline = $false
    $passwordTextBox.text = ""
    $passwordTextBox.width = 230
    $passwordTextBox.height = 20
    $passwordTextBox.location = New-Object System.Drawing.Point(160, 255)
    $passwordTextBox.Font = 'Microsoft Sans Serif,10'
    $Form.Controls.Add($passwordTextBox)


    $ProgressBar = New-Object system.Windows.Forms.ProgressBar
    $ProgressBar.width = 380
    $ProgressBar.height = 17
    $ProgressBar.location = New-Object System.Drawing.Point(10, 290)
    $Form.Controls.Add($ProgressBar)

    $Label1 = New-Object system.Windows.Forms.Label
    $Label1.text = ""
    $Label1.AutoSize = $true
    $Label1.width = 25
    $Label1.height = 10
    $label1.ForeColor = "Red"
    $Label1.location = New-Object System.Drawing.Point(50, 310)
    $Label1.Font = 'Microsoft Sans Serif,10'
    $Form.Controls.Add($Label1)

    $buttonGo = New-Object system.Windows.Forms.Button
    $buttonGo.Text = "Go"     
    $buttonGo.width = 60
    $buttonGo.height = 24
    $buttonGo.location = New-Object System.Drawing.Point(170, 330)
    $buttonGo.Font = 'Microsoft Sans Serif,10'
    $buttonGo.Add_Click( { activateTool })
    $Form.Controls.Add($buttonGo)


    [void]$Form.ShowDialog()


}
#User Migration Tool - Decrypts and copies user data from location to destination
function userMigrationTool {
    logAction "Migration tool loaded"
    function listUsers {
        $computerName = $TextBox1.Text
        $userFolders = Get-ChildItem -path c:\users | Select-Object Name
        [array]$userFolders = Get-ChildItem -path \\$computerName\c$\Users | Select-Object Name
        ForEach ($Item in $userFolders) { $ListBox1.Items.Add($Item.Name) }
    }
 
    function copyFiles {
        logAction "File copy initiated."
        $sourceComputerName = $TextBox1.Text
        $targetComputerName = $TextBox2.Text
        $selectedUser = $ListBox1.SelectedItem
        $ProgressBar1.Value = "5"
        $zipFileLocation = $TextBox2.Text
        $dateStamp = Get-Date -Format g | ForEach-Object { $_ -replace ":", "." } | ForEach-Object { $_ -replace "/", "." }
        Function add-filezip {
            Param(
                [string]$ZIPFileName,
                [string]$NewFileToAdd
            )
             
            try {
                [Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null
                $zip = [System.IO.Compression.ZipFile]::Open($ZIPFileName, "Update")
                $FileName = [System.IO.Path]::GetFileName($NewFileToAdd)
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $NewFileToAdd, $FileName, "Optimal") | Out-Null
                $Zip.Dispose()
                $wshell.Popup("Successfully added $NewFileToAdd to $ZIPFileName", 0, "Success")
            }
            catch {
                $wshell.Popup("Failed to add $NewFileToAdd to $ZIPFileName . Details : $_", 0, "Error")
            }
        }

        If ($RadioButton1.Checked) {
            
            If (Test-Connection $sourceComputerName -Quiet) {
                $ProgressBar1.Value = "15"
         
                $ProgressBar1.Value = "25"
                If ($CheckBox1.Checked) {
                    add-filezip -ZIPfilename "$zipFileLocation\$selectedUser $dateStamp.zip" -NewFileToAdd "\\$sourceComputerName\c$\users\$selectedUser\Desktop" -Recurse -Force
                    $ProgressBar1.Value = "40"
                }
                If ($CheckBox2.Checked) {
                    add-filezip -ZIPfilename "$zipFileLocation\$selectedUser $dateStamp.zip" -NewFileToAdd "\\$sourceComputerName\c$\users\$selectedUser\Documents" -Recurse -Force
                    $ProgressBar1.Value = "55"
                }
                If ($CheckBox3.Checked) {
                    add-filezip -ZIPfilename "$zipFileLocation\$selectedUser $dateStamp.zip" -NewFileToAdd "\\$sourceComputerName\c$\users\$selectedUser\Downloads" -Recurse -Force
                    $ProgressBar1.Value = "70"
                }
                If ($CheckBox4.Checked) {
                    add-filezip -ZIPfilename "$zipFileLocation\$selectedUser $dateStamp.zip" -NewFileToAdd "\\$sourceComputerName\c$\users\$selectedUser\Favorites" -Recurse -Force
                    $ProgressBar1.Value = "85"
                }
                If ($CheckBox5.Checked) {
                    add-filezip -ZIPfilename "$zipFileLocation\$selectedUser $dateStamp.zip" -NewFileToAdd "\\$sourceComputerName\c$\users\$selectedUser\Pictures" -Recurse -Force
                    $ProgressBar1.Value = "95"
                }
                $wshell.Popup("Files have been zipped successfully.", 0, "Complete")
                $ProgressBar1.Value = "100"
            }
  
            Else { $wshell.Popup("Unable to reach source computer.", 0, "Error") }
        }

        If ($RadioButton2.Checked) {
            If (Test-Connection $sourceComputerName -Quiet) {
                $ProgressBar1.Value = "15"
                If (Test-Connection $targetComputerName -Quiet) {
                    $ProgressBar1.Value = "25"
                    If ($CheckBox1.Checked) {
                        Copy-Item "\\$sourceComputerName\c$\users\$selectedUser\Desktop" -Destination "\\$targetComputerName\c$\users\$selectedUser" -Recurse -Force
                        $ProgressBar1.Value = "40"
                    }
                    If ($CheckBox2.Checked) {
                        Copy-Item "\\$sourceComputerName\c$\users\$selectedUser\Documents" -Destination "\\$targetComputerName\c$\users\$selectedUser" -Recurse -Force
                        $ProgressBar1.Value = "55"
                    }
                    If ($CheckBox3.Checked) {
                        Copy-Item "\\$sourceComputerName\c$\users\$selectedUser\Downloads" -Destination "\\$targetComputerName\c$\users\$selectedUser" -Recurse -Force
                        $ProgressBar1.Value = "70"
                    }
                    If ($CheckBox4.Checked) {
                        Copy-Item "\\$sourceComputerName\c$\users\$selectedUser\Favorites" -Destination "\\$targetComputerName\c$\users\$selectedUser" -Recurse -Force
                        $ProgressBar1.Value = "85"
                    }
                    If ($CheckBox5.Checked) {
                        Copy-Item "\\$sourceComputerName\c$\users\$selectedUser\Pictures" -Destination "\\$targetComputerName\c$\users\$selectedUser" -Recurse -Force
                        $ProgressBar1.Value = "95"
                    }
                    $wshell.Popup("Files have been copied successfully.", 0, "Complete")
                    $ProgressBar1.Value = "100"
                }
            }
            Else { $wshell.Popup("Unable to reach target computer.", 0, "Error") }
            Else { $wshell.Popup("Unable to reach source computer.", 0, "Error") }
        }
 
        $ProgressBar1.Value = "0"
    }

    $Form = New-Object system.Windows.Forms.Form
    $Form.ClientSize = '458,446'
    $Form.text = "User Migration Tool"
    $Form.TopMost = $false

    $CheckBox1 = New-Object system.Windows.Forms.CheckBox
    $CheckBox1.text = "Desktop"
    $CheckBox1.AutoSize = $false
    $CheckBox1.width = 95
    $CheckBox1.height = 20
    $CheckBox1.location = New-Object System.Drawing.Point(118, 243)
    $CheckBox1.Font = 'Microsoft Sans Serif,10'

    $CheckBox2 = New-Object system.Windows.Forms.CheckBox
    $CheckBox2.text = "Documents"
    $CheckBox2.AutoSize = $false
    $CheckBox2.width = 95
    $CheckBox2.height = 20
    $CheckBox2.location = New-Object System.Drawing.Point(118, 262)
    $CheckBox2.Font = 'Microsoft Sans Serif,10'

    $CheckBox3 = New-Object system.Windows.Forms.CheckBox
    $CheckBox3.text = "Downloads"
    $CheckBox3.AutoSize = $false
    $CheckBox3.width = 95
    $CheckBox3.height = 20
    $CheckBox3.location = New-Object System.Drawing.Point(118, 281)
    $CheckBox3.Font = 'Microsoft Sans Serif,10'

    $CheckBox4 = New-Object system.Windows.Forms.CheckBox
    $CheckBox4.text = "Favorites"
    $CheckBox4.AutoSize = $false
    $CheckBox4.width = 95
    $CheckBox4.height = 20
    $CheckBox4.location = New-Object System.Drawing.Point(118, 301)
    $CheckBox4.Font = 'Microsoft Sans Serif,10'

    $ProgressBar1 = New-Object system.Windows.Forms.ProgressBar
    $ProgressBar1.width = 435
    $ProgressBar1.height = 17
    $ProgressBar1.location = New-Object System.Drawing.Point(11, 356)

    $CheckBox5 = New-Object system.Windows.Forms.CheckBox
    $CheckBox5.text = "Pictures"
    $CheckBox5.AutoSize = $false
    $CheckBox5.width = 95
    $CheckBox5.height = 20
    $CheckBox5.location = New-Object System.Drawing.Point(118, 320)
    $CheckBox5.Font = 'Microsoft Sans Serif,10'

    $TextBox1 = New-Object system.Windows.Forms.TextBox
    $TextBox1.multiline = $false
    $TextBox1.width = 200
    $TextBox1.height = 20
    $TextBox1.location = New-Object System.Drawing.Point(116, 42)
    $TextBox1.Font = 'Microsoft Sans Serif,10'
    $TextBox1.Text = "$env:computername"

    $Button1 = New-Object system.Windows.Forms.Button
    $Button1.text = "Select"
    $Button1.width = 53
    $Button1.height = 25
    $Button1.location = New-Object System.Drawing.Point(319, 41)
    $Button1.Font = 'Microsoft Sans Serif,10'
    $Button1.Add_Click( { listUsers })

    $Label1 = New-Object system.Windows.Forms.Label
    $Label1.text = "Source PC:"
    $Label1.AutoSize = $true
    $Label1.width = 25
    $Label1.height = 10
    $Label1.location = New-Object System.Drawing.Point(42, 46)
    $Label1.Font = 'Microsoft Sans Serif,10'

    $TextBox2 = New-Object system.Windows.Forms.TextBox
    $TextBox2.multiline = $false
    $TextBox2.width = 255
    $TextBox2.height = 20
    $TextBox2.location = New-Object System.Drawing.Point(116, 68)
    $TextBox2.Font = 'Microsoft Sans Serif,10'

    $Label2 = New-Object system.Windows.Forms.Label
    $Label2.text = "Destination PC:"
    $Label2.AutoSize = $true
    $Label2.width = 25
    $Label2.height = 10
    $Label2.location = New-Object System.Drawing.Point(18, 72)
    $Label2.Font = 'Microsoft Sans Serif,10'

    $RadioButton1 = New-Object system.Windows.Forms.RadioButton
    $RadioButton1.text = "Store as ZIP"
    $RadioButton1.AutoSize = $true
    $RadioButton1.width = 104
    $RadioButton1.height = 20
    $RadioButton1.location = New-Object System.Drawing.Point(114, 93)
    $RadioButton1.Font = 'Microsoft Sans Serif,10'

    $RadioButton2 = New-Object system.Windows.Forms.RadioButton
    $RadioButton2.text = "Migrate Directly to User Folder"
    $RadioButton2.AutoSize = $true
    $RadioButton2.width = 104
    $RadioButton2.height = 20
    $RadioButton2.location = New-Object System.Drawing.Point(215, 93)
    $RadioButton2.Font = 'Microsoft Sans Serif,10'

    $ListBox1 = New-Object system.Windows.Forms.ListBox
    $ListBox1.text = "listBox"
    $ListBox1.width = 257
    $ListBox1.height = 82
    $ListBox1.location = New-Object System.Drawing.Point(115, 142)

    $Label3 = New-Object system.Windows.Forms.Label
    $Label3.text = "Select User"
    $Label3.AutoSize = $true
    $Label3.width = 25
    $Label3.height = 10
    $Label3.location = New-Object System.Drawing.Point(114, 125)
    $Label3.Font = 'Microsoft Sans Serif,10'

    $Button2 = New-Object system.Windows.Forms.Button
    $Button2.text = "Go"
    $Button2.width = 60
    $Button2.height = 30
    $Button2.location = New-Object System.Drawing.Point(213, 392)
    $Button2.Font = 'Microsoft Sans Serif,10'
    $Button2.Add_Click( { copyFiles })


    $Label4 = New-Object system.Windows.Forms.Label
    $Label4.text = "Folders to Copy:"
    $Label4.AutoSize = $true
    $Label4.width = 25
    $Label4.height = 10
    $Label4.location = New-Object System.Drawing.Point(13, 243)
    $Label4.Font = 'Microsoft Sans Serif,10'

    $Form.controls.AddRange(@($CheckBox1, $CheckBox2, $CheckBox3, $CheckBox4, $ProgressBar1, $CheckBox5, $TextBox1, $Button1, $Label1, $TextBox2, $Label2, $RadioButton1, $RadioButton2, $ListBox1, $Label3, $Button2, $Label4))

    [void]$Form.ShowDialog()
}

#Local Admin Tool

function LocalAdminTool {
    function addLocalAdmin {
        $Computer = $TextBox1.Text
        $Domain = $TextBox2.Text
        $User = $TextBox3.Text
        $DaysToRemoveAfter = $TextBox4.Text

        # Variable to flag access to expire or not
        if ($CheckBox1.Checked) { $Expire = $true } else { $Expire = $false }
   
        # Create full user name i.e. Company-na\joe.smith

        $DomainUser = $Domain + "\" + $User
    
        # Create task description in the scheduled task tool.
    
        $Description = "RemoveAdmin " + $DomainUser + " on " + $RemovalDate
    
        # Name of the task
    
        $TaskName = "Remove Temp Admin" + " " + $user
    
        # Parameters for the task to remove the user.
    
        $Argument = "-NoProfile -command &{Remove-LocalGroupMember -Group Administrators -Member `"$DomainUser`" ; Unregister-ScheduledTask -TaskName `"$TaskName`" -Confirm:`$false}"
    
        # Used to create a sub folder in the task scheduler
    
        $TaskPath = "Remove Temp Admin"
    
        # Date to remove the user
    
        $RemovalDate = (Get-Date).AddDays($DaysToRemoveAfter)
    
        # Account to run the task under
    
        $RunUser = "NT AUTHORITY\SYSTEM"
    
        # ------------------------------------------------------------ #
    
        # Check if PC is online and launch the commands remotely.
    
        If (Test-Connection -ComputerName $Computer -Quiet) {
            Invoke-Command -ComputerName $Computer -ScriptBlock {
                Param ($Argument, $RemovalDate, $TaskName, $Expire, $TaskPath, $Description, $RunUser, $DomainUser)
                Import-Module Microsoft.PowerShell.LocalAccounts
    
                # Give them admin rights
    
                Add-LocalGroupMember -Group "Administrators" -Member $DomainUser -ErrorAction SilentlyContinue
    
                # Create the task to remove admin rights
    
                $Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument $Argument
    
                # Set the trigger to remove the task 
    
                $Trigger = New-ScheduledTaskTrigger -Once -At $RemovalDate
    
                # If the task already exists, try to remove it so it can be replaced.
    
                Unregister-ScheduledTask $TaskName -Confirm:$False -ErrorAction SilentlyContinue
         
                # Register the removal tsk

                if ($Expire -eq $true) { Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName $TaskName -TaskPath $TaskPath -Description $Description -User $RunUser }
    
            } -ArgumentList @($Argument, $RemovalDate, $TaskName, $Expire, $TaskPath, $Description, $RunUser, $DomainUser)
            $wshell.Popup("Successfully added $User to the Local Administrators of $Computer.", 0, "Success")
        }
        Else {
            # If PC was not online display the message.
        
            $wshell.Popup("Unable to reach $Computer", 0, "Host Unreachable")
        }
    }
    function removeLocalAdmin {

        $Computer = $TextBox1.Text
        If (Test-Connection -ComputerName $Computer -Quiet) {
            $LocalAdminUsers = Invoke-Command -computer $Computer -scriptblock { Get-LocalGroupMember -group "Administrators" }
            $User = $null
            $SelectedUser = $LocalAdminUsers | Select-Object Name | Out-GridView -title "$computerName | Local Admins" -PassThru 
            $User = $SelectedUser.Name
            Invoke-Command -computer $Computer -ArgumentList $User -scriptblock { param($User)
                Remove-LocalGroupMember -group "Administrators" -Member $User }
    
            if ($User -eq $null) { }
            Else { $wshell.Popup("$User has been removed from the Local Admin group.", 0, "$Computer") }
        }
        else { $wshell.Popup("Unable to reach $Computer", 0, "Host Unreachable") }

    }

    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $Form = New-Object system.Windows.Forms.Form
    $Form.ClientSize = '300,150'
    $Form.text = "Local Admin Manager"
    $Form.TopMost = $false
    $Form.FormBorderStyle = 'Fixed3D'
    $Form.MaximizeBox = $false

    $Label1 = New-Object system.Windows.Forms.Label
    $Label1.text = "Target Computer"
    $Label1.AutoSize = $true
    $Label1.width = 25
    $Label1.height = 10
    $Label1.location = New-Object System.Drawing.Point(10, 10)
    $Label1.Font = 'Microsoft Sans Serif,10'
    $Form.Controls.Add($Label1)

    $TextBox1 = New-Object system.Windows.Forms.TextBox
    $TextBox1.multiline = $false
    $TextBox1.width = 141
    $TextBox1.height = 20
    $TextBox1.location = New-Object System.Drawing.Point(140, 10)
    $TextBox1.Font = 'Microsoft Sans Serif,10'
    $Form.Controls.Add($TextBox1)

    $Label2 = New-Object system.Windows.Forms.Label
    $Label2.text = "Domain"
    $Label2.AutoSize = $true
    $Label2.width = 25
    $Label2.height = 10
    $Label2.location = New-Object System.Drawing.Point(10, 34)
    $Label2.Font = 'Microsoft Sans Serif,10'
    $Form.Controls.Add($Label2)

    $TextBox2 = New-Object system.Windows.Forms.TextBox
    $TextBox2.multiline = $false
    $TextBox2.width = 140
    $TextBox2.height = 20
    $TextBox2.location = New-Object System.Drawing.Point(140, 34)
    $TextBox2.Font = 'Microsoft Sans Serif,10'
    $TextBox2.Text = 'Company-na'   
    $Form.Controls.Add($TextBox2)

    $Label3 = New-Object system.Windows.Forms.Label
    $Label3.text = "Username"
    $Label3.AutoSize = $true
    $Label3.width = 25
    $Label3.height = 10
    $Label3.location = New-Object System.Drawing.Point(10, 59)
    $Label3.Font = 'Microsoft Sans Serif,10'
    $Form.Controls.Add($Label3)

    $TextBox3 = New-Object system.Windows.Forms.TextBox
    $TextBox3.multiline = $false
    $TextBox3.width = 140
    $TextBox3.height = 20
    $TextBox3.location = New-Object System.Drawing.Point(140, 58)
    $TextBox3.Font = 'Microsoft Sans Serif,10'
    $Form.Controls.Add($TextBox3)


    $CheckBox1 = New-Object system.Windows.Forms.CheckBox
    $CheckBox1.text = "Set to Expire"
    $CheckBox1.AutoSize = $false
    $CheckBox1.width = 105
    $CheckBox1.height = 20
    $CheckBox1.location = New-Object System.Drawing.Point(10, 84)
    $CheckBox1.Font = 'Microsoft Sans Serif,10'
    $CheckBox1.Checked = $true
    $Form.Controls.Add($CheckBox1)

    $TextBox4 = New-Object system.Windows.Forms.TextBox
    $TextBox4.multiline = $false
    $TextBox4.width = 42
    $TextBox4.height = 20
    $TextBox4.location = New-Object System.Drawing.Point(140, 82)
    $TextBox4.Font = 'Microsoft Sans Serif,10'
    $TextBox4.Text = '10'
    $Form.Controls.Add($TextBox4)

    $Label4 = New-Object system.Windows.Forms.Label
    $Label4.text = "Days"
    $Label4.AutoSize = $true
    $Label4.width = 25
    $Label4.height = 10
    $Label4.location = New-Object System.Drawing.Point(185, 86)
    $Label4.Font = 'Microsoft Sans Serif,10'
    $Form.Controls.Add($Label4)

    $Button1 = New-Object system.Windows.Forms.Button
    $Button1.text = "Add"
    $Button1.width = 50
    $Button1.height = 30
    $Button1.location = New-Object System.Drawing.Point(55, 109)
    $Button1.Font = 'Microsoft Sans Serif,10'
    $Button1.Add_Click( { addLocalAdmin })
    $Form.Controls.Add($Button1)

    $Button2 = New-Object system.Windows.Forms.Button
    $Button2.text = "Remove User..."
    $Button2.width = 150
    $Button2.height = 30
    $Button2.location = New-Object System.Drawing.Point(115, 109)
    $Button2.Font = 'Microsoft Sans Serif,10'
    $Button2.Add_Click( { removeLocalAdmin })
    $Form.Controls.Add($Button2)

    [void]$Form.ShowDialog()

}

#Printer Tool - Adds printers to remote or local computer.
function printerTool {
    logAction "Opened Printer Tool" 
    #Executes the request to add the printer to the computer.
    function addPrinter {
        logAction "Opened Printer Tool"
        $printerName = $TextBox3.Text
        $computerName = $TextBox2.Text
        $printServer = $TextBox1.Text

        if (Test-Connection -computername $computerName -Quiet) { 
            Invoke-Command -ComputerName $computerName -Scriptblock {"RUNDLL32 PRINTUI.DLL,PrintUIEntry /ga /n\\$using:printServer\$using:printerName"}
            

            $wshell.Popup("Request to add $printerName to $computerName has been sent.", 0, "Printer Added")
        }

        Else {
            logAction "Failed to add printer; $computerName unreachable."
            $wshell.Popup("Target computer unreachable.", 0, "Error")
        }
    }


    $Form = New-Object system.Windows.Forms.Form
    $Form.ClientSize = '430,170'
    $Form.text = "Printer Tool"
    $Form.TopMost = $false

    $Label1 = New-Object system.Windows.Forms.Label
    $Label1.text = "Printer Server:"
    $Label1.AutoSize = $true
    $Label1.width = 25
    $Label1.height = 10
    $Label1.location = New-Object System.Drawing.Point(13, 20)
    $Label1.Font = 'Microsoft Sans Serif,10'

    $Label2 = New-Object system.Windows.Forms.Label
    $Label2.text = "Target Computer:"
    $Label2.AutoSize = $true
    $Label2.width = 25
    $Label2.height = 10
    $Label2.location = New-Object System.Drawing.Point(13, 45)
    $Label2.Font = 'Microsoft Sans Serif,10'

    $TextBox1 = New-Object system.Windows.Forms.TextBox
    $TextBox1.multiline = $false
    $TextBox1.width = 232
    $TextBox1.height = 20
    $TextBox1.location = New-Object System.Drawing.Point(144, 15)
    $TextBox1.Font = 'Microsoft Sans Serif,10'
    $TextBox1.Text = 'printservername'

    $TextBox2 = New-Object system.Windows.Forms.TextBox
    $TextBox2.multiline = $false
    $TextBox2.width = 232
    $TextBox2.height = 20
    $TextBox2.location = New-Object System.Drawing.Point(144, 40)
    $TextBox2.Font = 'Microsoft Sans Serif,10'

    $Label3 = New-Object system.Windows.Forms.Label
    $Label3.text = "Printer:"
    $Label3.AutoSize = $true
    $Label3.width = 25
    $Label3.height = 10
    $Label3.location = New-Object System.Drawing.Point(15, 70)
    $Label3.Font = 'Microsoft Sans Serif,10'

    $TextBox3 = New-Object system.Windows.Forms.ComboBox
    $TextBox3.multiline = $false
    $TextBox3.width = 232
    $TextBox3.height = 20
    $TextBox3.location = New-Object System.Drawing.Point(144, 65)
    $TextBox3.Font = 'Microsoft Sans Serif,10'

    #Populates the printer list with available shared printers.
    $printServer = $TextBox1.Text
    [array]$DropDownArray = Get-Printer -ComputerName $printServer | Select-Object Name | Sort-Object Name
    ForEach ($Item in $DropDownArray) { $TextBox3.Items.Add($Item.Name) }

    $Button2 = New-Object system.Windows.Forms.Button
    $Button2.BackColor = "#b1c39b"
    $Button2.text = "Add"
    $Button2.width = 60
    $Button2.height = 30
    $Button2.location = New-Object System.Drawing.Point(185, 124)
    $Button2.Font = 'Microsoft Sans Serif,10'
    $Button2.Add_Click( { addPrinter })

    $Form.controls.AddRange(@($Label1, $Label2, $TextBox1, $TextBox2, $Label3, $TextBox3, $Button1, $Button2))

    [void]$Form.ShowDialog()
}

#ODBC Tool - Add/Remove hard-coded ODBC Connections to the local computer
function odbcTool {
    logAction "ODBC Tool opened."
    $wshell.Popup("ODBC Tool must be run on local computer.", 0, "Notice")
    $TextBox1.Text = $env:computername
    function Get-Connections {

        $computerName = $TextBox1.Text
        $ListBox1.Items.Clear()
         
        $connections = Get-OdbcDsn 
        ForEach ($item in $connections) {
            $ListBox1.Items.Add($item.name)
        }
    }
        
    function Add-Connection {
        if ($CheckBox1.Checked) { Add-OdbcDsn -Name "dbPricing" -DriverName "SQL Server" -DsnType "System" -Platform "32-bit" -SetPropertyValue @("SERVER=", "DATABASE=dbPricing", "Trusted_Connection=Yes") }
        #Add DB Quality
        #Add BOM_DATA
        if ($CheckBox2.Checked) { Add-OdbcDsn -Name "ChassisDb" -DriverName "SQL Server" -DsnType "System" -Platform "32-bit" -SetPropertyValue @("SERVER=", "DATABASE=ChassisDb", "Trusted_Connection=Yes") }
        if ($CheckBox3.Checked) { Add-OdbcDsn -Name "db_APQP" -DriverName "SQL Server" -DsnType "System" -Platform "32-bit" -SetPropertyValue @("SERVER=", "DATABASE=db_APQP", "Trusted_Connection=Yes") }
        if ($CheckBox3.Checked) { Add-OdbcDsn -Name "dbAPQP" -DriverName "SQL Server" -DsnType "System" -Platform "32-bit" -SetPropertyValue @("SERVER=", "DATABASE=db_APQP", "Trusted_Connection=Yes") }
        if ($CheckBox3.Checked) { Add-OdbcDsn -Name "APQP" -DriverName "SQL Server" -DsnType "System" -Platform "32-bit" -SetPropertyValue @("SERVER=", "DATABASE=db_APQP", "Trusted_Connection=Yes") }
        if ($CheckBox4.Checked) { Add-OdbcDsn -Name "KMAK" -DriverName "SQL Server" -DsnType "System" -Platform "32-bit" -SetPropertyValue @("SERVER=", "DATABASE=KMAK", "Trusted_Connection=Yes") }
        #if ($CheckBox5.Checked) { Add-OdbcDsn -Name "db_APQP" -DriverName "SQL Server" -DsnType "System" -Platform "32-bit" -SetPropertyValue @("SERVER=", "DATABASE=db_APQP", "Trusted_Connection=Yes") }
        $wshell.Popup("Selected connections have been added.", 0, "Done")
        logAction "ODBC Connections added."
        Get-Connections
    }
        
    function Remove-Connection {
        $msgBoxInput = $wshell.Popup("Remove selected connections?", 0, "Done", 0x1)
        switch ($msgBoxInput) {
            '1' {
                if ($CheckBox1.Checked) { Remove-OdbcDsn -Name "dbPricing" -DriverName "SQL Server" -DsnType "System" -Platform "32-bit" }
                if ($CheckBox2.Checked) { Remove-OdbcDsn -Name "ChassisDb" -DriverName "SQL Server" -DsnType "System" -Platform "32-bit" }
                if ($CheckBox3.Checked) { Remove-OdbcDsn -Name "APQP" -DriverName "SQL Server" -DsnType "System" -Platform "32-bit" }
                if ($CheckBox4.Checked) { Remove-OdbcDsn -Name "KMAK" -DriverName "SQL Server" -DsnType "System" -Platform "32-bit" }
                $wshell.Popup("Selected connections have been removed.", 0, "Done")
                logAction "ODBC Connections removed."
            }
            '2' {
            }
        }

        Get-Connections
    }
            
    $Form = New-Object system.Windows.Forms.Form
    $Form.ClientSize = '400,400'
    $Form.text = ""
    $Form.TopMost = $false
            
    $Label1 = New-Object system.Windows.Forms.Label
    $Label1.text = "Manage ODBC Data Sources"
    $Label1.AutoSize = $true
    $Label1.width = 25
    $Label1.height = 10
    $Label1.location = New-Object System.Drawing.Point(104, 25)
    $Label1.Font = 'Microsoft Sans Serif,11'
    $Form.Controls.Add($Label1)

    $TextBox1 = New-Object system.Windows.Forms.TextBox
    $TextBox1.multiline = $false
    $TextBox1.Text = $env:computername
    #   $TextBox1.text = "Target Host/IP"
    $TextBox1.width = 200
    $TextBox1.height = 20
    $TextBox1.location = New-Object System.Drawing.Point(80, 50)
    $TextBox1.Font = 'Microsoft Sans Serif,10'
    $Form.Controls.Add($TextBox1)
    $TextBox1.Add_Click( {
            if ($TextBox1.Tag -eq $null) {
                $TextBox1.Text = ''
                $TextBox1.Tag = 'clear'
            } })
            
    $ButtonGo = New-Object system.Windows.Forms.Button
    $ButtonGo.text = "Go"
    $ButtonGo.width = 40
    $ButtonGo.height = 25
    $ButtonGo.location = New-Object System.Drawing.Point(285, 50)
    $ButtonGo.Font = 'Microsoft Sans Serif,10'
    $ButtonGo.Add_Click( { Get-Connections })
    $Form.Controls.Add($ButtonGo)

    $Label2 = New-Object system.Windows.Forms.Label
    $Label2.text = "Current Connections"
    $Label2.AutoSize = $true
    $Label2.width = 25
    $Label2.height = 10
    $Label2.location = New-Object System.Drawing.Point(140, 180)
    $Label2.Font = 'Microsoft Sans Serif,10'
    $Form.Controls.Add($Label2)
            
    $ListBox1 = New-Object system.Windows.Forms.ListBox
    $ListBox1.text = "listBox"
    $ListBox1.width = 294
    $ListBox1.height = 131
    $ListBox1.location = New-Object System.Drawing.Point(50, 200)
    $Form.Controls.Add($ListBox1)
            
    $Button1 = New-Object system.Windows.Forms.Button
    $Button1.BackColor = "#aebdae"
    $Button1.text = "Add"
    $Button1.width = 60
    $Button1.height = 30
    $Button1.location = New-Object System.Drawing.Point(114, 350)
    $Button1.Font = 'Microsoft Sans Serif,10'
    $Button1.Add_Click( { Add-Connection })
    $Form.Controls.Add($Button1)

    $Button2 = New-Object system.Windows.Forms.Button
    $Button2.BackColor = "#c0b6b6"
    $Button2.text = "Remove"
    $Button2.width = 80
    $Button2.height = 30
    $Button2.location = New-Object System.Drawing.Point(210, 350)
    $Button2.Font = 'Microsoft Sans Serif,10'
    $Button2.Add_Click( { Remove-Connection })
    $Form.Controls.Add($Button2)

    $CheckBox1 = New-Object system.Windows.Forms.CheckBox
    $CheckBox1.text = "dbPricing"
    $CheckBox1.AutoSize = $false
    $CheckBox1.width = 95
    $CheckBox1.height = 20
    $CheckBox1.location = New-Object System.Drawing.Point(40, 100)
    $CheckBox1.Font = 'Microsoft Sans Serif,10'
    $Form.Controls.Add($CheckBox1)
            
    $CheckBox2 = New-Object system.Windows.Forms.CheckBox
    $CheckBox2.text = "ChassisDb"
    $CheckBox2.AutoSize = $false
    $CheckBox2.width = 95
    $CheckBox2.height = 20
    $CheckBox2.location = New-Object System.Drawing.Point(40, 120)
    $CheckBox2.Font = 'Microsoft Sans Serif,10'
    $Form.Controls.Add($CheckBox2)
            
    $CheckBox3 = New-Object system.Windows.Forms.CheckBox
    $CheckBox3.text = "APQP"
    $CheckBox3.AutoSize = $false
    $CheckBox3.width = 95
    $CheckBox3.height = 20
    $CheckBox3.location = New-Object System.Drawing.Point(40, 140)
    $CheckBox3.Font = 'Microsoft Sans Serif,10'
    $Form.Controls.Add($CheckBox3)
            
    $CheckBox4 = New-Object system.Windows.Forms.CheckBox
    $CheckBox4.text = "KMAK"
    $CheckBox4.AutoSize = $false
    $CheckBox4.width = 95
    $CheckBox4.height = 20
    $CheckBox4.location = New-Object System.Drawing.Point(40, 160)
    $CheckBox4.Font = 'Microsoft Sans Serif,10'
    $Form.Controls.Add($CheckBox4)

    $CheckBox5 = New-Object system.Windows.Forms.CheckBox
    $CheckBox5.text = "Quality"
    $CheckBox5.AutoSize = $false
    $CheckBox5.width = 95
    $CheckBox5.height = 20
    $CheckBox5.location = New-Object System.Drawing.Point(140, 100)
    $CheckBox5.Font = 'Microsoft Sans Serif,10'
    $Form.Controls.Add($CheckBox5)
            
    Get-Connections
        
    [void]$Form.ShowDialog()
        
}
    


# Functions

function knowledgeBase {
    logAction "Knowledge Base opened."
    function populateFolders {
        $ComboBox1.Items.Clear()
        $kbFolders = Get-ChildItem "\\DYNLOUM102\securedfiles\749Information_Technology\Knowledge Base" | Select-Object Name
        ForEach ($folder in $kbFolders) {
            $ComboBox1.Items.Add($folder.Name)
        }
    }

    function getFolderItems {
        $ListBox1.Items.Clear()
        $selectedFolder = $ComboBox1.SelectedItem
        $folderItems = Get-ChildItem "\\DYNLOUM102\securedfiles\749Information_Technology\Knowledge Base\$selectedFolder" | Select-Object Name
        ForEach ($item in $folderItems) {
            $ListBox1.Items.Add($item.Name)
        }
    }

    function openFile {
        $selectedFolder = $ComboBox1.SelectedItem
        $selectedItem = $ListBox1.SelectedItem
        Start-Process "\\DYNLOUM102\securedfiles\749Information_Technology\Knowledge Base\$selectedFolder\$selectedItem" 
    }

    function newTopic {
        logAction "New KB Folder created."
        $newTopic = [Microsoft.VisualBasic.Interaction]::InputBox('Enter a title for the new topic', 'Add New Topic')
        New-Item -ItemType "directory" -Path "\\DYNLOUM102\securedfiles\749Information_Technology\Knowledge Base\$newTopic"
        $wshell.Popup("$newTopic has been added.", 0, "Success")
        populateFolders
    }

    function addFile {
        logAction "New KB item added."
        $initialDirectory = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.initialDirectory = $initialDirectory
        $OpenFileDialog.filter = "All files (*.*)| *.*"
        $OpenFileDialog.ShowDialog() | Out-Null
        $selectedFile = $OpenFileDialog.filename
        $selectedTopic = $ComboBox1.SelectedItem
        Copy-Item "$selectedFile" -Destination "\\DYNLOUM102\securedfiles\749Information_Technology\Knowledge Base\$selectedTopic"
        $wshell.Popup("File has been added to $selectedTopic.", 0, "Success")
        getFolderItems
    }

    $Form = New-Object system.Windows.Forms.Form
    $Form.ClientSize = '310,220'
    $Form.text = "Knowledge Base"
    $Form.TopMost = $false



    $ListBox1 = New-Object system.Windows.Forms.ListBox
    $ListBox1.text = "listBox"
    $ListBox1.width = 258
    $ListBox1.height = 137
    $ListBox1.location = New-Object System.Drawing.Point(25, 45)
    $ListBox1.add_mousedoubleclick( { openFile })
    $Form.Controls.Add($ListBox1)

    $ComboBox1 = New-Object system.Windows.Forms.ComboBox
    $ComboBox1.text = "Select topic..."
    $ComboBox1.width = 257
    $ComboBox1.height = 20
    $ComboBox1.location = New-Object System.Drawing.Point(25, 15)
    $ComboBox1.Font = 'Microsoft Sans Serif,10'
    $ComboBox1.add_selectedindexchanged( { getFolderItems })
    $Form.Controls.Add($ComboBox1)

    $knowledgeBaseButton1 = New-Object system.Windows.Forms.Button
    $knowledgeBaseButton1.text = "New Topic.."
    $knowledgeBaseButton1.width = 110
    $knowledgeBaseButton1.height = 22
    $knowledgeBaseButton1.location = New-Object System.Drawing.Point(35, 190)
    $knowledgeBaseButton1.Font = 'Microsoft Sans Serif,10'
    $knowledgeBaseButton1.Add_Click( { newTopic })
    $Form.Controls.Add($knowledgeBaseButton1)

    $knowledgeBaseButton2 = New-Object system.Windows.Forms.Button
    $knowledgeBaseButton2.text = "Add File.."
    $knowledgeBaseButton2.width = 110
    $knowledgeBaseButton2.height = 22
    $knowledgeBaseButton2.location = New-Object System.Drawing.Point(160, 190)
    $knowledgeBaseButton2.Font = 'Microsoft Sans Serif,10'
    $knowledgeBaseButton2.Add_Click( { addFile })
    $Form.Controls.Add($knowledgeBaseButton2)



    populateFolders

    [void]$Form.ShowDialog()

}
function remoteComputerManagement {
    $computerName = [Microsoft.VisualBasic.Interaction]::InputBox('Enter Host Name or IP Address of the computer you would like to connect to:', "Remote Computer Management")
    If (Test-Connection -ComputerName $computerName -quiet) {
        Start-Process compmgmt.msc /computer=\\$computerName
    }
    Else { $wshell.Popup("Unable to connect to host.", 0, "Error") }
}
function Launch-UNC {
    $computerName = $computerTextBox1.Text
    logAction "UNC path to $computerName accessed."
    $ShellExp = New-Object -ComObject Shell.Application
    $ShellExp.open("\\$computerName\c$")
}
    
function Launch-RDC {
    $computerName = $computerTextBox1.Text
    logAction "RDC Connection initiated to $computerName"
    Start-Process "$env:windir\system32\mstsc.exe" -ArgumentList "/v:$computerName"
}
    
Function Launch-RDP {
    $computerName = $computerTextBox1.Text
    logAction "RDP Session initiated to $computerName"
    Start-Process "C:\Program Files (x86)\SCCM2012Console\bin\i386\CmRcViewer.exe" $computerName
}

function sendMessage {
    $computerName = $computerTextBox1.Text
    logAction "Message sent to $computerName"
        

    $title = 'Send Message'
    $msg = 'Enter the message you would like to send to ' + "$computerName"

    $messageText = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
    Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList "msg * $messageText" -ComputerName $computerName
}

 function sendSpeech {

 $computerName = $computerTextBox1.Text

    $title = 'Send Text to Speech'
    $msg = 'Enter the text to speech message you would like to send to ' + "$computerName"

    $speechText = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)

$session = New-PSSession $computerName
Invoke-Command -Session $session -Scriptblock {
Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;
[Guid("5CDF2C82-841E-4546-9722-0CF74078229A"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioEndpointVolume
{
    // f(), g(), ... are unused COM method slots. Define these if you care
    int f(); int g(); int h(); int i();
    int SetMasterVolumeLevelScalar(float fLevel, System.Guid pguidEventContext);
    int j();
    int GetMasterVolumeLevelScalar(out float pfLevel);
    int k(); int l(); int m(); int n();
    int SetMute([MarshalAs(UnmanagedType.Bool)] bool bMute, System.Guid pguidEventContext);
    int GetMute(out bool pbMute);
}
[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDevice
{
    int Activate(ref System.Guid id, int clsCtx, int activationParams, out IAudioEndpointVolume aev);
}
[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceEnumerator
{
    int f(); // Unused
    int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice endpoint);
}
[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class MMDeviceEnumeratorComObject { }
public class Audio
{
    static IAudioEndpointVolume Vol()
    {
        var enumerator = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator;
        IMMDevice dev = null;
        Marshal.ThrowExceptionForHR(enumerator.GetDefaultAudioEndpoint(/*eRender*/ 0, /*eMultimedia*/ 1, out dev));
        IAudioEndpointVolume epv = null;
        var epvid = typeof(IAudioEndpointVolume).GUID;
        Marshal.ThrowExceptionForHR(dev.Activate(ref epvid, /*CLSCTX_ALL*/ 23, 0, out epv));
        return epv;
    }
    public static float Volume
    {
        get { float v = -1; Marshal.ThrowExceptionForHR(Vol().GetMasterVolumeLevelScalar(out v)); return v; }
        set { Marshal.ThrowExceptionForHR(Vol().SetMasterVolumeLevelScalar(value, System.Guid.Empty)); }
    }
    public static bool Mute
    {
        get { bool mute; Marshal.ThrowExceptionForHR(Vol().GetMute(out mute)); return mute; }
        set { Marshal.ThrowExceptionForHR(Vol().SetMute(value, System.Guid.Empty)); }
    }
}
'@
[audio]::Mute = $false
[audio]::Volume  = 1

    function Say-Text {
    param ([Parameter(Mandatory=$true, ValueFromPipeline=$true)] [string] $Text)
    [Reflection.Assembly]::LoadWithPartialName('System.Speech') | Out-Null   
    $object = New-Object System.Speech.Synthesis.SpeechSynthesizer 
    $object.Speak($Text) 
}
Say-Text "$Using:speechText"
}
Remove-Pssession $session


}

function checkUser {
    $computerName = $computerTextBox1.Text
    $userName = (Get-WmiObject -Class win32_process -ComputerName $computerName | Where-Object name -Match explorer).getowner().user
         
    $wshell.Popup("Last known user: $userName", 0, "$computerName User")
            
}
function getProcesses {
    $computerName = $computerTextBox1.Text
    logAction "Queried processes of $computerName"
    Get-Process -computername $computerName | Out-GridView -title "$computerName Processes"
}

function stopProcesses {
    $computerName = $computerTextBox1.Text
    $process = Get-Process -computername $computerName | Out-GridView -title "$computerName Processes" -PassThru 
    $processID = $process.id
    $processName = $process.ProcessName
    taskkill.exe /s $computerName /pid $processID /f
    $wshell.Popup("Request sent to $computerName to terminate $processName.", 0, "Success")
    logAction "Request sent to $computerName to terminate $processName."
}
function forceUpdate {
    $DateAndTime = (Get-Date -format ddMMMyyyy-HH.mm)
    $computerName = $computerTextBox1.Text
    logAction "Update scheduled for $computerName"
    Invoke-Command -ComputerName $computerName  -ScriptBlock {
        
        $DateAndTime = (Get-Date -format ddMMMyyyy-HH.mm)
        
        Register-ScheduledJob -Name "InstallUpdates $DateAndTime" -RunNow -ScriptBlock {
        
            $Criteria = "IsInstalled=0 and Type='Software'"; `
                $SearchResult = $Searcher.Search($Criteria).Updates; `
                $Session = New-Object -ComObject Microsoft.Update.Session; `
                $Downloader = $Session.CreateUpdateDownloader(); `
                $Downloader.Updates = $SearchResult; `
                $Downloader.Download(); `
                $Installer = New-Object -ComObject Microsoft.Update.Installer; `
                $Installer.Updates = $SearchResult; `
                $Result = $Installer.Install(); `
        } 
    } 
    $taskName = "InstallUpdates $DateAndTime"
    $taskExists = Get-ScheduledTask -cimsession $computerName | Where-Object { $_.TaskName -like $taskName }
    if ($taskExists) {
        $wshell.Popup("Update request has been sent successfully.", 0, "Success")
    }
    else {
        $wshell.Popup("Update request failed to send.", 0, "Error")
    }
}
    
function Restart-PC {
    $computerName = $computerTextBox1.Text
    logAction "Restart command sent to $computerName"
    $msgBoxInput = $wshell.Popup("Are you sure you want to restart the computer?", 0, "Restart", 0x1)
    switch ($msgBoxInput) {
        '1' {
            Restart-Computer $computerName -force
            $wshell.Popup("Restart request has been sent to the computer.", 0, "Success")
        }
        '2' {
        }
    }
}
    
function Shutdown-PC {
    $computerName = $computerTextBox1.Text
    logAction "Shutdown command sent to $computerName"
    $msgBoxInput = $wshell.Popup("Are you sure you want to shut down the computer?", 0, "Shut Down", 0x1)
    switch ($msgBoxInput) {
        '1' {
            Stop-Computer $computerName -force
            $wshell.Popup("Shut down request has been sent to the computer.", 0, "Success")
        }
        '2' {
        }
    }
}

function logOffAll {
    $computerName = $computerTextBox1.Text
    logAction "Log off all users sent to $computerName"
    $msgBoxInput = $wshell.Popup("Are you sure you want to log all users out of this computer?", 0, "Log Out All Users", 0x1)
    switch ($msgBoxInput) {
        '1' {
            (Get-WmiObject Win32_OperatingSystem -ComputerName $computerName).Win32Shutdown(4)
            $wshell.Popup("Request has been sent to log all users off.", 0, "Success")
        }
        '2' {
        }
    }
}
    
function applicationErrorCount {
    $computerName = $computerTextBox1.Text
    $errorTime = $computerTextBox2.Text
    logAction "Requested error count of $computerName"
    $getApplicationErrorCount = Get-EventLog -LogName Application -EntryType Error -ComputerName $computerName -After (Get-Date).AddHours(-$errorTime) | Measure-Object
    $applicationErrorCount = $getApplicationErrorCount.Count

    $getSystemErrorCount = Get-EventLog -LogName System -EntryType Error -ComputerName $computerName -After (Get-Date).AddHours(-$errorTime) | Measure-Object
    $systemErrorCount = $getSystemErrorCount.Count



        

    if ($errorTime -eq "1") { $reportErrorTime = "hour" }
    else { $reportErrorTime = "hours" }

    $wshell.Popup("Found $applicationErrorCount critical Application Log errors and $systemErrorCount System Log errors in the last $errorTime $reportErrorTime.", 0, "Error Check")
}

function getComputerInfo {
    Try {
        $computerDataGrid.DataSource = $null
        $computerName = $computerTextBox1.Text
        if (Test-Connection -computername $computerName -Quiet) {
            $wmi = Get-WmiObject Win32_ComputerSystem -computername $computerName -ea stop
            $wmi1 = Get-WmiObject Win32_NetworkAdapterConfiguration -computername $computerName | Where-Object { $_.IpEnabled -Match "True" }
            $wmi2 = Get-WmiObject -class Win32_OperatingSystem -computername $computerName
            $getIP = @(@(Get-WmiObject Win32_NetworkAdapterConfiguration -computername $computerName | Select-Object -ExpandProperty IPAddress) -like "*.*")[0]
            $ComputerOS = (Get-WmiObject Win32_OperatingSystem -ComputerName $computerName).Version
            $lastBoot = (Get-WmiObject Win32_OperatingSystem -ComputerName $computerName)
            $hddInfo = Get-WmiObject Win32_LogicalDisk -ComputerName $computerName -Filter "DeviceID='C:'" | Select-Object Size, FreeSpace
            $hddSize = [Math]::Round($hddInfo.Size / 1GB)
            $hddFreeSpace = [Math]::Round($hddInfo.FreeSpace / 1GB)
            $InstalledRAM = Get-WmiObject -Class Win32_ComputerSystem
            $getServiceTag = Get-WmiObject Win32_BaseBoard -ComputerName $computerName
            $serial = $getServiceTag.SerialNumber
            $getServicTag = $serial.Split('/')
        
            switch -Wildcard ($ComputerOS) {
                "6.1.7600" { $OS = "Windows 7"; break }
                "6.1.7601" { $OS = "Windows 7 SP1"; break }
                "6.2.9200" { $OS = "Windows 8"; break }
                "6.3.9600" { $OS = "Windows 8.1"; break }
                "10.0.*" { $OS = "Windows 10"; break }
                default { $OS = "Unknown Operating System"; break }
            }
        
            switch ($wmi2.Version) {
                '10.0.10240' { $wmi_build = "1507" }
                '10.0.10586' { $wmi_build = "1511" }
                '10.0.14393' { $wmi_build = "1607" }
                '10.0.15063' { $wmi_build = "1703" }
                '10.0.16299' { $wmi_build = "1709" }
                '10.0.17134' { $wmi_build = "1803" }
                '10.0.17686' { $wmi_build = "1809" }
                default { $wmi_build = "N/A" }
            }
        
            $hostName = $wmi.Name
            $makeModel = $wmi.Manufacturer + " - " + $wmi.Model
            $ipAddress = $getIP
            $macAddress = $wmi1.MACAddress
            $serialNumber = "test"
            $operatingSystem = $OS
            $osVersion = $wmi_build
            $RAM = [Math]::Round(($InstalledRAM.TotalPhysicalMemory / 1GB), 0)
            $HDD = "$hddSize" + 'GB Total / ' + "$hddFreeSpace" + 'GB Free'
            $lastRestart = $lastBoot.ConvertToDateTime($lastBoot.lastbootuptime)
            $serviceTag = $getServiceTag[1]
        
            $computerDataGrid.Rows[0].Cells[1].Value = $hostName
            $computerDataGrid.Rows[1].Cells[1].Value = $makeModel
            $computerDataGrid.Rows[2].Cells[1].Value = $ipAddress
            $computerDataGrid.Rows[3].Cells[1].Value = $operatingSystem
            $computerDataGrid.Rows[4].Cells[1].Value = $osVersion
            $computerDataGrid.Rows[5].Cells[1].Value = "$RAM" + ' GB'
            $computerDataGrid.Rows[6].Cells[1].Value = $HDD
            $computerDataGrid.Rows[7].Cells[1].Value = $lastRestart
            $computerDataGrid.Rows[8].Cells[1].Value = $macAddress
            $computerDataGrid.Rows[9].Cells[1].Value = $getServicTag[1]
        }
        else {
            $computerDataGrid.DataSource = $null
            
            $wshell.Popup("Unable to reach host.", 0, "Error")
        }
    }
    Catch {
        $wshell.Popup("Unable to reach host.", 0, "Error")
    }
}
    
function getDynaLocations {
    $UserTextBox1.Items.Add("All")
    [array]$getDynaLocations = Get-ADOrganizationalUnit -SearchBase "OU=DYN,OU=Users and Computers,DC=na,DC=Company,DC=com" -Filter { Name -like "DYN*" } -SearchScope OneLevel | Select-Object Name
    ForEach ($Item in $getDynaLocations) { $userTextBox1.Items.Add($Item.Name) }
}

function getUsers {
    $dynaLocation = $userTextBox1.Text
    $userTextBox2.Items.Clear()

    Import-Module ActiveDirectory

    $userTextBox2Collection = @()

    If ($dynaLocation -eq "All") {
        $Users = Get-ADUser -SearchBase "OU=DYN,OU=Users and Computers,DC=na,DC=Company,DC=com" -Filter { Description -like "Company,*" } | Select-Object Name, SamAccountName | Sort-Object Name
        foreach ($User in $Users) {
            $Object = New-Object Object 
            $Object | Add-Member -type NoteProperty -Name wholeName -Value $User.Name
            $Object | Add-Member -type NoteProperty -Name userName -Value $User.SamAccountName
            $userTextBox2Collection += $Object
        }
        $userTextBox2.Items.AddRange($userTextBox2Collection)
    
        #This is using the properties above to display the correct item
        $userTextBox2.ValueMember = "userName"
        $userTextBox2.DisplayMember = "wholeName"
    }

    Else {
        $Users = Get-ADUser -SearchBase "OU=Users,OU=$dynaLocation,OU=DYN,OU=Users and Computers,DC=na,DC=Company,DC=com" -Filter { Description -like "Company,*" } | Select-Object Name, SamAccountName | Sort-Object Name
        foreach ($User in $Users) {
            $Object = New-Object Object 
            $Object | Add-Member -type NoteProperty -Name wholeName -Value $User.Name
            $Object | Add-Member -type NoteProperty -Name userName -Value $User.SamAccountName
            $userTextBox2Collection += $Object
        }
        $userTextBox2.Items.AddRange($userTextBox2Collection)

        #This is using the properties above to display the correct item
        $userTextBox2.ValueMember = "userName"
        $userTextBox2.DisplayMember = "wholeName"
    }
}

function compareUsers($selectedUser) {
    $ListBox1.Items.Clear()
    logAction "User Group Comparison tool launched"
    $selectedUser1 = $selectedUser
    function compareGroups($selectedUser1) {
        $user1 = $userTextBox2.SelectedItem.userName
        $user2 = $userCompareTextBox2.SelectedItem.userName

        $u1groups = Get-ADPrincipalGroupMembership $user1
        $u2groups = Get-ADPrincipalGroupMembership $user2


        $groupsMissing = Compare-Object -referenceobject $u1groups -differenceobject $u2groups -passthru | Where-Object SideIndicator -eq "=>" | Select-Object name | Sort-Object Name
        $ListBox1.Items.Clear()
        foreach ($Group in $groupsMissing) {
            $GroupName = $Group.Name
            $ListBox1.Items.Add($GroupName)
        }
        $label1.text = "$user2's groups that $user1 is not in:"
    }

    function getDynaLocationsUC {
        $UserCompareTextBox1.Items.Add("All")
        [array]$getDynaLocations = Get-ADOrganizationalUnit -SearchBase "OU=DYN,OU=Users and Computers,DC=na,DC=Company,DC=com" -Filter { Name -like "DYN*" } -SearchScope OneLevel | Select-Object Name
        ForEach ($Item in $getDynaLocations) { $userCompareTextBox1.Items.Add($Item.Name) }
    }
    function getUsersUC {
        $dynaLocation = $userCompareTextBox1.Text
        $userCompareTextBox2.Items.Clear()

        Import-Module ActiveDirectory

        $userCompareTextBox2Collection = @()

        If ($dynaLocation -eq "All") {
            $Users = Get-ADUser -SearchBase "OU=DYN,OU=Users and Computers,DC=na,DC=Company,DC=com" -Filter { Description -like "Company,*" } | Select-Object Name, SamAccountName | Sort-Object Name
            foreach ($User in $Users) {
                $Object = New-Object Object 
                $Object | Add-Member -type NoteProperty -Name wholeName -Value $User.Name
                $Object | Add-Member -type NoteProperty -Name userName -Value $User.SamAccountName
                $userCompareTextBox2Collection += $Object
            }
            $userCompareTextBox2.Items.AddRange($userCompareTextBox2Collection)
    
            #This is using the properties above to display the correct item
            $userCompareTextBox2.ValueMember = "userName"
            $userCompareTextBox2.DisplayMember = "wholeName"
        }
        Else {
            $Users = Get-ADUser -SearchBase "OU=Users,OU=,OU=DYN,OU=Users and Computers,DC=na,DC=Company,DC=com" -Filter { Description -like "Company,*" } | Select-Object Name, SamAccountName | Sort-Object Name
            foreach ($User in $Users) {
                $Object = New-Object Object 
                $Object | Add-Member -type NoteProperty -Name wholeName -Value $User.Name
                $Object | Add-Member -type NoteProperty -Name userName -Value $User.SamAccountName
                $userCompareTextBox2Collection += $Object
            }
            $userCompareTextBox2.Items.AddRange($userCompareTextBox2Collection)
    
            #This is using the properties above to display the correct item
            $userCompareTextBox2.ValueMember = "userName"
            $userCompareTextBox2.DisplayMember = "wholeName"
        }
    }

    function addToAllGroups {

        $msgBoxInput = $wshell.Popup("Are you sure you want to add user to all groups?", 0, "Confirm", 0x1)
        switch ($msgBoxInput) {
            '1' {
           
                $user1 = $userTextBox2.SelectedItem.userName
                $groups = $ListBox1.Items
                ForEach ($groupName in $groups) {
                    try {
                        Add-ADGroupMember -Identity $groupName -Members $user1

                    }
                    catch { $wshell.Popup("Failed to add to $groupName") }
                }

            }
            '2' { }
        }

    }


    function addToGroup {
        $groupName = $ListBox1.SelectedItem

        $msgBoxInput = $wshell.Popup("Are you sure you want to add user to $groupName", 0, "Confirm", 0x1)
        switch ($msgBoxInput) {
            '1' {
                try {
                    Add-ADGroupMember -Identity $groupName -Members $user1
                    $wshell.Popup("Successfully added to $groupName")
                }
                catch { $wshell.Popup("Failed to add to $groupName") }
            }

            '2' { }
        }
    }




    $Form = New-Object system.Windows.Forms.Form
    $Form.ClientSize = '310,240'
    $Form.text = "Compare Users"
    $Form.TopMost = $false

    $userCompareTextBox1 = New-Object system.Windows.Forms.ComboBox
    $userCompareTextBox1.multiline = $false
    $userCompareTextBox1.text = "Location"
    $userCompareTextBox1.width = 100
    $userCompareTextBox1.height = 20
    $userCompareTextBox1.location = New-Object System.Drawing.Point(10, 10)
    $userCompareTextBox1.Font = 'Microsoft Sans Serif,10'
    $userCompareTextBox1.add_selectedindexchanged( { getUsersUC })
    $Form.Controls.Add($userCompareTextBox1)
    getDynaLocationsUC

    $userCompareTextBox2 = New-Object system.Windows.Forms.ComboBox
    $userCompareTextBox2.multiline = $false
    $userCompareTextBox2.text = "User"
    $userCompareTextBox2.width = 182
    $userCompareTextBox2.height = 20
    $userCompareTextBox2.location = New-Object System.Drawing.Point(120, 10)
    $userCompareTextBox2.Font = 'Microsoft Sans Serif,10'
    $userCompareTextBox2.add_selectedindexchanged( { compareGroups })
    $Form.Controls.Add($userCompareTextBox2)



    $label1 = New-Object system.Windows.Forms.Label

    $label1.AutoSize = $true
    $label1.width = 25
    $label1.height = 10
    $label1.location = New-Object System.Drawing.Point(10, 45)
    $Form.Controls.Add($label1)

    $ListBox1 = New-Object system.Windows.Forms.ListBox
    $ListBox1.text = "listBox"
    $ListBox1.width = 290
    $ListBox1.height = 140
    $ListBox1.location = New-Object System.Drawing.Point(10, 65)
    $Form.Controls.Add($ListBox1)

    $Button0 = New-Object system.Windows.Forms.Button
    $Button0.Text = "Add to Group"     
    $Button0.width = 120
    $Button0.height = 24
    $Button0.location = New-Object System.Drawing.Point(20, 205)
    $Button0.Font = 'Microsoft Sans Serif,10'
    $Button0.Add_Click( { addToGroup })
    $Form.Controls.Add($Button0)


    $Button1 = New-Object system.Windows.Forms.Button
    $Button1.Text = "Add to All Groups"     
    $Button1.width = 140
    $Button1.height = 24
    $Button1.location = New-Object System.Drawing.Point(150, 205)
    $Button1.Font = 'Microsoft Sans Serif,10'
    $Button1.Add_Click( { addToAllGroups })
    $Form.Controls.Add($Button1)


    populateFolders

    [void]$Form.ShowDialog()

}
function getUserInfo {
    $userGroupsBox.Items.Clear()
    $groupMembersBox.Items.Clear()
    $userDataGrid.DataSource = $null

    $wholeName = $userTextBox2.SelectedItem.wholeName
    $userName = $userTextBox2.SelectedItem.userName
    $selectedUser = $userName
    logAction "Requested user info of $wholeName"

    $userOBject = Get-ADUser $userName -Properties Department, Telephonenumber | Sort-Object Name

    $emailAddress = $userOBject.UserPrincipalName
    $department = $userOBject.Department
    $phoneNumber = $userOBject.Telephonenumber

    $userDataGrid.Rows[0].Cells[1].Value = $userName
    $userDataGrid.Rows[1].Cells[1].Value = $emailAddress
    $userDataGrid.Rows[2].Cells[1].Value = $department
    $userDataGrid.Rows[3].Cells[1].Value = $phoneNumber
    getUserGroups
}

function getUserGroups {

    $userGroupsBoxCollection = @()
    $getADGroups = Get-ADPrincipalGroupMembership $userName | Select-Object name, distinguishedName | Sort-Object Name
    foreach ($Group in $getADGroups) {
        $Object = New-Object Object 
        $Object | Add-Member -type NoteProperty -Name groupName -Value $Group.name
        $Object | Add-Member -type NoteProperty -Name distinguishedName -Value $Group.distinguishedName
        $userGroupsBoxCollection += $Object
    }
    $userGroupsBox.Items.AddRange($userGroupsBoxCollection)
    $userGroupsBox.ValueMember = "distinguishedName"
    $userGroupsBox.DisplayMember = "groupName"
}

function getGroupMembers {
    $groupMembersBox.Items.Clear()
    $selectedGroup = $userGroupsBox.SelectedItem.distinguishedName
    $membersList = Get-ADGroupMember "$selectedGroup" | Select-Object Name | Sort-Object Name 
    foreach ($Member in $membersList) { $groupMembersBox.Items.Add($Member.Name) }
}

function resetPassword {
    $userName = $userTextBox2.SelectedItem.userName
    logAction "Reset password of $userName"
    Set-ADAccountPassword -Identity $userName -NewPassword (ConvertTo-SecureString -AsPlainText "Company1!" -Force)
    Set-ADUser $userName -changepasswordatlogon $true 
          
    $wshell.Popup("Password reset to Company1!", 0, "Success")
}

function unlockUser {
    $userName = $userTextBox2.SelectedItem.userName
    logAction "Attempted to unlock $userName"
    $checkLockStatus = Get-ADUser $userName -Properties * | Select-Object LockedOut
    $lockStatus = $checkLockStatus.LockedOut
 
    If ($lockStatus -eq $False) {
        $wshell.Popup("User is not currently locked out.", 0, "Lock Status")
    }
    else {
        Unlock-ADAccount -Identity $userName
        $wshell.Popup("User account has been unlocked.", 0, "Lock Status")
    }
}

function makeUserLocalAdmin {

    $computerName = [Microsoft.VisualBasic.Interaction]::InputBox('Enter Host Name or IP Address of the computer you would like to make the user a Local Administrator on:', 'Add user to Local Administrators group.')
    if (Test-Connection -computername $computerName -Quiet) { 
        Try {
            $UserName = $userTextBox2.SelectedItem.userName
            logAction "$userName added as local admin of $computerName"
            $AdminGroup = [ADSI]"WinNT://$computerName/Administrators,group"
            $User = [ADSI]"WinNT://Company-NA/$UserName,user"
            $AdminGroup.Add($User.Path)
            $wshell.Popup("User has been added to Local Admin group of $computerName.", 0, "Success")
        }
        Catch {
            $wshell.Popup("Unable to add user to Local Admin group.", 0, "Error")
        }
    }
    Else { $wshell.Popup("Unable to reach the host.", 0, "Error") }
}
function addGroup {
    $group = [Microsoft.VisualBasic.Interaction]::InputBox('Enter exact group name spelling:', 'Add to AD Group')
    $selectedUser = $userTextBox2.SelectedItem.wholeName
    $selectedUserName = $userTextBox2.SelectedItem.userName
    logAction "$selectedUser added to AD group $group"
    Try {
        Add-ADGroupMember -Identity "$group" -Members "$selectedUserName"
        $wshell.Popup("$selectedUser has been added to $group.", 0, "Success")
        getUserGroups
    }
    Catch {
        $wshell.Popup("Group not found.", 0, "Error")
    }
}
function removeGroup {
    $selectedGroup = $userGroupsBox.SelectedItem.groupName
    $selectedGroupDN = $userGroupsBox.SelectedItem.distinguishedName
    $selectedUser = $userTextBox2.SelectedItem.wholeName
    $selectedUserName = $userTextBox2.SelectedItem.userName
    logAction "$selectedUser removed from AD group $selectedGroup"
    $msgBoxInput = $wshell.Popup("Are you sure you want to remove $selectedUser from " + $selectedGroup + "?", 0, "Confirm", 0x1)
    switch ($msgBoxInput) {
        '1' {
            Remove-ADGroupMember -Identity "$selectedGroupDN" -members "$selectedUserName" -confirm:$false
            getUserGroups
            $wshell.Popup("$selectedUser has been removed from " + $selectedGroup + ".", 0, "Success")
        }
        '2' { }
    }
}

function addUser {
    $user = "None"
    $user = [Microsoft.VisualBasic.Interaction]::InputBox('Enter username:', 'Add User to Group')
    $selectedGroup = $userGroupsBox.SelectedItem.groupName
    $selectedGroupDN = $userGroupsBox.SelectedItem.distinguishedName
    
    If ($user -eq "") { }
    Else {
        Try { 
            Add-ADGroupMember -Identity "$selectedGroupDN" -Members "$user" 
            getGroupMembers
            $wshell.Popup("$user has been added to $selectedGroup.", 0, "Success")
            logAction "$user added to AD group $selectedGroup"

        }
        Catch {
            $wshell.Popup("User not found.", 0, "Error")
            $wshell.Popup("$user", 0, "Error")
        }
    }
}

function removeUser {
    $selectedGroupDN = $userGroupsBox.SelectedItem.distinguishedName
    $selectedUserName = $groupMembersBox.SelectedItem

    $getUserName = Get-ADUser -filter { name -like $selectedUserName } | Select-Object SamAccountName
    $userName = $getUserName.SamAccountName

    Remove-ADGroupMember -Identity "$selectedGroupDN" -Members "$userName" -confirm:$false
    getGroupMembers
    logAction "$userName removed from AD group $selectedGroupDN"
}
# The main form setup for the Tool
function CreateForm {
    #[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
    #[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null

        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.drawing
        
        #Form Setup
        $formMain = New-Object System.Windows.Forms.Form
        $TabControl = New-Object System.Windows.Forms.TabControl
        $mainPage = New-Object System.Windows.Forms.TabPage
        $computerPage = New-Object System.Windows.Forms.TabPage
        $userPage = New-Object System.Windows.Forms.TabPage
        $toolPage = New-Object System.Windows.Forms.TabPage
        $toolButton1 = New-Object System.Windows.Forms.Button
        
        $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
        
        #Form Parameter
        $formMain.Text = "Company - IT System Helper"
        $formMain.Name = "formMain"
        $formMain.DataBindings.DefaultDataSourceUpdateMode = 0
        $formMain.FormBorderStyle = 'Fixed3D'
        $formMain.MaximizeBox = $false
        $System_Drawing_Size = New-Object System.Drawing.Size
        $System_Drawing_Size.Width = 595
        $System_Drawing_Size.Height = 345
        $formMain.ClientSize = $System_Drawing_Size
        
        #Draw and set Icon
        [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
        $bmp = New-Object System.Drawing.Bitmap(16, 16)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.drawline([System.Drawing.Pens]::Red, 4, 7, 4, 15)
        $g.drawline([System.Drawing.Pens]::Red, 5, 7, 5, 14)
        $g.drawline([System.Drawing.Pens]::Red, 10, 4, 10, 15)
        $g.drawline([System.Drawing.Pens]::Red, 11, 3, 11, 14)
        $g.drawline([System.Drawing.Pens]::Red, 0, 4, 14, 4)
        $g.drawline([System.Drawing.Pens]::Red, 1, 3, 15, 3)


        $ico = [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
        $formMain.Icon = $ico
        ###
        # End of the icon generation and loading
        ###

        $formMain.DataBindings.DefaultDataSourceUpdateMode = 0
        $System_Drawing_Size = New-Object System.Drawing.Size
        $System_Drawing_Size.Width = 284
        $System_Drawing_Size.Height = 262
        
        #Tab Control
        $tabControl.DataBindings.DefaultDataSourceUpdateMode = 0
        $System_Drawing_Point = New-Object System.Drawing.Point
        $System_Drawing_Point.X = 5
        $System_Drawing_Point.Y = 5
        $tabControl.Location = $System_Drawing_Point
        $tabControl.Name = "tabControl"
        $System_Drawing_Size = New-Object System.Drawing.Size
        $System_Drawing_Size.Height = 335
        $System_Drawing_Size.Width = 585
        $tabControl.Size = $System_Drawing_Size
        $formMain.Controls.Add($tabControl)
        
        #Main Page
        $mainPage.DataBindings.DefaultDataSourceUpdateMode = 0
        $mainPage.UseVisualStyleBackColor = $True
        $mainPage.Name = "mainPage"
        $mainPage.Text = "Main"
        $tabControl.Controls.Add($mainPage)
           
        $mainTextBox1 = New-Object system.Windows.Forms.MaskedTextBox
        $mainTextBox1.multiline = $false
        $mainTextBox1.PasswordChar = '*'
        $mainTextBox1.width = 200
        $mainTextBox1.height = 20
        $mainTextBox1.location = New-Object System.Drawing.Point(40, 40)
        $mainTextBox1.Font = 'Microsoft Sans Serif,10'
        $mainPage.Controls.Add($mainTextBox1)

        $mainButton = New-Object system.Windows.Forms.Button
        $mainButton.Text = "4"     
        $mainButton.width = 20
        $mainButton.height = 24
        $mainButton.location = New-Object System.Drawing.Point(250, 40)
        $mainButton.Font = 'Wingdings,12'
        $mainButton.Add_Click( { 
                Set-Clipboard $mainTextBox1.text
            })
        $mainPage.Controls.Add($mainButton)


        $mainButton1 = New-Object system.Windows.Forms.Button
        $mainButton1.Text = "Knowlede Base"     
        $mainButton1.width = 110
        $mainButton1.height = 24
        $mainButton1.location = New-Object System.Drawing.Point(160, 200)
        $mainButton1.Font = 'Microsoft Sans Serif,10'
        $mainButton1.Add_Click( { knowledgeBase })
        $mainPage.Controls.Add($mainButton1)

        $mainButton2 = New-Object system.Windows.Forms.Button
        $mainButton2.Text = "Request Center"     
        $mainButton2.width = 110
        $mainButton2.height = 24
        $mainButton2.location = New-Object System.Drawing.Point(40, 200)
        $mainButton2.Font = 'Microsoft Sans Serif,10'
        $mainButton2.add_Click( {
                $IE = New-Object -com internetexplorer.application
                $IE.navigate2("http://ittracker.Company.com/GlobalServiceRequest/#/GlobalRequestClient;component/Views/HomePage.xaml")
                $IE.visible = $true })
        $mainPage.Controls.Add($mainButton2)

        $mainButton3 = New-Object system.Windows.Forms.Button
        $mainButton3.Text = "PC Inventory"     
        $mainButton3.width = 110
        $mainButton3.height = 24
        $mainButton3.location = New-Object System.Drawing.Point(280, 200)
        $mainButton3.Font = 'Microsoft Sans Serif,10'
        $mainButton3.add_Click( { Start-Process("") })
        $mainPage.Controls.Add($mainButton3)

        $mainButton4 = New-Object system.Windows.Forms.Button
        $mainButton4.Text = "Active Directory"     
        $mainButton4.width = 110
        $mainButton4.height = 24
        $mainButton4.location = New-Object System.Drawing.Point(160, 230)
        $mainButton4.Font = 'Microsoft Sans Serif,10'
        $mainButton4.Add_Click( { Start-Process("dsa.msc") })
        $mainPage.Controls.Add($mainButton4)

        $mainButton5 = New-Object system.Windows.Forms.Button
        $mainButton5.Text = "Password Safe"     
        $mainButton5.width = 110
        $mainButton5.height = 24
        $mainButton5.location = New-Object System.Drawing.Point(40, 230)
        $mainButton5.Font = 'Microsoft Sans Serif,10'
        $mainButton5.add_Click( { Start-Process("C:\Program Files (x86)\Password Safe\pwsafe.exe") })
        $mainPage.Controls.Add($mainButton5)

        $mainButton6 = New-Object system.Windows.Forms.Button
        $mainButton6.Text = "SCCM"     
        $mainButton6.width = 110
        $mainButton6.height = 24
        $mainButton6.location = New-Object System.Drawing.Point(280, 230)
        $mainButton6.Font = 'Microsoft Sans Serif,10'
        $mainButton6.add_Click( { Start-Process("C:\Program Files (x86)\SCCM2012Console\bin\Microsoft.ConfigurationManagement.exe") })
        $mainPage.Controls.Add($mainButton6)                
        
        $mainButton7 = New-Object system.Windows.Forms.Button
        $mainButton7.Text = "PowerShell"     
        $mainButton7.width = 110
        $mainButton7.height = 24
        $mainButton7.location = New-Object System.Drawing.Point(40, 260)
        $mainButton7.Font = 'Microsoft Sans Serif,10'
        $mainButton7.Add_Click( { Start-Process powershell })
        $mainPage.Controls.Add($mainButton7)

        $mainButton8 = New-Object system.Windows.Forms.Button
        $mainButton8.Text = "Remote Computer Management"     
        $mainButton8.width = 230
        $mainButton8.height = 24
        $mainButton8.location = New-Object System.Drawing.Point(160, 260)
        $mainButton8.Font = 'Microsoft Sans Serif,10'
        $mainButton8.Add_Click( { remoteComputerManagement })
        $mainPage.Controls.Add($mainButton8)


        $mainLink0 = New-Object system.Windows.Forms.LinkLabel
        $mainLink0.text = "IT Team Intranet"
        $mainLink0.AutoSize = $true
        $mainLink0.width = 25
        $mainLink0.height = 10
        $mainLink0.location = New-Object System.Drawing.Point(450, 25)
        $mainLink0.LinkColor = "BLACK" 
        $mainLink0.ActiveLinkColor = "BLACK" 
        $mainLink0.add_Click( { [system.Diagnostics.Process]::start("") })
        $mainLink0.Font = 'Calibri,12' 
        $mainLink0.LinkBehavior = 'HoverUnderline'
        $mainPage.Controls.Add($mainLink0)

        $mainLink1 = New-Object system.Windows.Forms.LinkLabel
        $mainLink1.text = "Company Intranet"
        $mainLink1.AutoSize = $true
        $mainLink1.width = 25
        $mainLink1.height = 10
        $mainLink1.location = New-Object System.Drawing.Point(450, 47)
        $mainLink1.LinkColor = "BLACK" 
        $mainLink1.ActiveLinkColor = "BLACK" 
        $mainLink1.add_Click( { [system.Diagnostics.Process]::start("") })
        $mainLink1.Font = 'Calibri,12' 
        $mainLink1.LinkBehavior = 'HoverUnderline'
        $mainPage.Controls.Add($mainLink1)

        $mainLink2 = New-Object system.Windows.Forms.LinkLabel
        $mainLink2.text = "Company Intranet"
        $mainLink2.AutoSize = $true
        $mainLink2.width = 25
        $mainLink2.height = 10
        $mainLink2.location = New-Object System.Drawing.Point(450, 69)
        $mainLink2.LinkColor = "BLACK" 
        $mainLink2.ActiveLinkColor = "BLACK" 
        $mainLink2.add_Click( { [system.Diagnostics.Process]::start("") })
        $mainLink2.Font = 'Calibri,12' 
        $mainLink2.LinkBehavior = 'HoverUnderline'
        $mainPage.Controls.Add($mainLink2)

        $mainLink3 = New-Object system.Windows.Forms.LinkLabel
        $mainLink3.text = "Company Store"
        $mainLink3.AutoSize = $true
        $mainLink3.width = 25
        $mainLink3.height = 10
        $mainLink3.location = New-Object System.Drawing.Point(450, 91)
        $mainLink3.LinkColor = "BLACK" 
        $mainLink3.ActiveLinkColor = "BLACK" 
        $mainLink3.add_Click( { [system.Diagnostics.Process]::start("") })
        $mainLink3.Font = 'Calibri,12' 
        $mainLink3.LinkBehavior = 'HoverUnderline'
        $mainPage.Controls.Add($mainLink3)

        $mainLink4 = New-Object system.Windows.Forms.LinkLabel
        $mainLink4.text = "HR Service Center"
        $mainLink4.AutoSize = $true
        $mainLink4.width = 25
        $mainLink4.height = 10
        $mainLink4.location = New-Object System.Drawing.Point(450, 113)
        $mainLink4.LinkColor = "BLACK" 
        $mainLink4.ActiveLinkColor = "BLACK" 
        $mainLink4.add_Click( { [system.Diagnostics.Process]::start("") })
        $mainLink4.Font = 'Calibri,12' 
        $mainLink4.LinkBehavior = 'HoverUnderline'
        $mainPage.Controls.Add($mainLink4)

        $mainLink5 = New-Object system.Windows.Forms.LinkLabel
        $mainLink5.text = "Company Benefits"
        $mainLink5.AutoSize = $true
        $mainLink5.width = 25
        $mainLink5.height = 10
        $mainLink5.location = New-Object System.Drawing.Point(450, 135)
        $mainLink5.LinkColor = "BLACK" 
        $mainLink5.ActiveLinkColor = "BLACK" 
        $mainLink5.add_Click( { [system.Diagnostics.Process]::start("") })
        $mainLink5.Font = 'Calibri,12' 
        $mainLink5.LinkBehavior = 'HoverUnderline'
        $mainPage.Controls.Add($mainLink5)

        $mainLink6 = New-Object system.Windows.Forms.LinkLabel
        $mainLink6.text = "Mobile Iron"
        $mainLink6.AutoSize = $true
        $mainLink6.width = 25
        $mainLink6.height = 10
        $mainLink6.location = New-Object System.Drawing.Point(450, 157)
        $mainLink6.LinkColor = "BLACK" 
        $mainLink6.ActiveLinkColor = "BLACK" 
        $mainLink6.add_Click( { [system.Diagnostics.Process]::start("") })
        $mainLink6.Font = 'Calibri,12' 
        $mainLink6.LinkBehavior = 'HoverUnderline'
        $mainPage.Controls.Add($mainLink6)

        $mainLink7 = New-Object system.Windows.Forms.LinkLabel
        $mainLink7.text = "Honeywell RMA"
        $mainLink7.AutoSize = $true
        $mainLink7.width = 25
        $mainLink7.height = 10
        $mainLink7.location = New-Object System.Drawing.Point(450, 179)
        $mainLink7.LinkColor = "BLACK" 
        $mainLink7.ActiveLinkColor = "BLACK" 
        $mainLink7.add_Click( { [system.Diagnostics.Process]::start("") })
        $mainLink7.Font = 'Calibri,12' 
        $mainLink7.LinkBehavior = 'HoverUnderline'
        $mainPage.Controls.Add($mainLink7)

        $mainLink8 = New-Object system.Windows.Forms.LinkLabel
        $mainLink8.text = "Aramark Uniforms"
        $mainLink8.AutoSize = $true
        $mainLink8.width = 25
        $mainLink8.height = 10
        $mainLink8.location = New-Object System.Drawing.Point(450, 201)
        $mainLink8.LinkColor = "BLACK" 
        $mainLink8.ActiveLinkColor = "BLACK" 
        $mainLink8.add_Click( { [system.Diagnostics.Process]::start("") })
        $mainLink8.Font = 'Calibri,12' 
        $mainLink8.LinkBehavior = 'HoverUnderline'
        $mainPage.Controls.Add($mainLink8)
        
        $mainLabel1 = New-Object system.Windows.Forms.Label
        $mainLabel1.text = "Company"
        $mainLabel1.AutoSize = $true
        $mainLabel1.width = 25
        $mainLabel1.height = 10
        $mainLabel1.location = New-Object System.Drawing.Point(454, 265)
        $mainLabel1.Font = 'Franklin Gothic,14,style=Italic'
        $mainLabel1.ForeColor = "#ff0000"
        $mainPage.Controls.Add($mainLabel1)
        
        $mainLabel2 = New-Object system.Windows.Forms.Label
        $mainLabel2.text = "A  Company"
        $mainLabel2.AutoSize = $true
        $mainLabel2.width = 25
        $mainLabel2.height = 10
        $mainLabel2.location = New-Object System.Drawing.Point(455, 287)
        $mainLabel2.Font = 'Calibri,10'
        $mainPage.Controls.Add($mainLabel2)
             
        #Computer Page
        $computerPage.DataBindings.DefaultDataSourceUpdateMode = 0
        $computerPage.UseVisualStyleBackColor = $True
        $computerPage.Name = "computerPage"
        $computerPage.Text = "Computer"
        $tabControl.Controls.Add($computerPage)
        
        $computerTextBox1 = New-Object system.Windows.Forms.TextBox
        $computerTextBox1.multiline = $false
        $computerTextBox1.text = "Host Name / IP"
        $computerTextBox1.width = 220
        $computerTextBox1.height = 20
        $computerTextBox1.location = New-Object System.Drawing.Point(12, 20)
        $computerTextBox1.Font = 'Microsoft Sans Serif,10'
        $computerTextBox1.Add_Click( {
                if ($computerTextBox1.Tag -eq $null) {
                    $computerTextBox1.Text = ''
                    $computerTextBox1.Tag = 'clear'
                } })
        $computerPage.Controls.Add($computerTextBox1)
        
        $computerButtonGo = New-Object system.Windows.Forms.Button
        $computerButtonGo.text = "Go"
        $computerButtonGo.width = 60
        $computerButtonGo.height = 22
        $computerButtonGo.location = New-Object System.Drawing.Point(241, 20)
        $computerButtonGo.Font = 'Microsoft Sans Serif,10'
        $computerButtonGo.Add_Click( { getComputerInfo })
        $computerPage.Controls.Add($computerButtonGo)
        
        $computerDataGrid = New-Object system.Windows.Forms.DataGridView
        $computerDataGrid.width = 290
        $computerDataGrid.height = 223
        $computerDataGrid.location = New-Object System.Drawing.Point(12, 65)
        $computerDataGrid.ColumnHeadersVisible = $false
        $computerDataGrid.RowHeadersVisible = $false
        $computerDataGrid.ColumnCount = 2
        $computerDataGrid.RowCount = 10
        $computerDataGrid.Columns[0].Width = 120
        $computerDataGrid.Columns[1].Width = 167
        $computerDataGrid.Rows[0].Cells[0].Value = "Host Name"
        $computerDataGrid.Rows[1].Cells[0].Value = "Make/Model"
        $computerDataGrid.Rows[2].Cells[0].Value = "IP Address"
        $computerDataGrid.Rows[3].Cells[0].Value = "Operating System"
        $computerDataGrid.Rows[4].Cells[0].Value = "OS Build Number"
        $computerDataGrid.Rows[5].Cells[0].Value = "RAM"
        $computerDataGrid.Rows[6].Cells[0].Value = "HDD"
        $computerDataGrid.Rows[7].Cells[0].Value = "Last Restart"
        $computerDataGrid.Rows[8].Cells[0].Value = "MAC Address"
        $computerDataGrid.Rows[9].Cells[0].Value = "Service Tag"
        
        $computerButton1 = New-Object system.Windows.Forms.Button
        $computerButton1.text = "Remote Control"
        $computerButton1.width = 110
        $computerButton1.height = 22
        $computerButton1.location = New-Object System.Drawing.Point(320, 65)
        $computerButton1.Font = 'Microsoft Sans Serif,10'
        $computerButton1.Add_Click( { Launch-RDP })
        $computerPage.Controls.Add($computerButton1)
        
        $computerButton2 = New-Object system.Windows.Forms.Button
        $computerButton2.text = "RDC"
        $computerButton2.width = 50
        $computerButton2.height = 22
        $computerButton2.location = New-Object System.Drawing.Point(440, 65)
        $computerButton2.Font = 'Microsoft Sans Serif,10'
        $computerButton2.Add_Click( { Launch-RDC })
        $computerPage.Controls.Add($computerButton2)
        
        $computerButton3 = New-Object system.Windows.Forms.Button
        $computerButton3.text = "UNC"
        $computerButton3.width = 60
        $computerButton3.height = 22
        $computerButton3.location = New-Object System.Drawing.Point(500, 65)
        $computerButton3.Font = 'Microsoft Sans Serif,10'
        $computerButton3.Add_Click( { Launch-UNC })
        $computerPage.Controls.Add($computerButton3)
        
        $computerButton4 = New-Object system.Windows.Forms.Button
        $computerButton4.text = "Message"
        $computerButton4.width = 110
        $computerButton4.height = 22
        $computerButton4.location = New-Object System.Drawing.Point(320, 95)
        $computerButton4.Font = 'Microsoft Sans Serif,10'
        $computerButton4.Add_Click( { sendMessage })
        $computerPage.Controls.Add($computerButton4)
        
        $computerButton5 = New-Object system.Windows.Forms.Button
        $computerButton5.text = "User"
        $computerButton5.width = 50
        $computerButton5.height = 22
        $computerButton5.location = New-Object System.Drawing.Point(440, 95)
        $computerButton5.Font = 'Microsoft Sans Serif,10'
        $computerButton5.Add_Click( { checkUser })
        $computerPage.Controls.Add($computerButton5)

        $computerButton5 = New-Object system.Windows.Forms.Button
        $computerButton5.text = "Speech"
        $computerButton5.width = 60
        $computerButton5.height = 22
        $computerButton5.location = New-Object System.Drawing.Point(500, 95)
        $computerButton5.Font = 'Microsoft Sans Serif,10'
        $computerButton5.Add_Click( { sendSpeech })
        $computerPage.Controls.Add($computerButton5)


        $computerButton6 = New-Object system.Windows.Forms.Button
        $computerButton6.text = "Update"
        $computerButton6.width = 60
        $computerButton6.height = 22
        $computerButton6.location = New-Object System.Drawing.Point(500, 95)
        $computerButton6.Font = 'Microsoft Sans Serif,10'
        $computerButton6.Add_Click( { forceUpdate })
        #$computerPage.Controls.Add($computerButton6)
        
        $computerButton7 = New-Object system.Windows.Forms.Button
        $computerButton7.text = "View Processes"
        $computerButton7.width = 120
        $computerButton7.height = 22
        $computerButton7.location = New-Object System.Drawing.Point(320, 150)
        $computerButton7.Font = 'Microsoft Sans Serif,10'
        $computerButton7.Add_Click( { getProcesses })
        $computerPage.Controls.Add($computerButton7)

        $computerButton7 = New-Object system.Windows.Forms.Button
        $computerButton7.text = "Stop Process.."
        $computerButton7.width = 120
        $computerButton7.height = 22
        $computerButton7.location = New-Object System.Drawing.Point(450, 150)
        $computerButton7.Font = 'Microsoft Sans Serif,10'
        $computerButton7.Add_Click( { stopProcesses })
        $computerPage.Controls.Add($computerButton7)

        $computerButton9 = New-Object system.Windows.Forms.Button
        $computerButton9.text = "System Error Count"
        $computerButton9.width = 140
        $computerButton9.height = 22
        $computerButton9.location = New-Object System.Drawing.Point(320, 220)
        $computerButton9.Font = 'Microsoft Sans Serif,10'
        $computerButton9.Add_Click( { applicationErrorCount })
        $computerPage.Controls.Add($computerButton9)

        $computerTextBox2 = New-Object system.Windows.Forms.TextBox
        $computerTextBox2.multiline = $false
        $computerTextBox2.text = "8"
        $computerTextBox2.width = 30
        $computerTextBox2.height = 20
        $computerTextBox2.location = New-Object System.Drawing.Point(470, 220)
        $computerTextBox2.Font = 'Microsoft Sans Serif,10'
        $computerPage.Controls.Add($computerTextBox2)

        $computerLabel1 = New-Object system.Windows.Forms.Label
        $computerLabel1.text = "Hour(s)"
        $computerLabel1.AutoSize = $true
        $computerLabel1.width = 25
        $computerLabel1.height = 10
        $computerLabel1.location = New-Object System.Drawing.Point(500, 222)
        $computerLabel1.Font = 'Microsoft Sans Serif,10'
        $computerPage.Controls.Add($computerLabel1)

        $computerButton10 = New-Object system.Windows.Forms.Button
        $computerButton10.text = "Log Off All"
        $computerButton10.width = 82
        $computerButton10.height = 22
        $computerButton10.location = New-Object System.Drawing.Point(320, 259)
        $computerButton10.Font = 'Microsoft Sans Serif,10'
        $computerButton10.Add_Click( { logOffAll })
        $computerPage.Controls.Add($computerButton10)
        
        $computerButton11 = New-Object system.Windows.Forms.Button
        $computerButton11.text = "Restart"
        $computerButton11.width = 60
        $computerButton11.height = 22
        $computerButton11.location = New-Object System.Drawing.Point(411, 259)
        $computerButton11.Font = 'Microsoft Sans Serif,10'
        $computerButton11.Add_Click( { Restart-PC })
        $computerPage.Controls.Add($computerButton11)
        
        $computerButton12 = New-Object system.Windows.Forms.Button
        $computerButton12.text = "Shut Down"
        $computerButton12.width = 82
        $computerButton12.height = 22
        $computerButton12.location = New-Object System.Drawing.Point(480, 259)
        $computerButton12.Font = 'Microsoft Sans Serif,10'
        $computerButton12.Add_Click( { Shutdown-PC })
        $computerPage.Controls.Add($computerButton12)
        
        $Groupbox1 = New-Object system.Windows.Forms.Groupbox
        $Groupbox1.height = 40
        $Groupbox1.width = 252
        $Groupbox1.location = New-Object System.Drawing.Point(315, 247)
        
        $computerPage.Controls.Add($Groupbox1)
        
        $computerPage.Controls.Add($computerDataGrid)
        
        #User Page

        $userPage.DataBindings.DefaultDataSourceUpdateMode = 0
        $userPage.UseVisualStyleBackColor = $True
        $userPage.Name = "userPage"
        $userPage.Text = "User"
        $tabControl.Controls.Add($userPage)

        $userTextBox1 = New-Object system.Windows.Forms.ComboBox
        $userTextBox1.multiline = $false
        $userTextBox1.text = "Location"
        $userTextBox1.width = 103
        $userTextBox1.height = 20
        $userTextBox1.location = New-Object System.Drawing.Point(12, 20)
        $userTextBox1.Font = 'Microsoft Sans Serif,10'
        $userTextBox1.add_selectedindexchanged( { getUsers })
     
        $userPage.Controls.Add($userTextBox1)
   

        $userTextBox2 = New-Object system.Windows.Forms.ComboBox
        $userTextBox2.multiline = $false
        $userTextBox2.text = "User"
        $userTextBox2.width = 182
        $userTextBox2.height = 20
        $userTextBox2.location = New-Object System.Drawing.Point(122, 20)
        $userTextBox2.Font = 'Microsoft Sans Serif,10'
        $userTextBox2.add_selectedindexchanged( { getUserInfo })
        $userPage.Controls.Add($userTextBox2)
       
        $userButton1 = New-Object system.Windows.Forms.Button
        $userButton1.text = "Reset Password"
        $userButton1.width = 120
        $userButton1.height = 22
        $userButton1.location = New-Object System.Drawing.Point(320, 20)
        $userButton1.Font = 'Microsoft Sans Serif,10'
        $userButton1.Add_Click( { resetPassword })
        $userPage.Controls.Add($userButton1)

        $userButton2 = New-Object system.Windows.Forms.Button
        $userButton2.text = "Unlock"
        $userButton2.width = 120
        $userButton2.height = 22
        $userButton2.location = New-Object System.Drawing.Point(450, 20)
        $userButton2.Font = 'Microsoft Sans Serif,10'
        $userButton2.Add_Click( { unlockUser })
        $userPage.Controls.Add($userButton2)

        $userButton3 = New-Object system.Windows.Forms.Button
        $userButton3.text = "Make Local Admin.."
        $userButton3.width = 250
        $userButton3.height = 22
        $userButton3.location = New-Object System.Drawing.Point(320, 70)
        $userButton3.Font = 'Microsoft Sans Serif,10'
        $userButton3.Add_Click( { makeUserLocalAdmin })
        $userPage.Controls.Add($userButton3)        

        $userButton4 = New-Object system.Windows.Forms.Button
        $userButton4.text = "Compare User Groups.."
        $userButton4.width = 250
        $userButton4.height = 22
        $userButton4.location = New-Object System.Drawing.Point(320, 100)
        $userButton4.Font = 'Microsoft Sans Serif,10'
        $userButton4.Add_Click( { compareUsers })
        $userPage.Controls.Add($userButton4)        

        $userButton5 = New-Object system.Windows.Forms.Button
        $userButton5.text = "Add to Group.."
        $userButton5.width = 120
        $userButton5.height = 22
        $userButton5.location = New-Object System.Drawing.Point(20, 285)
        $userButton5.Font = 'Microsoft Sans Serif,10'
        $userButton5.Add_Click( { addGroup })
        $userPage.Controls.Add($userButton5)

        $userButton6 = New-Object system.Windows.Forms.Button
        $userButton6.text = "Remove from Group"
        $userButton6.width = 140
        $userButton6.height = 22
        $userButton6.location = New-Object System.Drawing.Point(150, 285)
        $userButton6.Font = 'Microsoft Sans Serif,10'
        $userButton6.Add_Click( { removeGroup })
        $userPage.Controls.Add($userButton6)

        $userButton7 = New-Object system.Windows.Forms.Button
        $userButton7.text = "Add User"
        $userButton7.width = 120
        $userButton7.height = 22
        $userButton7.location = New-Object System.Drawing.Point(310, 285)
        $userButton7.Font = 'Microsoft Sans Serif,10'
        $userButton7.Add_Click( { addUser })
        $userPage.Controls.Add($userButton7)

        $userButton8 = New-Object system.Windows.Forms.Button
        $userButton8.text = "Remove User"
        $userButton8.width = 120
        $userButton8.height = 22
        $userButton8.location = New-Object System.Drawing.Point(440, 285)
        $userButton8.Font = 'Microsoft Sans Serif,10'
        $userButton8.Add_Click( { removeUser })
        $userPage.Controls.Add($userButton8)




        
        
        $userDataGrid = New-Object system.Windows.Forms.DataGridView
        $userDataGrid.width = 290
        $userDataGrid.height = 91
        $userDataGrid.location = New-Object System.Drawing.Point(12, 65)
        $userDataGrid.ColumnHeadersVisible = $false
        $userDataGrid.RowHeadersVisible = $false
        $userDataGrid.ColumnCount = 2
        $userDataGrid.RowCount = 4
        $userDataGrid.Columns[0].Width = 120
        $userDataGrid.Columns[1].Width = 167
        $userDataGrid.Rows[0].Cells[0].Value = "Username"
        $userDataGrid.Rows[1].Cells[0].Value = "Email Address"
        $userDataGrid.Rows[2].Cells[0].Value = "Department"
        $userDataGrid.Rows[3].Cells[0].Value = "Phone Number"
        $userPage.Controls.Add($userDataGrid)

        $userLabel1 = New-Object system.Windows.Forms.Label
        $userLabel1.text = "User's AD Groups"
        $userLabel1.AutoSize = $true
        $userLabel1.width = 25
        $userLabel1.height = 10
        $userLabel1.location = New-Object System.Drawing.Point(12, 164)
        $userLabel1.Font = 'Calibri,10'
        $userPage.Controls.Add($userLabel1)

        $userGroupsBox = New-Object system.Windows.Forms.ListBox
        $userGroupsBox.width = 290
        $userGroupsBox.height = 100
        $userGroupsBox.location = New-Object System.Drawing.Point(12, 185)
        $userPage.Controls.Add($userGroupsBox)
        $userGroupsBox.add_selectedindexchanged( { getGroupMembers })

        $userLabel2 = New-Object system.Windows.Forms.Label
        $userLabel2.text = "Members of Selected Group"
        $userLabel2.AutoSize = $true
        $userLabel2.width = 25
        $userLabel2.height = 10
        $userLabel2.location = New-Object System.Drawing.Point(310, 164)
        $userLabel2.Font = 'Calibri,10'
        $userPage.Controls.Add($userLabel2)

        $groupMembersBox = New-Object system.Windows.Forms.ListBox
        $groupMembersBox.width = 250
        $groupMembersBox.height = 100
        $groupMembersBox.location = New-Object System.Drawing.Point(310, 185)
        $userPage.Controls.Add($groupMembersBox)

        #Tool Page
        $toolPage.DataBindings.DefaultDataSourceUpdateMode = 0
        $toolPage.UseVisualStyleBackColor = $True
        $toolPage.Name = "toolPage"
        $toolPage.Text = "Tools"
        $tabControl.Controls.Add($toolPage)
        
        $toolButton1 = New-Object system.Windows.Forms.Button
        $toolButton1.Text = "ODBC"     
        $toolButton1.width = 104
        $toolButton1.height = 24
        $toolButton1.location = New-Object System.Drawing.Point(25, 25)
        $toolButton1.Font = 'Microsoft Sans Serif,10'
        $toolButton1.Add_Click( { odbcTool })
        $toolPage.Controls.Add($toolButton1)

        $toolButton2 = New-Object system.Windows.Forms.Button
        $toolButton2.Text = "Add Printer"     
        $toolButton2.width = 104
        $toolButton2.height = 24
        $toolButton2.location = New-Object System.Drawing.Point(25, 60)
        $toolButton2.Font = 'Microsoft Sans Serif,10'
        $toolButton2.Add_Click( { printerTool })
        $toolPage.Controls.Add($toolButton2)

        $toolButton3 = New-Object system.Windows.Forms.Button
        $toolButton3.Text = "Migrate User"     
        $toolButton3.width = 104
        $toolButton3.height = 24
        $toolButton3.location = New-Object System.Drawing.Point(25, 95)
        $toolButton3.Font = 'Microsoft Sans Serif,10'
        $toolButton3.Add_Click( { userMigrationTool })
        $toolPage.Controls.Add($toolButton3)
        
        $toolButton4 = New-Object system.Windows.Forms.Button
        $toolButton4.Text = "Local Admin"     
        $toolButton4.width = 104
        $toolButton4.height = 24
        $toolButton4.location = New-Object System.Drawing.Point(25, 130)
        $toolButton4.Font = 'Microsoft Sans Serif,10'
        $toolButton4.Add_Click( { LocalAdminTool })
        $toolPage.Controls.Add($toolButton4)
        
        $toolButton5 = New-Object system.Windows.Forms.Button
        $toolButton5.Text = "Auto Logon"     
        $toolButton5.width = 104
        $toolButton5.height = 24
        $toolButton5.location = New-Object System.Drawing.Point(25, 165)
        $toolButton5.Font = 'Microsoft Sans Serif,10'
        $toolButton5.Add_Click( { autoLogonTool })
        $toolPage.Controls.Add($toolButton5)
        
        $toolButton6 = New-Object system.Windows.Forms.Button
        $toolButton6.Text = "Admin Clean"     
        $toolButton6.width = 104
        $toolButton6.height = 24
        $toolButton6.location = New-Object System.Drawing.Point(25, 200)
        $toolButton6.Font = 'Microsoft Sans Serif,10'
        $toolButton6.Add_Click( { localAdminCleanupTool })
        $toolPage.Controls.Add($toolButton6)
        
        $toolButton7 = New-Object system.Windows.Forms.Button
        $toolButton7.Text = ""     
        $toolButton7.width = 104
        $toolButton7.height = 24
        $toolButton7.location = New-Object System.Drawing.Point(25, 235)
        $toolButton7.Font = 'Microsoft Sans Serif,10'
        $toolButton7.Add_Click( { })
        $toolPage.Controls.Add($toolButton7)
        
        $toolButton8 = New-Object system.Windows.Forms.Button
        $toolButton8.Text = ""     
        $toolButton8.width = 104
        $toolButton8.height = 24
        $toolButton8.location = New-Object System.Drawing.Point(25, 270)
        $toolButton8.Font = 'Microsoft Sans Serif,10'
        $toolButton8.Add_Click( { })
        $toolPage.Controls.Add($toolButton8)
        

        
        $OnLoadForm_StateCorrection =
        {
            $formMain.WindowState = $InitialFormWindowState
        }
        

        
    #Save the initial state of the form
    $InitialFormWindowState = $formMain.WindowState
    #Init the OnLoad event to correct the initial state of the form
    $formMain.add_Load($OnLoadForm_StateCorrection)
    #Show the Form
    $formMain.ShowDialog() | Out-Null
} #End function CreateForm
    
#Call FormCreate Function
CreateForm