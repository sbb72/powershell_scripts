## Running the report

It is required to run the script for each server detailed in the surf form.
Follow the procedure below to generate the report

--------------------------------------------------------------------------------------------------------------------------
The following need to be copied from this repository to the server where the checks are to be completed:

    - HtmlReportHeader.html (file)
    - main.ps1 (file)
    - ImportExcel/4.0.9 (folder)
    - SAChecksModule (folder)

--------------------------------------------------------------------------------------------------------------------------

1 - Log in to the server and ensure the surf form is located at a location where it can be reachable from the server and run the main.ps1 file. 
When the script launches file selection dialog box will be display. Use the dialog box to browse to the location where the surf form is located and select the surf form.
			
2- Once reading the surf form,  configuration collection from the server and comparison operations are completed by the script 'Save As' dialog box will be display for saving the result in report. Browse to the location where you want to save the report, type a file name and save the report.

## Viewing the report

The report consists of 9 sections. Below are the names and the description of the information displayed in each section.
- **Surf and Server Config Differences:** The Difference identified between the Surf Form and the server's configuration. If there are no differences, nothing will be displayed in the section.

- **Server Details:** The configuration information collected from the server to be used for the comparison.
- **Surf Form:** The data exported from the surf to be used for the comparison
- **Check Installed Software:** Prerequisite software installed on the server
- **Services:** Services that are set to auto start but not running
- **Events:** Most recent error message from the event log
- **Devices:** Drivers that are installed on the server 
- **Apps:** Total list of software installed on the server
- **Patches and Service Packs:** Total list of updated, patches and service packs installed on the server

	

		
		
		
		
	
