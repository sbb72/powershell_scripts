function Write-ErrorMessage 
{
<#

.SYNOPSIS
Write a non-terminating error message to the error stream.

.DESCRIPTION
This function writes a non-terminating error to the error stream.

Upto three distinct text messages can be incorporated in the error.
 
The error can be categorised as either INFO, WARNING or ERROR (default ERROR).

The function that calls this function is identified in the error.


.PARAMETER messageText
The main error text.  A default message is used if a message is not provided.

.PARAMETER CategoryTargetType
A second message to compliment the error text.  A default message is used if text is not provided.

.PARAMETER CategoryReason
A third message to compliment the error text.  A default message is used if a text is not provided.

.PARAMETER ErrorId
One of INFO, WARNING or ERROR.  No other value is valid.  ERROR is used if a value is not provided.

.PARAMETER Category
Can only be an excepted value of the Write-Error cmdlet optional parameter Category 
e.g. OpenError, CloseError, InvalidData, InvalidType, ParseError, ResourceBusy, FromStdErr, etc.
FromStdErr is used if a value is not provided.


.EXAMPLE
Write-ErrorMessage "This is an error message"

.EXAMPLE
Write-ErrorMessage "This is an error message" -ErrorId INFO

.EXAMPLE
Write-ErrorMessage "This is an error message" "Additional text about the error" -ErrorId WARNING

.EXAMPLE
Write-ErrorMessage "This is an error message" "Additional text about the error" "Further information about the error" ERROR

.EXAMPLE
Write-ErrorMessage "This is an error message" "Additional text about the error" "Further information about the error" ERROR InvalidData

.EXAMPLE
Write-ErrorMessage "This is an error message" -CategoryTargetType "Additional text about the error" -CategoryReason "Further information about the error" -Category InvalidData

.EXAMPLE
$text | Write-ErrorMessage

.EXAMPLE
Get-Content textfile.txt | Write-ErrorProg

.EXAMPLE
Write-ErrorMessage "This is an error message" -WhatIf


.NOTES
A message, or text string, can be piped into this function.
The content of a text file can be piped in to this function resulting in an individual error for each line of the file.
Each line of text in the file is piped in to the parameter $messageText.

#>

  [CmdletBinding(SupportsShouldProcess)]

  param(
    [Parameter(Position=0,ValueFromPipeline=$True)]
    [String]
    $messageText = "Message text was not provided.",
    
    [Parameter(Position=1)]
    [String]
    $CategoryTargetType = "No additional information",

    [Parameter(Position=2)]
    [String]
    # maximum 41 characters
    $CategoryReason = "No additional information",

    [Parameter(Position=3)]
    [ValidateSet("ERROR","WARNING","INFO")]
    [String]
    $ErrorId = "ERROR",

    [Parameter(Position=4)]
    [String]
    # can only be one of the excepted values of the optional parameter Category
    # e.g. OpenError, CloseError, InvalidData, InvalidType, ParseError, ResourceBusy, FromStdErr, etc.
    $Category = "FromStdErr",

    [String]
    # This will typically identify the function that called this function
    $CategoryTargetName = "unknown"
    )

    Process {
      If ($PSCmdlet.ShouldProcess($messageText, "Write an error made of up to three sets of text to the Error stream")) {

        # Identify the function that called this function
        $FunctionName = $((Get-PSCallStack)[1].FunctionName)
        $CategoryTargetName = $FunctionName

        # Construct an ErrorRecord object
        $ErrorRecordObject = New-Object Management.Automation.ErrorRecord $messageText, $ErrorId.ToUpper(), $Category, $CategoryTargetName

        # write the error to the error stream
        Write-Error -ErrorRecord $ErrorRecordObject -CategoryTargetType $CategoryTargetType -CategoryReason $CategoryReason
        }
      }
}