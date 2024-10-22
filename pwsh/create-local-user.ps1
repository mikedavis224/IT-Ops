#Create local accounts

$pw = Read-host   -AsSecureString
$params = @{
    Name = 'EnergixStaff'
    Password = $pw
    FullName = 'Energix Staff'
    Description = 'Energix Staff Account'
    PasswordNeverExpires = $true

}

New-LocalUser @params
Addd-LocalGroupMember -Group "Power Users" -Member "EnergixStaff"
Get-LocalGroupMember -Group "Power Users"