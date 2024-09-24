


# Function to load plugins
function Load-Plugins {
    param (
        [string]$PluginDirectory
    )

    # Validate the plugin directory
    if (-not (Test-Path -Path $PluginDirectory)) {
        Write-Error "The specified plugin directory does not exist: $PluginDirectory"
        return
    }

    # Get all .psm1 files in the plugin directory
    $pluginFiles = Get-ChildItem -Path $PluginDirectory -Filter '*.psm1' -ErrorAction Stop
    foreach ($plugin in $pluginFiles) {
        try {
            Import-Module -Name $plugin.FullName -Force
            Write-Host "Loaded plugin: $($plugin.Name)"
        } catch {
            Write-Error "Failed to load plugin '$($plugin.Name)': $_"
        }
    }
}

# Function to create a project structure with subdirectories and .gitkeep files
function New-ParaStructure {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Base directory for the project.")]
        [string]$BaseDirectory,

        [Parameter(Mandatory = $true, HelpMessage = "Name of the project.")]
        [string]$ProjectName,

        [Parameter(Mandatory = $false, HelpMessage = "Custom subdirectories to create.")]
        [string[]]$CustomSubdirectories = @(),

        [switch]$Force,

        [switch]$Verbose
    )

    # Validate Project Name
    if ($ProjectName -match '[<>:"/\\|?*]') {
        Write-Error "Project name contains invalid characters."
        return
    }

    # Define the path for the new project
    $projectPath = Join-Path -Path $BaseDirectory -ChildPath $ProjectName

    # Create the base project directory if it doesn't exist
    if (-not (Test-Path -Path $projectPath)) {
        try {
            New-Item -Path $projectPath -ItemType Directory -Force | Out-Null
            if ($Verbose) {
                Write-Verbose "Created project directory: $projectPath"
            }
        } catch {
            Write-Error "Failed to create project directory: $_"
            return
        }
    } elseif (-not $Force) {
        Write-Host "Project directory already exists: $projectPath"
        return
    } else {
        # If force is specified, remove the existing directory
        Remove-Item -Path $projectPath -Recurse -Force -ErrorAction Stop
        New-Item -Path $projectPath -ItemType Directory -Force | Out-Null
        if ($Verbose) {
            Write-Verbose "Overwritten existing project directory: $projectPath"
        }
    }

    # Default subdirectories to create
    $defaultSubdirectories = @("code", "videos", "bloopers", "working-git-project")
    
    # Validate and combine default and custom subdirectories
    $validCustomSubdirs = @()
    foreach ($subdir in $CustomSubdirectories) {
        if ($subdir -and $subdir -notmatch '[<>:"/\\|?*]') {
            $validCustomSubdirs += $subdir
        } else {
            Write-Warning "Custom subdirectory '$subdir' is invalid and will be ignored."
        }
    }

    $subdirectories = $defaultSubdirectories + $validCustomSubdirs | Select-Object -Unique

    # Create each subdirectory and .gitkeep file
    foreach ($subdirectory in $subdirectories) {
        $subPath = Join-Path -Path $projectPath -ChildPath $subdirectory
        if (-not (Test-Path -Path $subPath)) {
            try {
                New-Item -Path $subPath -ItemType Directory -Force | Out-Null
                if ($Verbose) {
                    Write-Verbose "Created subdirectory: $subPath"
                }

                # Create .gitkeep file to ensure the directory is tracked by Git
                New-Item -Path (Join-Path -Path $subPath -ChildPath ".gitkeep") -ItemType File -Force | Out-Null
            } catch {
                Write-Error "Failed to create subdirectory or .gitkeep: $_"
            }
        } elseif (-not $Force) {
            Write-Host "Subdirectory already exists: $subPath"
        } else {
            Remove-Item -Path $subPath -Recurse -Force -ErrorAction Stop
            New-Item -Path $subPath -ItemType Directory -Force | Out-Null
            New-Item -Path (Join-Path -Path $subPath -ChildPath ".gitkeep") -ItemType File -Force | Out-Null
            if ($Verbose) {
                Write-Verbose "Overwritten existing subdirectory: $subPath"
            }
        }
    }

    if ($Verbose) {
        Write-Verbose "Project structure created successfully!"
    } else {
        Write-Host "Project structure created successfully at '$projectPath'."
    }

    return $projectPath
}

Export-ModuleMember -Function New-ParaStructure
