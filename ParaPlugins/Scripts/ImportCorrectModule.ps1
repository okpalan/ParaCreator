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

Export-ModuleMember -Function Import-CorrectModule
