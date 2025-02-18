# Prompt user for admin credentials
$adminUser = Read-Host "Enter your Exchange Online admin UPN (e.g., admin@example.com)"

# Check if there is an active connection to Exchange Online
if (-not (Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange' })) {
    # Connect to Exchange Online with user input
    Connect-ExchangeOnline -UserPrincipalName $adminUser -ShowProgress $true
} else {
    Write-Host "Active connection to Exchange Online found."
}

# Prompt user for the new user information
$userName = Read-Host "Enter user name (FirstName.LastName)"
$domain = Read-Host "Enter your organization domain (e.g., example.com)"
$user = "$userName@$domain"

Write-Host "Adding user '$user' to distribution groups..."

<# List of groups to add the user to (Uncomment or modify as needed) REPLACE WITH CLIENT DL's
$groups = @(
    "Energix US",
    "Energix HQ",
    #"Fax-US",
    #"Legal US",
    #"AdamsCommAlerts",
    #"AdamsCommOps",
    #"AdamsSettlements",
    #"AxtonCommOps",
    #"AxtonSettlements",
    #"AxtonCommAlerts",
    #"WaverlyCommAlerts",
    #"WaverlyCommOps",
    #"WaverlySettlements",
    #"Energix-O&M",
    #"Origination Team",
    #"Development@energixrenewables.com",
    #"Environmental",
    "Accounting US"
    #"EPC-US@energixrenewables.com",
    #"energix-epc@energixrenewables.com",
    #"Procurement-US",
    #"HR-US"
)

# Add user to specified distribution groups
foreach ($group in $groups) {
    try {
        Add-DistributionGroupMember -Identity $group -Member $user
        Write-Host "Successfully added $user to $group" -ForegroundColor Green
    } catch {
        Write-Host "Failed to add $user to $group: $_" -ForegroundColor Red
    }
} #>

#Get All Distribution Lists - Excluding Mail enabled security groups
$DistributionGroups = Get-Distributiongroup -resultsize unlimited |  Where-object {!$_.GroupType.contains("SecurityEnabled")}
    
Write-Host "'$user' is a member of the following groups: `n" -f White

#Loop through each Distribution Lists#Loop through each Distribution Lists
ForEach ($Group in $DistributionGroups)
{
    #Check if the Distribution List contains the particular user
    If ((Get-DistributionGroupMember $Group.Name | Select-object -Expand PrimarySmtpAddress) -contains $user){
    Write-host " '$Group'" -f Green       
    
    }
   }
# Write-host "Distribution list check complete"