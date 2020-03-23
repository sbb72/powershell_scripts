# set the owner on a file on a remote system.

$acl=get-acl \\SYSTEM01\test\test.log

$owner=[System.Security.Principal.NTAccount]'MYDOMIAN\user01'

$acl.SetOwner($owner)

set-acl -Path \\omega2\test\test.log -AclObject $acl

$ACL = Get-ACL .\smithb
$Group = New-Object System.Security.Principal.NTAccount("Builtin", "Administrators")
$ACL.SetOwner($Group)
Set-Acl -Path .\smithb\profile.v2 -AclObject $ACL


$acl=get-acl \\10.80.150.20\data$\tha

$owner=[System.Security.Principal.NTAccount]'Urenco\x-sbarker'

$acl.SetOwner($owner)

set-acl -Path \\10.80.150.20\data$\tha\.* -AclObject $acl