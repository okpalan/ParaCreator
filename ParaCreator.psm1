# ParaCreator.psm1

# Function to create a config file
function New-ConfigFile {
    param (
        [string]$ConfigPath,
        [string]$Format,
        [hashtable]$ConfigData
    )

    # Create the config directory if it doesn't exist
    if (-not (Test-Path $ConfigPath)) {
        New-Item -Path $ConfigPath -ItemType Directory -Force | Out-Null
    }

    # Set the file name based on the format
    $FileName = "ParaConfig.$Format"
    $FullPath = Join-Path -Path $ConfigPath -ChildPath $FileName

    switch ($Format.ToLower()) {
        "json" {
            $JsonContent = $ConfigData | ConvertTo-Json -Depth 5
            Set-Content -Path $FullPath -Value $JsonContent
            Write-Host "JSON configuration file created at: $FullPath"
        }
        "yaml" {
            # Install the YamlDotNet module if not already installed
            if (-not (Get-Module -ListAvailable -Name "powershell-yaml")) {
                Install-Module -Name "powershell-yaml" -Scope CurrentUser -Force
            }

            $YamlContent = $ConfigData | ConvertTo-Yaml
            Set-Content -Path $FullPath -Value $YamlContent
            Write-Host "YAML configuration file created at: $FullPath"
        }
        default {
            Write-Error "Unsupported format. Please specify 'json' or 'yaml'."
        }
    }
}

function New-ParaStructure {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Base directory for the project.")]
        [string]$BaseDirectory,

        [Parameter(Mandatory = $true, HelpMessage = "Name of the project.")]
        [string]$ProjectName,

        [Parameter(Mandatory = $false, HelpMessage = "Custom subdirectories to create.")]
        [string[]]$CustomSubdirectories = @(),

        [switch]$Force
    )

    # Create base directory if it doesn't exist
    if (-not (Test-Path $BaseDirectory)) {
        New-Item -Path $BaseDirectory -ItemType Directory -Force | Out-Null
        Write-Host "Base directory created at: $BaseDirectory"
    }

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
            Write-Verbose "Created project directory: $projectPath"
        } catch {
            Write-Error "Failed to create project directory: $_"
            return
        }
    } elseif (-not $Force) {
        Write-Host "Project directory already exists: $projectPath"
        return
    } else {
        Remove-Item -Path $projectPath -Recurse -Force -ErrorAction Stop
        New-Item -Path $projectPath -ItemType Directory -Force | Out-Null
        Write-Verbose "Overwritten existing project directory: $projectPath"
    }

    # Default subdirectories to create
    $defaultSubdirectories = @("archives", "assets", "projects", "resources")

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
                Write-Verbose "Created subdirectory: $subPath"

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
            Write-Verbose "Overwritten existing subdirectory: $subPath"
        }
    }
}

# Function to load plugins from a specified directory
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

# Function to update a plugin
function Update-Plugin {
    param (
        [string]$PluginName,
        [string]$NewFilePath,
        [string]$ConfigPath
    )

    # Load existing configuration
    $ConfigFilePath = Join-Path -Path $ConfigPath -ChildPath "paraConfig.json"

    if (Test-Path $ConfigFilePath) {
        $ConfigData = Get-Content -Path $ConfigFilePath | ConvertFrom-Json
    } else {
        Write-Error "Configuration file not found at: $ConfigFilePath"
        return
    }

    # Find the plugin in the configuration
    $plugin = $ConfigData.Plugins | Where-Object { $_.Name -eq $PluginName }

    if ($plugin) {
        # Update the plugin's file path
        $plugin.FilePath = $NewFilePath

        # Save updated configuration
        New-ConfigFile -ConfigPath $ConfigPath -Format "json" -ConfigData $ConfigData
        Write-Host "Plugin '$PluginName' updated successfully."
    } else {
        Write-Error "Plugin '$PluginName' not found."
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

        [switch]$Force
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
            Write-Verbose "Created project directory: $projectPath"
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
        Write-Verbose "Overwritten existing project directory: $projectPath"
    }

    # Default subdirectories to create
    $defaultSubdirectories = @("archives", "assets", "projects", "resources")

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
                Write-Verbose "Created subdirectory: $subPath"

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
            Write-Verbose "Overwritten existing subdirectory: $subPath"
        }
    }
}
