param (
    [string]$needle
)

Get-ChildItem . -Recurse | Select-String $needle | Select-Object -Unique Path
