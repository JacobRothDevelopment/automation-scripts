[CmdletBinding()]

param (
    [string]$action = "help",
    [string]$file = "$HOME\vscode-extensions.txt",
    [switch]$ignore_version
)

$version = "B 0.1.0";
$vscode_extensions_file="$HOME\.vscode\extensions\extensions.json"

switch ($action) {
    "version" {
        Write-Output $version
    }
    "help" {
        Write-Error "There is no help menu yet. sorry"
        # TODO
    }
    "create" {
        if ([string]::IsNullOrWhiteSpace($file)) { 
            Write-Error "Provide a file path to write extension list to"
            Exit
        }

        Write-Debug "Creating extensions file"

        if ($ignore_version) {
            Write-Debug "Outputting file to $file"
            code --list-extensions | Out-File -FilePath $file
        }
        else {
            Write-Debug "Reading from $vscode_extensions_file"

            $vscode_extensions_json = Get-Content -Path $vscode_extensions_file -Raw
            $extensions = $vscode_extensions_json | ConvertFrom-Json
            
            $ext_entries = New-Object System.Collections.ArrayList
            for ($i = 0; $i -lt $extensions.Count; $i++) {
                $ext_id = $extensions[$i].identifier.id 
                $ext_version = $extensions[$i].version
                $entry = "$ext_id@$ext_version"
                $ext_entries += $entry
            }
    
            Write-Debug "Outputting file to $file"
            $ext_entries | Out-File -FilePath $file
        }

        Write-Output "File created: $file"
    }
    "install" {
        if ([string]::IsNullOrWhiteSpace($file)) { 
            Write-Error "Provide a file path to read extension list from"
            Exit
        }

        Write-Debug "Reading from $file"
        if (-Not(Test-Path $file -PathType Leaf)) {
            Write-Error "Extensions file [$file] file not found"
            Exit
        }
        
        Write-Output "Reading extensions file and installing extensions"

        $ext_entries = Get-Content -Path $file

        $answer = Read-Host "Are you sure you want to install $($ext_entries.Length) extensions? (y/N)"
        if ($answer -ne "y") {
            Write-Output "Installation cancelled"
            Exit
        }

        for ($i = 0; $i -lt $ext_entries.Count; $i++) {
            $extension = $ext_entries[$i]
            $command = "code --install-extension $extension"
            Write-Debug "installing $extension"
            Invoke-Expression $command
        }

        Write-Output "Extensions installed"
    }
    Default { Write-Warning "`'$action`" is not a valid action" }
}
