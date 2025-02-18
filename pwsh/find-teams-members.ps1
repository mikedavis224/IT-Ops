41c46d92-4560-49de-8fe8-48e80cd3c063
Get-TeamUser -GroupId 41c46d92-4560-49de-8fe8-48e80cd3c063 | Select-Object UserId, User, Role | Export-Csv -Path "C:\Export\2025-Participant-NetworkingMembers.csv" -NoTypeInformation
Get-TeamUser -GroupId 41c46d92-4560-49de-8fe8-48e80cd3c063 | Select-Object @{Name="DisplayName";Expression={$_.'User'}}, @{Name="Email";Expression={$_.'UserId'}}, Role | Export-Csv -Path "C:\Export\2025-Participant-Networking-Members.csv" -NoTypeInformation
