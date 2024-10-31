function Add-CalendarDelegate {
    param (
        [Parameter(Mandatory = $false)]
        [string]$AccessRights = "Reviewer"
    )

    # Prompt the user for the executive's mailbox and delegate email
    $exec = Read-Host "Enter the executive's firstName.Lastname"
    $ExecutiveMailbox = "$exec@energixrenewables.com"
    $delegate = Read-Host "Enter the delegate's firstName.Lastname"
    $DelegateEmail = "$delegate@energixrenewables.com"

    # Check if the session is already connected
    <#if (-not (Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange' })) {
        # Connect to Exchange Online
        $UserCredential = Get-Credential -Message "Enter your Microsoft 365 admin credentials"
        Connect-ExchangeOnline -Credential $UserCredential
    }#>
    

    try {
        # Set permissions on the executive's calendar folder
        Add-MailboxFolderPermission -Identity "${ExecutiveMailbox}:\Calendar" -User $DelegateEmail -AccessRights $AccessRights
        Write-Host "Successfully added $DelegateEmail as a delegate with $AccessRights access to $ExecutiveMailbox's calendar." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to add delegate. Error: $_" -ForegroundColor Red
    }
    
}
