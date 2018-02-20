Write-Host "Kicking Off IIS Installer Script"
PowerShell -file "ComponentScripts\Install_IIS.ps1"

Write-Host "Kicking Off Create Certs PowerShell Script"
PowerShell -file "ComponentScripts\CreateCerts.ps1"

Write-Host "Kicking Off Chocolatey Install Script"
PowerShell -file "ComponentScripts\DeveloperChocolateInstall.ps1"

Write-Host "Setting All Visual Studio Instances To Run as Admin"
PowerShell -file "ComponentScripts\SetVisualStudioToRunAsAdmin.ps1"