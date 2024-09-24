function New-ProjectTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Name of the template.")]
        [string]$TemplateName,

        [Parameter(Mandatory = $true, HelpMessage = "Base directory to create the template in.")]
        [string]$BaseDirectory,

        [Parameter(Mandatory = $false, HelpMessage = "Name of the plugin to create (optional).")]
        [string]$PluginName
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
            
            # Create ParaPlugins directory if PluginName is provided
            if ($PluginName) {
                # Validate Plugin Name
                if ($PluginName -match '[<>:"/\\|?*]') {
                    Write-Error "Plugin name contains invalid characters."
                    return
                }

                # Define path for the plugin
                $pluginPath = Join-Path -Path $templatePath -ChildPath "ParaPlugins"
                if (-not (Test-Path -Path $pluginPath)) {
                    New-Item -Path $pluginPath -ItemType Directory -Force | Out-Null
                    Write-Host "Created ParaPlugins directory: $pluginPath"
                }

                # Create the plugin directory
                $pluginDir = Join-Path -Path $pluginPath -ChildPath $PluginName
                if (-not (Test-Path -Path $pluginDir)) {
                    New-Item -Path $pluginDir -ItemType Directory -Force | Out-Null
                    Write-Host "Created plugin directory: $pluginDir"

                    # Create the plugin files with documentation
                    $pluginFile = Join-Path -Path $pluginDir -ChildPath "$PluginName.psm1"
                    $testFile = Join-Path -Path $pluginDir -ChildPath "Test-$PluginName.ps1"

                    # Plugin script file content
                    $pluginContent = @"
<#
.SYNOPSIS
    Plugin for $PluginName.
.DESCRIPTION
    This module provides functionalities for $PluginName.
#>
function New-$PluginName {
    [CmdletBinding()]
    param (
        [string]`$Parameter1
    )
    # Implementation of your plugin function
}
"@
                    # Create the plugin script file
                    Set-Content -Path $pluginFile -Value $pluginContent

                    # Test script file content
                    $testContent = @"
<#
.SYNOPSIS
    Unit tests for $PluginName.
.DESCRIPTION
    This script contains unit tests for the functionalities provided by the $PluginName module.
#>
Describe '$PluginName Tests' {
    It 'should do something' {
        # Add your test logic here
        $true | Should -Be $true
    }
}
"@
                    # Create the test script file
                    Set-Content -Path $testFile -Value $testContent

                    Write-Host "Created plugin files: $PluginName.psm1 and Test-$PluginName.ps1 in '$pluginDir'."
                } else {
                    Write-Host "Plugin directory already exists: $pluginDir"
                }
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
