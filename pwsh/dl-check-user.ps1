# Check if there is an active connection to Exchange Online
if (-not (Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange' })) {
    
    # Prompt user to connect to Exchange Online
    Connect-ExchangeOnline -UserPrincipalName michael-admin@energixrenewables.com -ShowProgress $true
} else {
    Write-Host "Active connection to Exchange Online found."
}



 
 #Define user
$userName = Read-Host "Enter user name (firstName.LastName)"
$user = "$username@energixrenewables.com"

##Add user to group(s)
###General & Administration###
Add-DistributionGroupMember -Identity "Energix US" -Member $user
Add-DistributionGroupMember -Identity "Energix HQ" -Member $user
#Add-DistributionGroupMember -Identity "Fax-US" -Member $user

#Legal
#Add-DistributionGroupMember -Identity "legal US" -Member $user

###Solar Projects Groups###
#Add-DistributionGroupMember -Identity "AdamsCommAlerts" -Member $user
#Add-DistributionGroupMember -Identity "AdamsCommOps" -Member $user
#Add-DistributionGroupMember -Identity "AdamsSettlements" -Member $user
#Add-DistributionGroupMember -Identity "AxtonCommOps" -Member $user
#Add-DistributionGroupMember -Identity "AxtonSettlements" -Member $user
#Add-DistributionGroupMember -Identity "AxtonCommAlerts" -Member $user
#Add-DistributionGroupMember -Identity "WaverlyCommAlerts" -Member $user
#Add-DistributionGroupMember -Identity "WaverlyCommOps" -Member $user
#Add-DistributionGroupMember -Identity "WaverlySettlements" -Member $user

###O&M###
#Add-DistributionGroupMember -Identity "Energix-O&M" -Member $user

###Origination###
#Add-DistributionGroupMember -Identity "Origination Team" -Member $user

###Development###
#Add-DistributionGroupMember -Identity "Development@energixrenewables.com" -Member $user
#Add-DistributionGroupMember -Identity "Environmental" -Member $user

###Finance Groups###
Add-DistributionGroupMember -Identity "Accounting US" -Member $user
#Add-DistributionGroupMember -Identity "EPC-US@energixrenewables.com" -Member $user

###EPC###
#Add-DistributionGroupMember -Identity "energix-epc@energixrenewables.com" -Member $user
#Add-DistributionGroupMember -Identity "Procurement-US" -Member $user

##HR##
#Add-DistributionGroupMember -Identity "HR-US" -Member $user


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
       