
.0# Check if there is an active connection to Exchange Online
if (-not (Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange' })) {
    
    # Prompt user to connect to Exchange Online
    Connect-ExchangeOnline -UserPrincipalName michael-admin@energixrenewables.com -ShowProgress $true
} else {
    Write-Host "Active connection to Exchange Online found."
}
#Set Variables
$group = Read-Host "Enter DL list email"
$listDate = get-date -UFormat "%Y-%m-%d"
$csvName = "$listDate-$group-members"
$csvPath = "z:\itops\csv\dl\$csvName.csv"

#Return members and save to csv
 Get-DistributionGroupMember -Identity $group  -ResultSize Unlimited | Select DisplayName, PrimarySMTPAddress | export-csv -Path $csvPath -NoTypeInformation

 #Open exported file
 Invoke-Item $csvPath 

 #user notification
 Write-Host "Distribution List export complete"
 