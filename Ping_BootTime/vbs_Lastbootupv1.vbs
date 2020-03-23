'############################################
'* File: vbs_Lastbootup.vbs
'* Author: SBarker
'* Version 1.0
'* Date 18-02-2014
'* Main Function: Displays the last reboot time of a computer
'********************************************************************

On Error Resume Next
Const ForReading = 1
Set objFSO = CreateObject("Scripting.FileSystemObject")
'Get list of servers
Set objTextFile = objFSO.OpenTextFile("D:\AD_Scripts\Server_Reboot_Check\ServerGP1.txt", ForReading)
Set outfile = objFSO.CreateTextFile("UptimeResult.txt")

Do Until objTextFile.AtEndOfStream 
    strComputer = objTextFile.Readline
	Set objWMIService = GetObject ("winmgmts:\\" & strComputer & "\root\cimv2")
	'Checking for a WMI connection
	If (Err.number <> 0) Then
	Wscript.echo strComputer & " Not Found"
	OutFile.WriteLine strComputer & " Not Found"
	ELSE
	
	Set colOperatingSystems = objWMIService.ExecQuery ("Select * from Win32_OperatingSystem")
	
	For Each objOS in colOperatingSystems
		dtmBootup = ""
		dtmBootup = objOS.LastBootUpTime
		dtmLastBootupTime = WMIDateStringToDate(dtmBootup)
		dtmSystemUptime = DateDiff("h", dtmLastBootUpTime, Now)
		
		OutFile.WriteLine strComputer & ",Up for " & dtmSystemUptime & " Hours" & "," & dtmLastBootupTime
		Wscript.echo strComputer & ",Up for " & dtmSystemUptime & " Hours" & "," & dtmLastBootupTime
		   
	Next
	End If
Loop
objTextFile.Close

Wscript.echo "Script Completed. See UptimeResult.txt"

' Function to convert UNC time to readable format
Function WMIDateStringToDate(dtmBootup)
    WMIDateStringToDate = CDate(Mid(dtmBootup, 5, 2) & "/" & _
         Mid(dtmBootup, 7, 2) & "/" & Left(dtmBootup, 4) _
         & " " & Mid (dtmBootup, 9, 2) & ":" & _
         Mid(dtmBootup, 11, 2) & ":" & Mid(dtmBootup, _
         13, 2))
End Function
