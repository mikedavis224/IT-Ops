<#
 ___________________________________________________
|                                                   |
|The following script adds a designated delegate to |
|a specified user's calendar with full access.      |  
|___________________________________________________|
#>

#import and connect to exchange online module
Import-Module ExchangeOnlineManagement

# Check if there is an active connection to Exchange Online
if (-not (Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange' })) {
    
    # Prompt user to connect to Exchange Online
    Connect-ExchangeOnline -UserPrincipalName michael-admin@energixrenewables.com -ShowProgress $true
} else {
    Write-Host "Active connection to Exchange Online found."
}

#Define variables

$boss = Read-Host "Enter ID of calendar to be managed (first.last)"
$aa = Read-Host "Enter ID of delegate to manage calendar (first.last)"
$exec = "$boss@energixrenewables.com"
$delegate = "$aa@energixrenewables.com"

#Grant delegate access
Add-MailboxFolderPermission -Identity "${exec}:\Calendar" -User $delegate -AccessRights Editor

#Allow delegate to accept/decline meetings
Set-CalendarProcessing -Identity $exec -ResourceDelegates $delegate -
AllRequestOutofPolicy: $false

