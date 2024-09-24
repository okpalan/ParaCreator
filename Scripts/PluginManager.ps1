function Add-Plugin {
    param (
        [string]$PluginName
    )

    # Define the base path for plugins
    $basePath = "C:\msys64\home\okpal\My Content Creations\ParaCreator\Plugins"

    # Create the plugin directory
    $pluginPath = Join-Path -Path $basePath -ChildPath $PluginName
    New-Item -Path $pluginPath -ItemType Directory -Force

    # Create the main plugin module file
    $moduleFile = Join-Path -Path $pluginPath -ChildPath "$PluginName.psm1"
    @"
function Invoke-$PluginName {
    param (
        [string]`$Parameter1
    )

    return "$PluginName executed with parameter: `$Parameter1"
}

# Export the function
Export-ModuleMember -Function Invoke-$PluginName

"@ | Set-Content -Path $moduleFile

    Write-Host "Plugin '$PluginName' created at '$pluginPath'."
}

Export-ModuleMember -Function Add-Plugin

function Remove-Plugin {
    param (
        [string]$PluginName,
        [string]$ConfigPath
    )
    
    $configFilePath = Join-Path -Path $ConfigPath -ChildPath "ParaConfig.json"

    if (Test-Path $configFilePath) {
        $configData = Get-Content -Path $configFilePath | ConvertFrom-Json
        $configData.Plugins = $configData.Plugins | Where-Object { $_.Name -ne $PluginName }
        $configData | ConvertTo-Json -Depth 5 | Set-Content -Path $configFilePath
        Write-Host "Removed plugin '$PluginName' from configuration."
    } else {
        Write-Error "Configuration file does not exist: $configFilePath"
    }

    $pluginPath = Join-Path -Path $ConfigPath -ChildPath "ParaPlugins\$PluginName"
    if (Test-Path $pluginPath) {
        Remove-Item -Path $pluginPath -Recurse -Force
        Write-Host "Deleted plugin directory: $pluginPath"
    }
}

Export-ModuleMember -Function Remove-Plugin

function Get-PluginInfo {
    param (
        [string]$ConfigPath
    )
    
    $configFilePath = Join-Path -Path $ConfigPath -ChildPath "ParaConfig.json"
    if (Test-Path $configFilePath) {
        $configData = Get-Content -Path $configFilePath | ConvertFrom-Json
        $configData.Plugins | ForEach-Object {
            Write-Host "Plugin Name: $($_.Name), Description: $($_.Description), Registered: $($_.Registered)"
        }
    } else {
        Write-Error "Configuration file does not exist: $configFilePath"
    }
}

Export-ModuleMember -Function Get-PluginInfo
