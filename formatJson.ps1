[CmdletBinding()]

param (
    [string]$file,
    [switch]$compress
)

if ($compress) {
    Get-Content -Path $file -Raw | ConvertFrom-Json | ConvertTo-Json -Depth 100 -Compress | Set-Content -Path $file
}
else {
    Get-Content -Path $file -Raw | ConvertFrom-Json | ConvertTo-Json -Depth 100 | Set-Content -Path $file
}
