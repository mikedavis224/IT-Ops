<#
_________________________________________________________________
|Script to assign device to user                                 | 
|Should be run AFTER prep-laptop.ps1 & AFTER join-to-domain.ps1  |
|________________________________________________________________|

#>

#define variables
$first = read-host "Enter the first initial of assigned user's first name"
$last = read-host "Enter the assigned user's last name"
$model = read-host "Enter the short model name for this computer (X1, E14,etc)"
$newName = "$first$last-$model"

#assign user as local admin
$username = Read-Host "Enter username (first.last)"
Add-LocalGroupMember -Group "Power Users" -Member "$username@energixrenewables.com" -wait

#rename device
Rename-Computer -NewName $newName -force -restart