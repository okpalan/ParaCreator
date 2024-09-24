function AutoCommit {
    param (
        [string]$ProjectPath,
        [string]$CommitMessage = "ParaCreator/AutoCommit: Automated commit by Scripts/AutoCommit.ps1 for project: $ProjectPath",
        [int]$SleepDurationInSeconds = 3600  # Default to 1 hour
    )

    while ($true) {
        if (Test-Path $ProjectPath) {
            Set-Location -Path $ProjectPath
            
            # Check for changes
            $changes = & git status --porcelain
            if (-not [string]::IsNullOrEmpty($changes)) {
                Write-Host "Changes detected. Committing..."
                
                # Stage all changes
                & git add .

                # Commit changes with the specified message
                & git commit -m $CommitMessage
                Write-Host "Changes committed with message: '$CommitMessage'"
            } else {
                Write-Host "No changes detected. Skipping commit."
            }
        } else {
            Write-Error "Project path does not exist: $ProjectPath"
        }
        
        # Wait for the specified duration before checking again
        Start-Sleep -Seconds $SleepDurationInSeconds
    }
}

# Export the function as a module member
Export-ModuleMember -Function AutoCommit
