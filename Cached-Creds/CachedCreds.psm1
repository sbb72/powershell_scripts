function Write-SavedCreds {
 
Param (
[Parameter(Mandatory=$false)]
[ValidateNotNullOrEmpty()]
[Management.Automation.PSCredential]$Credential,


[Parameter(Mandatory=$false)]
[ValidateNotNullOrEmpty()]
[String]$CachedCreds
)
 
$RegPath = "HKCU:\Software\PSCredentials"
[Void](Get-Item HKCU:\).OpenSubKey('SOFTWARE',$true).CreateSubKey('PSCredentials')
 
    If ($CachedCreds) {
 
        $Credential = $Host.UI.PromptForCredential($MyInvocation.MyCommand.Name,'Enter credentials to save','','')
 
        $RegPath = "HKCU:\Software\PSCredentials\$CachedCreds"
        [Void](Get-Item HKCU:\).OpenSubKey('SOFTWARE\PSCredentials',$true).CreateSubKey("$CachedCreds")
        $UserName = $Credential.UserName.TrimStart('\')
        Set-ItemProperty -LiteralPath "$RegPath" -Name "$CachedCreds`_User" -Value $UserName
        Set-ItemProperty -LiteralPath "$RegPath" -Name "$CachedCreds`_Password" -Value $($Credential.Password | ConvertFrom-SecureString)
 
        Write-Verbose "Saved $CachedCreds password for user $UserName"
    }
    Else {
 
    Write-Host "No switch specified" -ForegroundColor Red
 
    }
 
}
 
function Read-SavedCreds {
Param
(
    [Parameter(Mandatory=$false)]
       [ValidateNotNullOrEmpty()]
    [String]$CachedCreds
)
   
$RegPath = "HKCU:\Software\PSCredentials"
[Void](Get-Item HKCU:\).OpenSubKey('SOFTWARE',$true).CreateSubKey('PSCredentials')
 
    if($CachedCreds) {
 
        if(Test-Path -Path "HKCU:\Software\PSCredentials\$CachedCreds" -ErrorAction SilentlyContinue)
        {
            $Password = (Get-ItemProperty -LiteralPath "$RegPath\$CachedCreds")."$CachedCreds`_Password"
            $User = (Get-ItemProperty -LiteralPath "$RegPath\$CachedCreds")."$CachedCreds`_User"
               return $(New-Object Management.Automation.PSCredential $User, $($Password | ConvertTo-SecureString))
 
        }
 
    }
   
    Else {
 
    Write-Host "No switch specified" -ForegroundColor Red
 
    }
 
 
}

<# 
$MyCreds =@{}
 
$Creds = Read-SavedCreds -CachedCreds "ScottDomain"
 
$MyCreds = @{Credential=$Creds}

connect-ciserver -computer @MyCreds 
#>
