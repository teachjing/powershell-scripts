# powershell-scripts
Powershell scripts I made that I use and can call upon when I need it. 
Im slowly importing all my modules so follow to stay up to date.

Load the CoreCustom.psm1 Module and then use it to load any .psm1 modules

Example

#Loads a module
Import-Module ".\RandomGeneratedUser.psm1" -Force #loads the module and force it to reload if changes are made.

#Run command
New-RandomGeneratedUser -domain "test.com"

This generates a random user data using the rest api of https://randomuser.me