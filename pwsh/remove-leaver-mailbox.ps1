#Get-Module AzureADPreview

#ModuleType Version Name                ExportedCommands
#---------- ------- ----                ----------------
#Binary     2.0.0.7 azureadpreview     {Add-AzureADAdmini...Get-Module AzureADPreview
#
#ModuleType Version Name                ExportedCommands
#---------- ------- ----                ----------------
#Binary     2.0.0.7 azureadpreview     {Add-AzureADAdmini...PS C:\Windows\system32> Install-module Microsoft.Graph# Check if there is an active connection to Exchange Online
if (-not (Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange' })) {
    
    # Prompt user to connect to Exchange Online
    Connect-ExchangeOnline -UserPrincipalName michael-admin@energixrenewables.com -ShowProgress $true
} else {
    Write-Host "Active connection to Exchange Online found."
}

#Set departed user variables
$user= Read-Host "User name (firstName.lastName)"
$leaver = "$user@energixrenewables.com"
$userMgr= Read-Host "User's manager (firstName.lastName)"
$manager = "$userMgr@energixrenewables.com"
$leaveDate = get-date -Format "MM/dd/yyyy"

<# 
##Possible loop from csv file for bulk Leavers
ForEach ($user in $leavers) {}
#>


#Convert mailbox to shared
Set-Mailbox $leaver -Type Shared 

#Fwd mail to manager
Set-Mailbox -Identity "$leaver" -DeliverToMailboxAndForward $true -ForwardingAddress $manager

#Set auto-reply 
Set-MailboxAutoReplyConfiguration -Identity $leaver -AutoReplyState Enabled -InternalMessage "Hello, 

Thank you for your message. I am no longer with Energix Renewables as of $leaveDate. For immediate assistance, please reach out to $manager.

Thank you, " -ExternalMessage "Hello, 

Thank you for your message. I am no longer with Energix Renewables as of $leaveDate. For immediate assistance, please reach out to $manager.

Thank you, ." -ExternalAudience All

#Remove from groups and lists
Try {
    
    #Get All Distribution Lists - Excluding Mail enabled security groups
    $DistributionGroups = Get-Distributiongroup -resultsize unlimited |  Where {!$_.GroupType.contains("SecurityEnabled")}
 
    #Loop through each Distribution Lists
    ForEach ($Group in $DistributionGroups)
    {
        #Check if the Distribution List contains the particular user
        If ((Get-DistributionGroupMember $Group.Name | Select -Expand PrimarySmtpAddress) -contains $leaver)
        {
            Remove-DistributionGroupMember -Identity $Group.Name -Member $leaver -Confirm:$false
            Write-host "Removed '$leaver' from group '$Group'" -f Green
        }
    }
}
Catch {
    write-host -f Red "Error:" $_.Exception.Message
}

#Remove calendar events
Remove-CalendarEvents -Identity $leaver -CancelOrganizedMeetings -QueryStartDate (Get-Date) -QueryWindowInDays 365
Write-Host "Removed meetings hosted by" $leaver -f Magenta