param(
    [string]$BuildVersion,
    [switch]$Local,
    [switch]$IncrementVersion,
    [switch]$Test
)

#Install-Module -Name Configuration -Repository PSGallery -Force

# Function to auto-populate FunctionsToExport
function Update-FunctionsToExport {
    param(
        [string]$ManifestContent,
        [string]$PublicFolderPath
    )
    
    Write-Host "📋 Auto-populating FunctionsToExport..." -ForegroundColor Yellow
    
    if (Test-Path $PublicFolderPath) {
        $functionFiles = Get-ChildItem -Path $PublicFolderPath -Filter "*.ps1"
        if ($functionFiles) {
            $functionNames = $functionFiles | ForEach-Object { "'$($_.BaseName)'" }
            $functionsArray = $functionNames -join ",`n                        "
            
            # Replace the FunctionsToExport array
            $pattern = "FunctionsToExport\s*=\s*@\([^)]*\)"
            $replacement = "FunctionsToExport = @($functionsArray)"
            $updatedContent = $ManifestContent -replace $pattern, $replacement
            
            Write-Host "  📋 Found $($functionFiles.Count) functions: $($functionFiles.BaseName -join ', ')" -ForegroundColor Gray
            return $updatedContent
        } else {
            Write-Host "  ⚠️  No .ps1 files found in Public folder" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ⚠️  Public folder not found: $PublicFolderPath" -ForegroundColor Yellow
    }
    
    Write-Host "  📋 Keeping existing FunctionsToExport" -ForegroundColor Gray
    return $ManifestContent
}

$moduleName = 'SPSAeries'
$manifestPath = Join-Path -Path $PWD -ChildPath "$moduleName\$moduleName.psd1"

if ($Local) {
    Write-Host "🚀 SPSAeries Local Build" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    
    # Create build directory
    $buildDir = Join-Path -Path $PWD -ChildPath "build"
    $buildModuleDir = Join-Path -Path $buildDir -ChildPath $moduleName
    
    Write-Host "📁 Creating build directory..." -ForegroundColor Yellow
    if (Test-Path $buildDir) {
        Remove-Item $buildDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
    
    Write-Host "� Copying module files..." -ForegroundColor Yellow
    Copy-Item -Path $moduleName -Destination $buildDir -Recurse -Force
    
    $buildManifestPath = Join-Path -Path $buildModuleDir -ChildPath "$moduleName.psd1"
    
    # Handle version and auto-populate functions for local testing
    $content = Get-Content $buildManifestPath -Raw
    
    # Auto-populate FunctionsToExport from Public folder
    $publicFolderPath = Join-Path -Path $buildModuleDir -ChildPath "Public"
    $content = Update-FunctionsToExport -ManifestContent $content -PublicFolderPath $publicFolderPath
    
    if ($IncrementVersion) {
        Write-Host "📦 Setting incremented version..." -ForegroundColor Yellow
        
        if ($content -match "ModuleVersion\s*=\s*'([^']*)'") {
            $currentVersionString = $matches[1]
            
            if ($currentVersionString -eq '<ModuleVersion>' -or $currentVersionString -eq '') {
                $newVersion = "1.0.1"
                Write-Host "  📋 No existing version found, using $newVersion for local testing" -ForegroundColor Gray
            } else {
                try {
                    $currentVersion = [System.Version]$currentVersionString
                    $newVersion = [System.Version]::new($currentVersion.Major, $currentVersion.Minor, ($currentVersion.Build + 1))
                    Write-Host "  📋 Testing with incremented version: $newVersion" -ForegroundColor Gray
                } catch {
                    $newVersion = "1.0.1"
                    Write-Host "  ⚠️  Could not parse version '$currentVersionString', using $newVersion for testing" -ForegroundColor Yellow
                }
            }
        } else {
            $newVersion = "1.0.1"
            Write-Host "  📋 No ModuleVersion found, using $newVersion for testing" -ForegroundColor Gray
        }
        
        # Update version in build copy
        $content = $content -replace "ModuleVersion\s*=\s*'[^']*'", "ModuleVersion = '$newVersion'"
        $content | Set-Content $buildManifestPath
    } else {
        # For testing without version increment, still need to handle placeholder
        if ($content -match "ModuleVersion\s*=\s*'<ModuleVersion>'") {
            Write-Host "📦 Setting default version for testing..." -ForegroundColor Yellow
            $content = $content -replace "ModuleVersion\s*=\s*'<ModuleVersion>'", "ModuleVersion = '1.0.0'"
            $content | Set-Content $buildManifestPath
            Write-Host "  📋 Using default version 1.0.0 for testing" -ForegroundColor Gray
        }
    }
    
    Write-Host "`n🔄 Importing module from build directory..." -ForegroundColor Yellow
    
    # Remove existing module and import from build directory
    if (Get-Module SPSAeries -ErrorAction SilentlyContinue) {
        Remove-Module SPSAeries -Force
    }
    
    try {
        Import-Module $buildManifestPath -Force
        $module = Get-Module SPSAeries
        Write-Host "✅ Module imported successfully (Version: $($module.Version))" -ForegroundColor Green
        Write-Host "  📋 Module loaded from: $buildDir" -ForegroundColor Gray
        
        if ($Test) {
            Write-Host "`n🧪 Running tests..." -ForegroundColor Yellow
            
            # Test new function exists
            if (Get-Command Get-SPSAeriesAttendanceCalendar -ErrorAction SilentlyContinue) {
                Write-Host "✅ Get-SPSAeriesAttendanceCalendar function available" -ForegroundColor Green
                
                # Show function parameters
                $params = (Get-Command Get-SPSAeriesAttendanceCalendar).Parameters.Keys
                Write-Host "  📋 Available parameters: $($params -join ', ')" -ForegroundColor Gray
            } else {
                Write-Host "❌ Get-SPSAeriesAttendanceCalendar function not found" -ForegroundColor Red
            }
            
            # List all exported functions
            $exportedFunctions = $module.ExportedFunctions.Keys | Sort-Object
            Write-Host "  📋 All exported functions ($($exportedFunctions.Count)):" -ForegroundColor Gray
            foreach ($func in $exportedFunctions) {
                Write-Host "    • $func" -ForegroundColor DarkGray
            }
            
            # Validate manifest
            try {
                Test-ModuleManifest $buildManifestPath -ErrorAction Stop | Out-Null
                Write-Host "✅ Module manifest is valid" -ForegroundColor Green
            } catch {
                Write-Host "❌ Module manifest validation failed: $_" -ForegroundColor Red
            }
        }
        
        Write-Host "`n🎉 Local build complete!" -ForegroundColor Green
        Write-Host "💡 Test example: Get-SPSAeriesAttendanceCalendar -SchoolCode 13 -Verbose" -ForegroundColor Cyan
        Write-Host "💡 Original source code unchanged" -ForegroundColor Green
        Write-Host "💡 Build directory: $buildDir (git ignored)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to import module: $_" -ForegroundColor Red
        Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
    
    return
}

# CI/CD Build Mode
Write-Host "🏗️  CI/CD Build Mode" -ForegroundColor Yellow

"List all environment variables"
Get-ChildItem Env: | ForEach-Object { "$($_.Name): $($_.Value)" }
"End of environment variables"

$buildVersion = $BuildVersion ?? $env:buildVer
if (-not $buildVersion) {
    Write-Error "Build version not specified. Use -BuildVersion parameter or set env:buildVer"
    exit 1
}

"buildVersion: $buildVersion"
"manifestPath: $manifestPath"
"WorkingDir: $PWD"

#Update-Metadata -Path $manifestPath -PropertyName ModuleVersion -Value $buildVersion

# Update build version in manifest
Write-Host "📦 Updating version to $buildVersion..." -ForegroundColor Yellow
$manifestContent = Get-Content -Path $manifestPath -Raw
$manifestContent = $manifestContent -replace "ModuleVersion\s*=\s*'[^']*'", "ModuleVersion = '$buildVersion'"

# Auto-populate FunctionsToExport from Public folder for CI/CD
$publicFuncFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "$moduleName/Public"
$manifestContent = Update-FunctionsToExport -ManifestContent $manifestContent -PublicFolderPath $publicFuncFolderPath

$manifestContent | Set-Content -Path $manifestPath

Write-Host "✅ CI/CD Build completed successfully" -ForegroundColor Green