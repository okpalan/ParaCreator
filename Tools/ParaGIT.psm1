
function Initialize-GitRepo {
    param (
        [string]$ProjectPath
    )
    Write-Host "Initializing Git repository at: $ProjectPath"
    
    # Logic to run git init and set up initial commit
    if (-not (Test-Path $ProjectPath)) {
        Write-Error "The specified project path does not exist."
        return
    }

    # Change directory to the project path
    Set-Location -Path $ProjectPath

    # Initialize Git repository
    & git init
    Write-Host "Git repository initialized."

    # Create an initial commit (optional)
    & git add .
    & git commit -m "Initial commit"
    Write-Host "Initial commit created."
}

Export-ModuleMember -Function Initialize-GitRepo

function Manage-GitSubmodules {
    param (
        [string]$ProjectPath,
        [string]$SubmoduleUrl,
        [string]$SubmodulePath,
        [string]$Action
    )

    # Change to the project directory
    Set-Location -Path $ProjectPath

    switch ($Action) {
        "init" {
            Write-Host "Initializing submodules in: $ProjectPath"
            & git submodule init
            & git submodule update
            Write-Host "Submodules initialized."
        }
        "update" {
            Write-Host "Updating submodules in: $ProjectPath"
            & git submodule update --remote
            Write-Host "Submodules updated."
        }
        "add" {
            if (-not $SubmoduleUrl -or -not $SubmodulePath) {
                Write-Error "Submodule URL and path must be specified."
                return
            }
            Write-Host "Adding submodule at: $SubmodulePath"
            & git submodule add $SubmoduleUrl $SubmodulePath
            Write-Host "Submodule added."
        }
        "remove" {
            if (-not $SubmodulePath) {
                Write-Error "Submodule path must be specified."
                return
            }
            Write-Host "Removing submodule at: $SubmodulePath"
            & git submodule deinit -f -- $SubmodulePath
            Remove-Item -Path $SubmodulePath -Recurse -Force
            & git rm --cached $SubmodulePath
            Write-Host "Submodule removed."
        }
        default {
            Write-Error "Invalid action specified. Use 'init', 'update', 'add', or 'remove'."
        }
    }
}

Export-ModuleMember -Function Manage-GitSubmodules
