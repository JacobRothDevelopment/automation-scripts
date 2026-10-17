param (
    [string]$needle,
    [switch]$version,
    [switch]$help
)

#region globals

$versionNumber = "1.0.0"

#endregion

if ($help) {
    Write-Output "Counts the files in a directory and it's subdirectories`r`n`r`n wintree [string to search for (optional)]"
    Exit
}

if ($version) {
    Write-Output $versionNumber
    Exit
}

(Get-ChildItem -Path . -Filter $needle -Recurse -File).Count
