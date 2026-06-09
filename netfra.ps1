# $msbuildPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\msbuild.exe"  # Adjust the path to your msbuild.exe
$msbuildPath = "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"  # Adjust the path to your msbuild.exe
# $projectPath = "C:\Users\jacob\source\repos\PaycorActiveDirectoryFileExporter\API\API.csproj" # Replace with your project file path
$projectPath = "$HOME\source\repos\PaycorActiveDirectoryFileExporter\API\API.csproj" # Replace with your project file path
# $solutionPath = "C:\Users\jacob\source\repos\PaycorActiveDirectoryFileExporter\Paycor Active Directory File Exporter.sln" # Replace with your project file path
$solutionPath = "$HOME\source\repos\PaycorActiveDirectoryFileExporter\Paycor Active Directory File Exporter.sln" # Replace with your project file path
$publishProfileName = "FolderProfile" # Name of your publish profile (without the .pubxml extension)

# Build and Publish the project using the specified publish profile
# & "$msbuildPath" "$projectPath" /p:DeployOnBuild=true /p:PublishProfile="$publishProfileName" /p:Configuration=Release

# Optional: Add further actions after publishing, like copying files, deploying to a web server, etc.
# Write-Host "Project published successfully using profile: $publishProfileName"

# & "$msbuildPath" `
#     $projectPath `
#     /t:Publish `
#     /p:Configuration=Release `
#     /p:PublishProfile=$publishProfileName `
#     /p:DeployOnBuild=true 

& "$msbuildPath" "$projectPath" /p:DeployOnBuild=true /p:PublishProfile=$publishProfileName /p:Configuration=Release

if ($LASTEXITCODE -ne 0) {
    throw "MSBuild failed"
}
else {
    Write-Output $LASTEXITCODE
}

Write-Output "done?"
