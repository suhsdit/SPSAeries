# This function is used to help update the module while developing and testing...
Function Update-SPSAeries {
    [CmdletBinding()] #Enable all the default paramters, including -Verbose
    Param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$false,
            Position=0)]
        [string]$config
    )
    Write-Host "[X] Removing SPSAeries Module..." -ForegroundColor Green
    Get-Module SPSAeries | Remove-Module
    Write-Host "[X] Importing SPSAeries Module from .\SPSAeries..." -ForegroundColor Green
    Import-Module SPSAeries
    Write-Host "[X] Setting SPSAeries config to $config..." -ForegroundColor Green
    Set-SPSAeriesConfiguration $config -verbose
    Write-Host "[X] Updated SPSAeries ready to use. Using Config:" -ForegroundColor Green
    Get-SPSAeriesConfiguration
}