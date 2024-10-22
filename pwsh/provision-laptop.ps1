<#
_____________________________________________________________
|Script to install core applications                        | 
|Should be run as assigned user AFTER join-to-domain.ps1    |
|___________________________________________________________|

#>


$newPath = "c:\prov\core"

#Block Win11 update
#.\"BlockWin11.reg" -wait

#Box
#mkdir "c:\bcloud" -Verbose
#.\"boxfolder&lock.reg" -wait
#start-process "$newpath\box-x64.msi" -wait

#CrowdStrike
Start-process "$newPath\cs-install.bat" -wait

#Chrome
start-process "$newPath\chromesetup.exe" -wait

#GoogleEarthPro
Start-Process "$newPath\GoogleEarthProSetup.exe" -wait

#MS Teams for work
start-process "$newPath\MSTeams-x64.msix" -wait

#UniFlow client
#start-process "$newPath\MomSmartClient_x64_1_0_6.msi" -wait

#AnyDesk
start-process "$newPath\AnyDesk_Custom_client.exe" -wait

#Adobe Reader
#Start-Process "$newPath\Reader_Install_Setup.exe" -Wait

#Adobe Acrobat 
#Start-Process "$newPath\Acrobat_Set-Up.exe" -Wait

#Copy IT Training folder 
copy-item -path "c:\prov\core\IT Training Folder - Powered by Box.url" -Destination "c:\Users\$env:username\desktop"

#App install complete message
write-host "Core applications have been installed. Windows updates will be downloaded and installed after next reboot."

#Install Windows update
Install-PackageProvider -Name NuGet -Force
Install-Module -Name PSWindowsUpdate -Force
Import-Module PSWindowsUpdate
Get-WindowsUpdate
Install-WindowsUpdate -AcceptAll -AutoReboot

#End of script
Write-host "Laptop provision complete"
