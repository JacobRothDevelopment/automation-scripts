# install latest powershell

[CmdletBinding()]

param (
    [ValidateSet("install", "uninstall", "list", IgnoreCase = $false)]
    [string]$action,
    [switch]$version
)

#TODO create usage function and help option

$versionNumber = "1.0.0";

if ($version) {
    Write-Output $versionNumber
    Exit
}

switch ($action) {
    "install" {
        winget install --id Microsoft.Powershell --source winget
    }
    "uninstall" {
        winget uninstall Microsoft.PowerShell
    }
    "list" {
        winget list powershell
    }
    Default { Write-Warning "Please provide an action" }
}
