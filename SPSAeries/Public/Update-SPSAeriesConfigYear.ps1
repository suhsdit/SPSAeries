<#
.SYNOPSIS
    Updates SPSAeries database configuration files to rollover from one year to another.

.DESCRIPTION
    This script iterates through all directories in the SPSAeries config directory and updates
    the SQLDB configuration in config.json files, changing the database year identifier
    (e.g., DST24000 to DST25000).

.PARAMETER UserName
    The username for which to update the config files. Defaults to the current user.

.PARAMETER OldYear
    The old year identifier in the database name (e.g., 24 for DST24000). Defaults to last 2 digits of previous year.

.PARAMETER NewYear
    The new year identifier in the database name (e.g., 25 for DST25000). Defaults to last 2 digits of current year.

.PARAMETER ConfigNames
    Optional array of specific config directory names to process. If not provided, all directories will be processed.

.PARAMETER WhatIf
    Shows what changes would be made without actually making them.

.EXAMPLE
    .\Update-SPSAeriesConfigYear.ps1
    Updates config files for the current user, changing from previous year to current year (e.g., DST24 to DST25 in 2025)

.EXAMPLE
    .\Update-SPSAeriesConfigYear.ps1 -UserName "jsmith" -OldYear 23 -NewYear 24
    Updates config files for user "jsmith", changing DST23 to DST24

.EXAMPLE
    .\Update-SPSAeriesConfigYear.ps1 -WhatIf
    Shows what changes would be made without actually making them

.EXAMPLE
    .\Update-SPSAeriesConfigYear.ps1 -ConfigNames @("School1", "School2")
    Updates only the specified config directories

.EXAMPLE
    .\Update-SPSAeriesConfigYear.ps1 -ConfigNames "SingleSchool" -WhatIf
    Preview changes for a single specific config directory
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$UserName = $env:USERNAME,
    
    [Parameter(Mandatory = $false)]
    [ValidateRange(0, 99)]
    [int]$OldYear = ((Get-Date).Year - 1) % 100,
    
    [Parameter(Mandatory = $false)]
    [ValidateRange(0, 99)]
    [int]$NewYear = (Get-Date).Year % 100,
    
    [Parameter(Mandatory = $false)]
    [string[]]$ConfigNames = @()
)

function Update-SPSAeriesConfigYear {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$UserName,
        [int]$OldYear,
        [int]$NewYear,
        [string[]]$ConfigNames
    )
    
    # Construct the SPSAeries config directory path
    $configBasePath = "C:\Users\$UserName\AppData\Local\powershell\SPSAeries"
    
    Write-Host "SPSAeries Database Configuration Rollover Tool" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "Target User: $UserName" -ForegroundColor Green
    Write-Host "Config Path: $configBasePath" -ForegroundColor Green
    Write-Host "Updating: DST$($OldYear)000 -> DST$($NewYear)000" -ForegroundColor Green
    Write-Host ""
    
    # Check if the base directory exists
    if (-not (Test-Path $configBasePath)) {
        Write-Error "SPSAeries config directory not found: $configBasePath"
        return
    }
    
    # Get all subdirectories
    $allDirectories = Get-ChildItem -Path $configBasePath -Directory
    
    if ($allDirectories.Count -eq 0) {
        Write-Warning "No subdirectories found in $configBasePath"
        return
    }
    
    # Filter directories based on ConfigNames parameter
    if ($ConfigNames.Count -gt 0) {
        $directories = $allDirectories | Where-Object { $_.Name -in $ConfigNames }
        
        # Check if any specified configs were not found
        $notFound = $ConfigNames | Where-Object { $_ -notin $allDirectories.Name }
        if ($notFound.Count -gt 0) {
            Write-Warning "The following config directories were not found: $($notFound -join ', ')"
        }
        
        if ($directories.Count -eq 0) {
            Write-Warning "None of the specified config directories were found in $configBasePath"
            Write-Host "Available directories: $($allDirectories.Name -join ', ')" -ForegroundColor Gray
            return
        }
        
        Write-Host "Processing specified config directories ($($directories.Count) of $($ConfigNames.Count) requested):" -ForegroundColor Yellow
    } else {
        $directories = $allDirectories
        Write-Host "Found $($directories.Count) directories to process:" -ForegroundColor Yellow
    }
    $directories | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }
    Write-Host ""
    
    $processedCount = 0
    $updatedCount = 0
    $errorCount = 0
    
    foreach ($directory in $directories) {
        $configFile = Join-Path $directory.FullName "config.json"
        
        Write-Host "Processing: $($directory.Name)" -ForegroundColor White
        
        if (-not (Test-Path $configFile)) {
            Write-Warning "  config.json not found in $($directory.Name)"
            continue
        }
        
        try {
            # Read the config file
            $content = Get-Content $configFile -Raw -Encoding UTF8
            $processedCount++
            
            # Create the search and replace patterns
            $oldPattern = "DST$($OldYear)000"
            $newPattern = "DST$($NewYear)000"
            
            # Check if the old pattern exists in the file
            if ($content -match $oldPattern) {
                Write-Host "  Found $oldPattern in config.json" -ForegroundColor Green
                
                # Replace the pattern
                $updatedContent = $content -replace $oldPattern, $newPattern
                
                if ($WhatIfPreference) {
                    Write-Host "  [WHATIF] Would update: $oldPattern -> $newPattern" -ForegroundColor Magenta
                } else {
                    # Save the updated content
                    if ($PSCmdlet.ShouldProcess($configFile, "Update database configuration from $oldPattern to $newPattern")) {
                        Set-Content -Path $configFile -Value $updatedContent -Encoding UTF8
                        Write-Host "  Updated: $oldPattern -> $newPattern" -ForegroundColor Green
                        $updatedCount++
                    }
                }
            } else {
                Write-Host "  No $oldPattern found in config.json" -ForegroundColor Gray
            }
        }
        catch {
            Write-Error "  Error processing $($directory.Name): $($_.Exception.Message)"
            $errorCount++
        }
        
        Write-Host ""
    }
    
    # Summary
    Write-Host "Summary:" -ForegroundColor Cyan
    Write-Host "========" -ForegroundColor Cyan
    Write-Host "Directories processed: $processedCount" -ForegroundColor White
    
    if ($WhatIfPreference) {
        Write-Host "Files that would be updated: $updatedCount" -ForegroundColor Magenta
    } else {
        Write-Host "Files updated: $updatedCount" -ForegroundColor Green
    }
    
    if ($errorCount -gt 0) {
        Write-Host "Errors encountered: $errorCount" -ForegroundColor Red
    }
    
    Write-Host ""
    
    if ($WhatIfPreference) {
        Write-Host "Run without -WhatIf to apply changes." -ForegroundColor Yellow
    } elseif ($updatedCount -gt 0) {
        Write-Host "Database configuration rollover completed successfully!" -ForegroundColor Green
    }
}

# Execute the function with the provided parameters
Update-SPSAeriesConfigYear -UserName $UserName -OldYear $OldYear -NewYear $NewYear -ConfigNames $ConfigNames
