# Check if there is an active connection to Azure AD
try {
    $currentUser = Get-AzureADSignedInUser
    if ($null -eq $currentUser) {
        throw "No active Azure AD connection found."
    } else {
        Write-Host "Active connection to Azure AD found."
    }
} catch {
    Write-Host "No active connection to Azure AD found. Connecting to Azure AD..."
    Connect-AzureAD
}

# Connect to Azure AD
Connect-AzureAD

# Define the user and new password
$userName = Read-Host "Enter username (first.last)"
$upn = "$username@energixrenewables.com"
$plainPassword = Read-Host "Enter new password"
$NewPassword = ConvertTo-SecureString -String $plainPassword -AsPlainText -force

# Change the user's password
Set-AzureADUserPassword -ObjectId $upn -Password $NewPassword 

# Force the user to change their password at next login (optional
#Set-AzureADUser -ObjectId $upn -ForceChangePasswordNextLogin $true
