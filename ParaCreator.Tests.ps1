# Import the module to test
function Import-CorrectModule {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModulePath
    )

    if (-not (Test-Path -Path $ModulePath)) {
        $ModulePath = Join-Path -Path (Get-Location) -ChildPath $ModulePath
    }

    if (Test-Path -Path $ModulePath) {
        Import-Module -Name $ModulePath -Force
        Write-Host "Successfully imported module: $ModulePath"
    } else {
        Write-Host "Module not found: $ModulePath" -ForegroundColor Red
    }
}

Import-CorrectModule -ModulePath (Join-Path -Path $PSScriptRoot -ChildPath "ParaCreator.psd1")

Describe "New-ParaStructure" {
    BeforeEach {
        # Setup: Create a temporary directory for testing
        $TestBaseDir = New-Item -Path (Join-Path -Path $env:TEMP -ChildPath "ParaTest") -ItemType Directory -Force
    }

    AfterEach {
        # Cleanup: Remove the test directory after each test
        if (Test-Path $TestBaseDir.FullName) {
            Remove-Item -Path $TestBaseDir.FullName -Recurse -Force -ErrorAction Stop
        }
    }

    It "Should create the main project directory" {
        $ProjectName = "TestProject"
        New-ParaStructure -BaseDirectory $TestBaseDir.FullName -ProjectName $ProjectName
        
        # Assert the project directory exists
        $ExpectedPath = Join-Path -Path $TestBaseDir.FullName -ChildPath $ProjectName
        Test-Path $ExpectedPath | Should -Be $true
    }

    It "Should create default subdirectories" {
        $ProjectName = "TestProject"
        New-ParaStructure -BaseDirectory $TestBaseDir.FullName -ProjectName $ProjectName
        
        # Assert that default subdirectories are created
        $DefaultSubdirs = @("code", "videos", "bloopers", "working-git-project")
        foreach ($subdir in $DefaultSubdirs) {
            $ExpectedSubdirPath = Join-Path -Path $TestBaseDir.FullName -ChildPath "$ProjectName\$subdir"
            Test-Path $ExpectedSubdirPath | Should -Be $true
        }
    }

    It "Should create a .gitkeep file in each subdirectory" {
        $ProjectName = "TestProject"
        New-ParaStructure -BaseDirectory $TestBaseDir.FullName -ProjectName $ProjectName
        
        # Assert that .gitkeep files are created in default subdirectories
        $DefaultSubdirs = @("code", "videos", "bloopers", "working-git-project")
        foreach ($subdir in $DefaultSubdirs) {
            $ExpectedGitkeepPath = Join-Path -Path $TestBaseDir.FullName -ChildPath "$ProjectName\$subdir\.gitkeep"
            Test-Path $ExpectedGitkeepPath | Should -Be $true
        }
    }

    It "Should not overwrite existing project directory" {
        $ProjectName = "TestProject"
        New-ParaStructure -BaseDirectory $TestBaseDir.FullName -ProjectName $ProjectName
        
        # Attempt to create the same project again
        { New-ParaStructure -BaseDirectory $TestBaseDir.FullName -ProjectName $ProjectName } | Should -Throw
    }

    It "Should overwrite existing project directory if Force is specified" {
        $ProjectName = "TestProject"
        New-ParaStructure -BaseDirectory $TestBaseDir.FullName -ProjectName $ProjectName
        
        # Attempt to create the same project again with Force
        { New-ParaStructure -BaseDirectory $TestBaseDir.FullName -ProjectName $ProjectName -Force } | Should -Not -Throw
    }

    It "Should create custom subdirectories if provided" {
        $ProjectName = "TestProject"
        $CustomSubdirs = @("custom1", "custom2")
        New-ParaStructure -BaseDirectory $TestBaseDir.FullName -ProjectName $ProjectName -CustomSubdirectories $CustomSubdirs
        
        # Assert that custom subdirectories are created
        foreach ($subdir in $CustomSubdirs) {
            $ExpectedCustomSubdirPath = Join-Path -Path $TestBaseDir.FullName -ChildPath "$ProjectName\$subdir"
            Test-Path $ExpectedCustomSubdirPath | Should -Be $true
        }
    }

    It "Should handle invalid base directory" {
        $InvalidBaseDir = "C:\InvalidDirectory"
        $ProjectName = "TestProject"

        { New-ParaStructure -BaseDirectory $InvalidBaseDir -ProjectName $ProjectName } | Should -Throw
    }

    It "Should handle empty project name" {
        $EmptyProjectName = ""
        { New-ParaStructure -BaseDirectory $TestBaseDir.FullName -ProjectName $EmptyProjectName } | Should -Throw
    }

    It "Should handle special characters in project name" {
        $SpecialProjectName = "Test/Project"
        { New-ParaStructure -BaseDirectory $TestBaseDir.FullName -ProjectName $SpecialProjectName } | Should -Throw
    }

    It "Should handle long project name" {
        $LongProjectName = "A" * 261 # 261 characters long
        { New-ParaStructure -BaseDirectory $TestBaseDir.FullName -ProjectName $LongProjectName } | Should -Throw
    }

    It "Should handle existing directory with the same name" {
        $ProjectName = "TestProject"
        New-ParaStructure -BaseDirectory $TestBaseDir.FullName -ProjectName $ProjectName
        
        # Create the same directory manually
        New-Item -Path (Join-Path -Path $TestBaseDir.FullName -ChildPath $ProjectName) -ItemType Directory
        
        { New-ParaStructure -BaseDirectory $TestBaseDir.FullName -ProjectName $ProjectName } | Should -Throw
    }

    It "Should handle invalid custom subdirectory names" {
        $ProjectName = "TestProject"
        $InvalidCustomSubdirs = @("custom*1", "custom/2") # Invalid characters
        { New-ParaStructure -BaseDirectory $TestBaseDir.FullName -ProjectName $ProjectName -CustomSubdirectories $InvalidCustomSubdirs } | Should -Throw
    }

    It "Should create default subdirectories even if no custom ones are provided" {
        $ProjectName = "TestProject"
        New-ParaStructure -BaseDirectory $TestBaseDir.FullName -ProjectName $ProjectName
        
        # Assert default subdirectories are created
        $DefaultSubdirs = @("code", "videos", "bloopers", "working-git-project")
        foreach ($subdir in $DefaultSubdirs) {
            $ExpectedSubdirPath = Join-Path -Path $TestBaseDir.FullName -ChildPath "$ProjectName\$subdir"
            Test-Path $ExpectedSubdirPath | Should -Be $true
        }
    }

    It "Should handle insufficient permissions" {
        # This requires a specific setup in a restricted directory.
        $RestrictedDir = "C:\RestrictedDirectory"
        $ProjectName = "TestProject"

        # Ensure the directory exists and is protected.
        New-Item -Path $RestrictedDir -ItemType Directory -Force
        # Change permissions as necessary; this step might require admin rights.
        
        { New-ParaStructure -BaseDirectory $RestrictedDir -ProjectName $ProjectName } | Should -Throw
    }

    It "Should handle concurrent calls correctly" {
        # Simulate concurrent calls (this requires running in separate threads or jobs in a real scenario)
        $ProjectName = "ConcurrentProject"
        $Jobs = @()

        for ($i = 1; $i -le 5; $i++) {
            $Jobs += Start-Job -ScriptBlock {
                param($Path, $Name)
                New-ParaStructure -BaseDirectory $Path -ProjectName $Name
            } -ArgumentList $TestBaseDir.FullName, $ProjectName
        }

        $Jobs | ForEach-Object { Receive-Job -Job $_ }
        
        # Check if the project directory exists after all jobs have completed
        $ExpectedPath = Join-Path -Path $TestBaseDir.FullName -ChildPath $ProjectName
        Test-Path $ExpectedPath | Should -Be $true
    }
}
