# This function is used to help update the module while developing and testing...
Function Update-PSAeries {
    [CmdletBinding()] #Enable all the default paramters, including -Verbose
    Param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$false,
            Position=0)]
        [string]$config
    )
    Write-Host "[X] Removing PSAeries Module..." -ForegroundColor Green
    Get-Module PSAeries | Remove-Module
    Write-Host "[X] Importing PSAeries Module from .\PSAeries..." -ForegroundColor Green
    Import-Module .\PSAeries
    Write-Host "[X] Setting PSAeries config to $config..." -ForegroundColor Green
    Set-PSAeriesConfiguration $config
    Write-Host "[X] Updated PSAeries ready to use. Using Config:" -ForegroundColor Green
    Get-PSAeriesConfiguration
}

#end