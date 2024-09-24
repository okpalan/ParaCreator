# Import the GitManager module if needed
Import-Module -Name "./GitManager.psm1" -Force

# Define the project path for testing
$projectPath = "C:\path\to\your\test-directory"

# Call the Initialize-GitRepo function
Initialize-GitRepo -ProjectPath $projectPath

# Check if the .git directory was created
if (Test-Path (Join-Path -Path $projectPath -ChildPath ".git")) {
    Write-Host "Test Passed: Git repository initialized successfully."
} else {
    Write-Host "Test Failed: Git repository not initialized."
}

# Check for the initial commit
Set-Location -Path $projectPath
$commitCount = & git rev-list --count HEAD
if ($commitCount -eq 1) {
    Write-Host "Test Passed: Initial commit created successfully."
} else {
    Write-Host "Test Failed: No initial commit found."
}
