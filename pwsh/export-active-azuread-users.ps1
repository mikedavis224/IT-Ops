﻿#Import-Module Microsoft.Graph
#Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All", "AuditLog.Read.All"
##Export Active Users Who Logged in Within the Last 60 Days

# Define the date range (60 days ago)
$startDate = (Get-Date).AddDays(-60).ToString("yyyy-MM-ddTHH:mm:ssZ")

# Get all successful sign-ins within the last 60 days
$signIns = Get-MgAuditLogSignIn -Filter "CreatedDateTime ge $startDate and Status/ErrorCode eq 0" -All

# Get a list of unique user IDs from the sign-in logs
$activeUserIds = $signIns | Select-Object -ExpandProperty UserId -Unique

# Get enabled users and filter those who have logged in
$enabledUsers = Get-MgUser -Filter "AccountEnabled eq true" -All | Where-Object { $_.Id -in $activeUserIds }

# Export to CSV
$enabledUsers | Select-Object DisplayName, UserPrincipalName, Mail, Id | Export-Csv -Path "C:\Export\AIR\EnabledUsers_Last60Days.csv" -NoTypeInformation

Write-Host "Export complete. File saved to C:\Export\AIR\EnabledUsers_Last60Days.csv"

## User Authentication and Sign-ins

# Get active users who have not logged in for 90 days or more
$thresholdDate = (Get-Date).AddDays(-90).ToString("yyyy-MM-ddTHH:mm:ssZ")
$allUsers = Get-MgUser -Filter "AccountEnabled eq true" -All
$inactiveUsers = @()

foreach ($user in $allUsers) {
    $lastSignIn = Get-MgAuditLogSignIn -Filter "UserPrincipalName eq '$($user.UserPrincipalName)'" | Sort-Object CreatedDateTime -Descending | Select-Object -First 1 CreatedDateTime
    
    if ($lastSignIn -eq $null -or $lastSignIn.CreatedDateTime -lt $thresholdDate) {
        $inactiveUsers += [PSCustomObject]@{
            DisplayName = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            LastSignInDate = if ($lastSignIn -ne $null) { $lastSignIn.CreatedDateTime } else { "Never Signed In" }
        }
    }
}

# Export inactive users to CSV
$inactiveUsers | Export-Csv -Path "C:\Users\InactiveUsers_Last90Days.csv" -NoTypeInformation

Write-Host "Export complete. File saved to C:\Users\InactiveUsers_Last90Days.csv"