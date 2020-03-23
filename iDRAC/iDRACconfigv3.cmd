Echo OFF

Rem Define the user name to change
Set user=serveradmin

Rem Enter the CUURENT password
Set /p OldPass="Enter Current Password for iDRAC: "
Echo "Using %OldPass% as the iDRAC Password"

Rem Set the New password
Echo "Define the new password""
Set /p Pass="Enter New Password: "
Echo "Using %Pass% as the iDRAC Password"

Echo "====================="
Echo "===Starting Script==="
Echo "====================="
FOR /f %%i IN (Servers.txt) DO (

    echo %%i
	echo "Using %Pass% as the NEW iDRAC Password for %%i"
	racadm -r %%i -u %user% -p %OldPass% config -g cfgUserAdmin -i 4 -o cfgUserAdminPassword %Pass%
)