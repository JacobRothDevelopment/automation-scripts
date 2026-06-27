param (
    [string]$needle,
    [switch]$version,
    [switch]$help
)

#region globals

$versionNumber = "2.0.0"

#endregion

if ($help) {
    Write-Output "Searches the current directory file with a given pattern`r`n`r`n winfind [file to search for]"
    Exit
}

if ($version) {
    Write-Output $versionNumber
    Exit
}

Get-ChildItem -Path . -Filter $needle -Recurse | Select-Object FullName
