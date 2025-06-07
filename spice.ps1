<#
shortcut for working with spicetify
https://spicetify.app/
#>

[CmdletBinding()]

param (
    [ValidateSet("install", "uninstall", "upgrade", "update", "up", IgnoreCase = $false)]
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
        Invoke-WebRequest -useb https://raw.githubusercontent.com/spicetify/cli/main/install.ps1 | Invoke-Expression
        Invoke-WebRequest -useb https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.ps1 | Invoke-Expression
    }
    "uninstall" {
        spicetify restore
        Remove-Item -r -fo $env:APPDATA\spicetify
        Remove-Item -r -fo $env:LOCALAPPDATA\spicetify
    }
    { @("upgrade", "update", "up") -contains $_ } {
        # upgrade spicetify
        spicetify upgrade

        # apply all the things
        spicetify restore backup apply
    }
    Default { Write-Warning "Please provide an action" }
}
