[CmdletBinding()]

param (
    [ValidateSet("set", "list", "help", "version", IgnoreCase = $true)]
    [string]$action,
    [string]$_phpVersion # ex: 8.5 | 7.4.33
)

#region globals

# https://downloads.php.net/~windows/releases/archives/
# https://www.php.net/releases/index.php?json
# https://museum.php.net/php7/
# https://www.php.net/releases/index.php?json=1
# https://www.php.net/releases/index.php?json=1&version=8&max=1000

$version = "2.0.1"
$globalPhpDir = "C:\the_php"
$phpInstallationsDir = "C:\phps"
$masterPhpIni = "${phpInstallationsDir}\php.ini"
$phpVCodes = ("VC11", "VC14", "VC15", "vc15", "vs16", "vs17", "vs18" ) # VC6, VC9 not available for x64

#endregion

#region setup

# if PHPs dir doesn't exist, create it
New-Item -ItemType Directory -Force -Path $phpInstallationsDir | Out-Null

# acknowledge if php version is not present in $env:path
if (-not ($env:Path -split ';' -contains $globalPhpDir)) {
    Write-Host "Warning: the 'Path' Environment Variable does not contain '${globalPhpDir}'" -ForegroundColor Red
}

#endregion

#region functions

function GetLatestPhp {
    param(
        [string] $_version # ex 8.5 | 7.3 | etc
    )

    $url = "https://www.php.net/releases/index.php?json=1&version=${_version}"
    try {
        $response = Invoke-RestMethod -Uri $url
        Write-Debug $response
        return $response.version
    }
    catch {
        $StatusCode = $_.Exception.Response.StatusCode.value__
        Write-Error "${StatusCode}: Could not find PHP Version ${_version}"
        Exit 1;
    }
}

#endregion

switch ($action) {
    "version" {
        Write-Host $version
    }
    "help" {
        Write-Host "Usage
    ./multi-php [options] help
    ./multi-php [options] list
    ./multi-php [options] set <PHP version>
    
    -d          debug mode
    -v <X.X.X>  use PHP version X.X.X
    -v <X.X>    use latest minor PHP version X.X"
    }
    "list" {
        $installedPhpVersions = Get-ChildItem -Path $phpInstallationsDir -Directory | Select-Object -ExpandProperty Name 
        Write-Host "Installed Version" -ForegroundColor Green
        Write-Output $installedPhpVersions

        $symlink = (Get-Item $globalPhpDir).Target
        $dirName = Split-Path -Path $symlink -Leaf
        Write-Host ""
        Write-Host "Assigned Version" -ForegroundColor Green
        Write-Host $dirName
    }
    "set" {
        # if input php version is invalid, then exit
        $phpVersion = ""
        if ($_phpVersion -match "^\d+\.\d+\.\d+$") {
            $phpVersion = $_phpVersion;
        }
        elseif ($_phpVersion -match "^\d+\.\d+$") {
            Write-Debug "Fetching latest minor version of ${_phpVersion}"
            $latestVersion = GetLatestPhp $_phpVersion;
            Write-Debug "Fetched ${latestVersion}"
            $phpVersion = $latestVersion
        }
        else {
            Write-Error "Invalid PHP version ${_phpVersion}"
            Exit 1
        }

        $phpDir = "${phpInstallationsDir}\${phpVersion}\"

        # check if php version is downloaded, if not, download it 
        $installSuccessful = $false
        if (-not (Test-Path -path $phpDir)) {
            Write-Host "Downloading ${phpVersion}" -ForegroundColor Green

            $destination = "${phpInstallationsDir}\${phpVersion}.zip"
            Write-Debug "download destination: ${destination}"
    
            # loop through possible versions of php build. starting with "vc11", latest is "vs20"
            Write-Host "Finding ${phpVersion}" -ForegroundColor Green
            $downloadSuccessful = $false
            for ($i = 0; $i -lt $phpVCodes.Length; $i++) {
                $vCode = $phpVCodes[$i]

                $url = "https://downloads.php.net/~windows/releases/archives/php-${phpVersion}-Win32-${vCode}-x64.zip"
                Write-Debug "download url: ${url}"
                try {
                    $response = Invoke-WebRequest -Uri $url -OutFile $destination
                    $downloadSuccessful = $true
                    break;
                }
                catch {
                    $StatusCode = $_.Exception.Response.StatusCode.value__
                    Write-Debug $StatusCode
                }
            }

            # unzip archive
            if ($downloadSuccessful) {
                Expand-Archive -Path $destination -DestinationPath $phpDir
                Remove-Item $destination
                $installSuccessful = $true
            }
        }
        else {
            Write-Debug "PHP Version ${phpVersion} is already installed"
            $installSuccessful = $true
        }

        # create symlink to php dir
        if ($installSuccessful) {
            Write-Host "Installing ${phpVersion}" -ForegroundColor Green
            New-Item -ItemType SymbolicLink -Path $globalPhpDir -Target $phpDir -Force |  Out-Null
           
            if (Test-Path -path $masterPhpIni -PathType Leaf) {
                Write-Host "Reinstalling master php.ini" -ForegroundColor Green
                Write-Debug "Copying php.ini from ${masterPhpIni} to ${globalPhpDir}"
                Copy-Item $masterPhpIni $globalPhpDir
            }

            Write-Host "Complete" -ForegroundColor Green
        }
        else {
            Write-Error "Installation not successful"
            Exit 1
        }
    }
    Default { Write-Warning "How did you even get here?" }
}
