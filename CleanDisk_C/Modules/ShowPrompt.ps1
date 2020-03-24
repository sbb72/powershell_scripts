function Show-Prompt ($title, $message){

    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel", `
    "Cancel script execution"

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes1", `
        "Yes"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($no, $yes)
    return $host.ui.PromptForChoice($title, $message, $options, 0) 
}

