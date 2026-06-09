param (
    [string]$needle
)

Get-ChildItem -Path . -Filter $needle -Recurse
