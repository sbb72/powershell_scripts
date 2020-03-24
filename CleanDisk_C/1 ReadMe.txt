*** This script should be run from this folder, there is no need to copy it anywhere else for GREENLNK
Only this location will be updated with future releases. ***

Script can be copied to other domains to be run, but this is the master and the only script that will get updated.

Script written by Serhat Damlica (iSolve)
--------------------------------------------------------------------------------
OPTIONS:-
	Directories.CSV - contains list of directories to be used in script
		DELETE		- yes to delete folder
		COMPRESS	- yes to compress folder
		GET SIZE		- yes to log size to output file

FOLDERS:-
	Logs	-	contains log file from each run of script
	Reports	-	results file in CSV format for each run of script
--------------------------------------------------------------------------------
Run by selecting main.ps1 with right button and choose Run with PowerSHELL.
Type Single or List depending on option you need

LIST 	- will prompt for file which should contain a simple list of servers to check
SINGLE	- will prompt for hostname to check
	
Script will then run and output log will be produce in same folder as script, filename is date/time script was run.

Script also produces the results in a CSV file, prompt for filename will appear when script has finished.


+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Update Log
	21st march 2019 - added Logs & Reports folder output
			- removed prompt for output file name