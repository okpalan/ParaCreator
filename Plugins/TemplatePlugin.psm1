function New-ProjectTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Name of the template.")]
        [string]$TemplateName,

        [Parameter(Mandatory = $true, HelpMessage = "Base directory to create the template in.")]
        [string]$BaseDirectory,

        [Parameter(Mandatory = $false, HelpMessage = "Name of the plugin to create within the template.")]
        [string]$PluginName = $null  # Optional parameter for plugin name
    )

    # Validate Template Name
    if ($TemplateName -match '[<>:"/\\|?*]') {
        Write-Error "Template name contains invalid characters."
        return
    }

    # Define the path for the new template
    $templatePath = Join-Path -Path $BaseDirectory -ChildPath $TemplateName

    # Create the template directory if it doesn't exist
    if (-not (Test-Path -Path $templatePath)) {
        try {
            New-Item -Path $templatePath -ItemType Directory -Force | Out-Null
            Write-Host "Created template directory: $templatePath"

            # Add sample files
            New-Item -Path (Join-Path -Path $templatePath -ChildPath "README.md") -ItemType File -Force | Out-Null
            New-Item -Path (Join-Path -Path $templatePath -ChildPath "LICENSE") -ItemType File -Force | Out-Null
            
            # If a PluginName is provided, create the plugin structure
            if ($PluginName) {
                $pluginPath = Join-Path -Path $templatePath -ChildPath "ParaPlugins"
                New-Item -Path $pluginPath -ItemType Directory -Force | Out-Null
                
                # Create the plugin directory
                $pluginDir = Join-Path -Path $pluginPath -ChildPath $PluginName
                New-Item -Path $pluginDir -ItemType Directory -Force | Out-Null

                # Create plugin files
                New-Item -Path (Join-Path -Path $pluginDir -ChildPath "$PluginName.psm1") -ItemType File -Force | Out-Null
                New-Item -Path (Join-Path -Path $pluginDir -ChildPath "Test-$PluginName.ps1") -ItemType File -Force | Out-Null
                
                # Add documentation or code usage instructions to the plugin files
                Set-Content -Path (Join-Path -Path $pluginDir -ChildPath "$PluginName.psm1") -Value "# $PluginName Module"
                Set-Content -Path (Join-Path -Path $pluginDir -ChildPath "Test-$PluginName.ps1") -Value "# Test script for $PluginName"

                Write-Host "Created plugin '$PluginName' in directory: $pluginDir"
            }

            Write-Host "Template created successfully at '$templatePath'."
        } catch {
            Write-Error "Failed to create template directory: $_"
        }
    } else {
        Write-Host "Template directory already exists: $templatePath"
    }

    return $templatePath
}

Export-ModuleMember -Function New-ProjectTemplate
