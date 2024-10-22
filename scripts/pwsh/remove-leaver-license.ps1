# Import the AzureAD module if not already imported
if (-not (Get-Module -ListAvailable -Name AzureAD)) {
    Install-Module -Name AzureAD -Force -AllowClobber
}

# Import the module
Import-Module AzureAD

# Check if there is an active connection to Azure AD
function Test-AzureADConnection {
    try {
        Get-AzureADUser -Top 1 -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

if (-not (Test-AzureADConnection)) {
    # Prompt for Azure AD login
    Connect-AzureAD
} else {
    Write-Host "Active connection to Azure AD found."
}

# Import CSV file
$csvPath = "z:\itops\csv\leavers.csv"
$leaversData = Import-Csv -Path $csvPath

# Process each leaver from the CSV
ForEach ($leaverRecord in $leaversData) {
    $user = $leaverRecord.User
    $userPrincipalName = "$user@energixrenewables.com"

    # Get the user's license details
    $userLicenses = Get-AzureADUserLicenseDetail -ObjectId $userPrincipalName

    # Remove all licenses from the user
    ForEach ($license in $userLicenses) {
        $assignedLicenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        $assignedLicenses.RemoveLicenses = @($license.SkuId)
        Set-AzureADUserLicense -ObjectId $userPrincipalName -AssignedLicenses $assignedLicenses
        Write-Host "Removed license $($license.SkuId) from user $userPrincipalName" -ForegroundColor Green
    }
}

# Disconnect from Azure AD
Disconnect-AzureAD
