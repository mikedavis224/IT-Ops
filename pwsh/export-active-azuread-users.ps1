#Import-Module Microsoft.Graph
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
