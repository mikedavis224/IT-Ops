# Check if there is an active connection to Exchange Online
if (-not (Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange' })) {
    
    # Prompt user to connect to Exchange Online
    Connect-ExchangeOnline -UserPrincipalName michael-admin@energixrenewables.com -ShowProgress $true
} else {
    Write-Host "Active connection to Exchange Online found."
}


$UserToRemove = "leah.powers@energixrenewables.com"
Try {
    
    #Get All Distribution Lists - Excluding Mail enabled security groups
    $DistributionGroups = Get-Distributiongroup -resultsize unlimited |  Where {!$_.GroupType.contains("SecurityEnabled")}
 
    #Loop through each Distribution Lists
    ForEach ($Group in $DistributionGroups)
    {
        #Check if the Distribution List contains the particular user
        If ((Get-DistributionGroupMember $Group.Name | Select -Expand PrimarySmtpAddress) -contains $UserToRemove)
        {
            Remove-DistributionGroupMember -Identity $Group.Name -Member $UserToRemove -Confirm:$false
            Write-host "Removed '$UserToRemove' from group '$Group'" -f Green
        }
    }
}
Catch {
    write-host -f Red "Error:" $_.Exception.Message
}

<#
Try {
#Connect to Entra ID
Connect-AzureAD

#Get All Entra ID groups
$AzureGroups = Get-AzureADGroup -All

#Loops through each Az Group
ForEach ($Group in $AzureGroups)
{
    #Check if the Entra ID group contains the particular user
    If ((Get-AzureAdGroup $Group.Name | Select -Expand PrimarySmtpAddress) -contains $UserToRemove)
    {
        Remove-AzureAdGroupMember -ObjectId 
        #>

Remove-CalendarEvents -Identity $UserToRemove -CancelOrganizedMeetings -QueryStartDate (Get-Date) -QueryWindowInDays 365
Write-Host "Removed meetings hosted by" $UserToRemove -f Magenta