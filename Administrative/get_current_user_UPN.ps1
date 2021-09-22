# 1
$env:UserName

# 2
[System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# 3
[Environment]::UserName

# 4
$(Get-WMIObject -class Win32_ComputerSystem | select username).username

<#
([ADSI]"LDAP://<SID=$([System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value)>").UserPrincipalName

$([System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value)

([ADSI]"LDAP://<SID=$([System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value)>")
#>