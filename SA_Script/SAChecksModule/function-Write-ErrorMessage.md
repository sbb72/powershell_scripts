# function Write-ErrorMessage
*Write-ErrorMessage* uses the cmdlet ‘Write-Error’ to write a non-terminating error message to the error message stream (and $error).

Error messages are structured in a standard format using input parameters and default values in their absence.

Up to three distinct messages can be incorporated in the error.  The function will work with one, two or three messages.

The error message will be categorised as INFO, WARNING or ERROR.  The function defaults to ERROR if no other value is provided.

The error message will also identify the function from which it was called (if called by a function).

## Input Parameters
Six input parameters are declared.  None of the parameters are mandatory.  However, *Write-ErrorMessage* output will be of little use if a message is not provided in the first parameter **messageText** (position 0).

The parameters **CategoryTargetType** and **CategoryReason** can be used to provide extra information about the error.  Default values are used if none are provided.
The parameter **CategoryTargetName** (declared last) is configured by *Write-ErrorMessage*.  An input value is not expected.

The input parameters have the same names as the required and optional parameters of ‘Write-Error’, apart from *messageText* which correlates with ‘Message’.

### Parameter Descriptions
**messageText**:
The main error text.  A default message is used if a message is not provided.

**CategoryTargetType**:
A second message to compliment the error text.  A default message is used if text is not provided.

**CategoryReason**:
A third message to compliment the error text.  A default message is used if a text is not provided.

**ErrorId**:
One of INFO, WARNING or ERROR.  No other value is valid.  ERROR is used if a value is not provided.

**Category**:
Can only be an excepted value of the ‘Write-Error’ cmdlet optional parameter ‘Category’ e.g. OpenError, CloseError, InvalidData, InvalidType, ParseError, ResourceBusy, FromStdErr, etc.
FromStdErr is used if a value is not provided.


**CategoryTargetName**:
Used to identify the function that called *Write-ErrorMessage*. The value is calculated by *Write-ErrorMessage*.


## Examples
``` powershell
Write-ErrorMessage "This is an error message"
```
``` powershell
Write-ErrorMessage "This is an error message" -ErrorId INFO
```
``` powershell
Write-ErrorMessage "This is an error message" "Additional text about the error" -ErrorId WARNING
```
``` powershell
Write-ErrorMessage "This is an error message" "Additional text about the error" "Further information about the error" ERROR
```
``` powershell
Write-ErrorMessage "This is an error message" "Additional text about the error" "Further information about the error" ERROR InvalidData
```
``` powershell
Write-ErrorMessage "This is an error message" -CategoryTargetType "Additional text about the error" -CategoryReason "Further information about the error" -Category InvalidData
```
``` powershell
Write-ErrorMessage "This is an error message" –WhatIf
```
``` powershell
$text | Write-ErrorMessage
```
``` powershell
Get-Content textfile.txt | Write-ErrorMessage
```

Messages can be piped in to *Write-ErrorMessage* as shown in the last two examples.  Each line of testfile.txt will be piped in to *Write-ErrorMessage* and treated as a separate error.


## Example Error Messages
The error messages below are produced when *Write-ErrorMessage* is called as shown from the function func-Z.

### Exampe 1

``` powershell
Write-ErrorMessage "ABC Failed" "Additional failure information" "Further failure information" INFO
```

```
Write-ErrorMessage : ABC Failed
At line:24 char:1
+ Write-ErrorMessage "ABC Failed" "Additional failure information" "Further failur ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : FromStdErr: (func-Z:Additional failure information) [Write-Error], Further failure information
    + FullyQualifiedErrorId : INFO,Write-ErrorMessage
```
  
### Exampe 2

``` powershell
Write-ErrorMessage "ABC Failed"
```

```
Write-ErrorMessage : ABC Failed
At line:25 char:1
+ Write-ErrorMessage "ABC Failed"
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : FromStdErr: (func-Z:No additional information) [Write-Error], No additional information
    + FullyQualifiedErrorId : ERROR,Write-ErrorMessage
```
