# Import the necessary modules
Import-Module Pester
Import-Module -Name "C:\Path\To\ParaCreator\ParaPlugins\TemplatePlugin.psm1" -Force

Describe "Template Plugin Tests" {

    # Define a base directory for testing
    $baseDir = Join-Path -Path $env:TEMP -ChildPath "ParaCreatorTests"

    BeforeAll {
        # Ensure the base directory exists for tests
        if (-not (Test-Path -Path $baseDir)) {
            New-Item -Path $baseDir -ItemType Directory | Out-Null
        }
    }

    AfterAll {
        # Clean up after tests
        Remove-Item -Path $baseDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Describe "New-ProjectTemplate" {
        It "Should create a new template directory" {
            $templateName = "MyTestTemplate"
            $result = New-ProjectTemplate -TemplateName $templateName -BaseDirectory $baseDir
            
            # Verify the template directory exists
            $expectedPath = Join-Path -Path $baseDir -ChildPath $templateName
            Test-Path -Path $expectedPath | Should -Be $true
            
            # Check if README.md file was created
            Test-Path -Path (Join-Path -Path $expectedPath -ChildPath "README.md") | Should -Be $true
            
            # Check if LICENSE file was created
            Test-Path -Path (Join-Path -Path $expectedPath -ChildPath "LICENSE") | Should -Be $true
        }

        It "Should not create a directory if it already exists" {
            $templateName = "MyTestTemplate"
            New-ProjectTemplate -TemplateName $templateName -BaseDirectory $baseDir # Create it once

            # Capture output
            $output = New-ProjectTemplate -TemplateName $templateName -BaseDirectory $baseDir

            # Check for already exists message
            $output | Should -Contain "Template directory already exists"
        }

        It "Should throw an error for invalid template name" {
            $templateName = "Invalid:Template"
            { New-ProjectTemplate -TemplateName $templateName -BaseDirectory $baseDir } | Should -Throw "Template name contains invalid characters."
        }
    }

    Describe "Get-AvailableTemplates" {
        It "Should list available templates" {
            $templateName = "AnotherTestTemplate"
            New-ProjectTemplate -TemplateName $templateName -BaseDirectory $baseDir

            $templates = Get-AvailableTemplates -BaseDirectory $baseDir

            # Check if the newly created template is in the list
            $templates | Should -Contain $templateName
        }

        It "Should return a message when no templates exist" {
            Remove-Item -Path (Join-Path -Path $baseDir -ChildPath "AnotherTestTemplate") -Recurse -Force -ErrorAction SilentlyContinue

            $output = Get-AvailableTemplates -BaseDirectory $baseDir

            # Check if the message indicates no templates found
            $output | Should -Be "No templates found in '$baseDir'."
        }
    }
}
