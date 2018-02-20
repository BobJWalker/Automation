Write-Host "Finding all installed versions of Visual Studio"

$visualStudioInstances = Get-ChildItem -Path "C:\Program Files (x86)\" -Filter devenv.exe -Recurse -ErrorAction SilentlyContinue -Force | %{$_.FullName}

Write-Host "Found the following Visual Studio $visualStudioInstances instances"  

$pathToCheck = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
$pathExists = Test-Path -Path $pathToCheck

if ($pathExists -eq $false)
{
    Write-Host "The registry path $pathToCheck does not exist, creating now"
    New-Item -Path $pathToCheck -Force
}

$compabilityItems = Get-ItemProperty $pathToCheck

foreach ($visualStudioPath in $visualStudioInstances)
{
    if ($compabilityItems.$visualStudioPath -eq $null)
    {
        Write-Host "Visual Studio at $visualStudioPath is not set to run as Admin, doing that now" 
        New-ItemProperty -Path $pathToCheck -Name $visualStudioPath -Value "^ RUNASADMIN" -PropertyType String -Force
    }
    else{
        Write-Host "Visual Studio at $visualStudioPath is already set to run as Admin"
    }
}