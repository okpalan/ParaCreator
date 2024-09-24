# TemplatePlugin.psm1

function New-ProjectTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Name of the template.")]
        [string]$TemplateName,

        [Parameter(Mandatory = $true, HelpMessage = "Base directory to create the template in.")]
        [string]$BaseDirectory
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
            
            # Add other default files as needed
            # e.g., New-Item -Path (Join-Path -Path $templatePath -ChildPath "main.ps1") -ItemType File -Force | Out-Null

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

function Get-AvailableTemplates {
    param (
        [string]$BaseDirectory
    )
    
    if (Test-Path -Path $BaseDirectory) {
        $templates = Get-ChildItem -Path $BaseDirectory -Directory
        if ($templates) {
            Write-Host "Available Templates:"
            $templates | ForEach-Object { Write-Host "- $_.Name" }
        } else {
            Write-Host "No templates found in '$BaseDirectory'."
        }
    } else {
        Write-Error "Base directory does not exist: $BaseDirectory"
    }
}

Export-ModuleMember -Function Get-AvailableTemplates


