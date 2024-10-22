<#
__________________________________________________________________
|Script to prepare the device for provisioning                    | 
|Should be run BEFORE prep-laptop.ps1 & BEFORE join-to-domain.ps1 |
|________________________________________________________________ |

#>
#map to prov folder
net use P: \\10.1.10.33\prov

#Copy provisioning folder to target
mkdir c:\prov
$prov = "c:\prov"
$core = "p:\core"
Copy-Item -path $core -Destination $prov -Recurse -Verbose


#Set TimeZone
Set-TimeZone -ID "US Eastern Standard Time" 



Start-process "c:\prov\core\cs-install.bat" -wait

#set computer name
$serial = (get-wmiobject -class win32_bios).SerialNumber
$newName = "usit-$serial"
Rename-Computer -NewName $newName -force -restart

