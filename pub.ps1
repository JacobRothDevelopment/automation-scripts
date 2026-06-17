$msbuildPath = "$env:ProgramFiles\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" # msbuild.exe
$7zPath = "$env:ProgramFiles\7-Zip\7z.exe"

$publishProfileName = "FolderProfile" # .pubxml file

# $repoDir = "$HOME\source\repos\PaycorActiveDirectoryFileExporter" # TODO replace with "."
$repoDir = "." # TODO replace with "."
$projectPath = "$repoDir\API\API.csproj" # .csproj file
$dataDir = "C:\Data\www\Paycor-Integration"
$prodDir = "$dataDir\production"
$publishDir = "$repoDir\API\bin\app.publish"

#region functions

function Progress {
    param (
        [string] $s
    )

    Write-Host $s -ForegroundColor Green
}

#endregion

#region 1. Build API Project

Progress "Running Publishing Profile"

& "$msbuildPath" "$projectPath" /p:DeployOnBuild=true /p:PublishProfile=$publishProfileName /p:Configuration=Release

#endregion

#region 2. zip existing production

Progress "Creating 7Zip backup of prod"

$date = Get-Date -Format "yyyyMMdd" 
$zipFile = "$dataDir\production-$date.7z"
& "$7zPath" a -mx=9 "$zipFile" "$prodDir" -y

#endregion

#region 3. copy files from app.publish/ to prod

Progress "Copying files to prod"

Copy-Item -Path "$publishDir\*" -Destination "$prodDir" -Recurse -Force

#endregion

Progress "Finished!"
