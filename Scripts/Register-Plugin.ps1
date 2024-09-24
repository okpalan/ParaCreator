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
