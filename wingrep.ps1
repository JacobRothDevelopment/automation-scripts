param (
    [string]$needle,
    [switch]$version,
    [switch]$help
)

#region globals

$versionNumber = "2.0.0"

#endregion

if ($help) {
    Write-Output "Searches the current directory for a given string`r`n`r`n wingrep [string to search for]"
    Exit
}

if ($version) {
    Write-Output $versionNumber
    Exit
}

# Get-ChildItem . -Recurse | Select-String $needle | Select-Object -Unique Path
Get-ChildItem . -Recurse | Select-String $needle | Select-Object LineNumber, Line, @{Name = "RelativePath"; Expression = { (Resolve-Path $_.Path -Relative) } }
