# install latest powershell

[CmdletBinding()]

param (
    [ValidateSet("install", "i", "uninstall", "list", "l", IgnoreCase = $false)]
    [string]$action,
    [switch]$version
)

#TODO create usage function and help option

$versionNumber = "1.1.0";

if ($version) {
    Write-Output $versionNumber
    Exit
}

switch ($action) {
    { "i", "install" -eq $_ } {
        winget install --id Microsoft.Powershell --source winget
    }
    "uninstall" {
        winget uninstall Microsoft.PowerShell
    }
    { "l", "list" -eq $_ } {
        winget list powershell
    }
    Default { Write-Warning "Please provide an action" }
}
