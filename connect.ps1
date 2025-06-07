<# A shortcut script for quick-use remote connection commands #>

[CmdletBinding()]

param (
    [string]$server_in,
    [switch]$open,
    [switch]$show,
    [switch]$version
)

#TODO create usage function and help option

#region Globals

$versionNumber = "1.0.0";

$hashFileName = "hash.ps1";
$newHashFileContent = "`$hash = [ordered]@{`r`n    `"default`" = `"ssh me@localhost`";`r`n}";
$programForOpen = "notepad++"
$scriptName = $MyInvocation.MyCommand.Name

#endregion

#region Functions

# stolen from https://stackoverflow.com/a/61281776
function Get-RealScriptPath() {
    # Get script path and name
    $ScriptPath = $PSCommandPath

    # Attempt to extract link target from script pathname
    $link_target = Get-Item $ScriptPath | Select-Object -ExpandProperty Target

    # If it's not a link ..
    If (-Not($link_target)) {
        # .. then the script path is the answer.
        return $ScriptPath
    }

    # If the link target is absolute ..
    $is_absolute = [System.IO.Path]::IsPathRooted($link_target)
    if ($is_absolute) {
        # .. then it is the answer.
        return $link_target
    }

    # At this point:
    # - we know that script was launched from a link
    # - the link target is probably relative (depending on how accurate
    #   IsPathRooted() is).
    # Try to make an absolute path by merging the script directory and the link
    # target and then normalize it through Resolve-Path.
    $joined = Join-Path $PSScriptRoot $link_target
    $resolved = Resolve-Path -Path $joined
    return $resolved
}

# stolen from https://stackoverflow.com/a/61281776
function Get-ScriptDirectory() {
    $ScriptPath = Get-RealScriptPath
    $ScriptDir = Split-Path -Parent $ScriptPath
    return $ScriptDir
}

#endregion

$scriptDir = Get-ScriptDirectory
$hashFile = "$scriptDir\$hashFileName"
Write-Debug "loading has file from: `"$($hashFile)`""

if ($version) {
    Write-Output $versionNumber
    Exit
}

if ($open) {
    Start-Process $programForOpen $hashFile
    Exit
}

# if hash file doesn't exist, create one and exit
if (-Not(Test-Path $hashFile -PathType Leaf)) {
    Write-Error "Hash file not found"
    Write-Output "Creating sample hash file"
    Write-Output "Use './$scriptName -open' to add connections"

    Write-Output $newHashFileContent | Out-File $hashFile
    Exit
}

# import hash file
. $hashFile

if ($show) {
    if ($hash.Count -gt 0) {
        Write-Output $hash
    }
    else {
        Write-Warning "No commands in hash file"
    }
    Exit
}

$command = $hash[$server_in]

if ($null -eq $command) {
    Write-Error "Invalid input '$server_in'"
    Write-Output "Use './$scriptName -show' to see all available connection"
    Exit
}

# if index and command are fine, then good to go
Write-Output "Connecting ... "
Invoke-Expression $command
