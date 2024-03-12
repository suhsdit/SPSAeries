$module = "SPSAeries"

BeforeAll {
    $here = $PSScriptRoot
    $module = "SPSAeries"
    $moduleDirectory = (get-item $here).parent.parent.FullName + "\$module"

    $functions = (  'Get-SPSAeriesDistrictAssetAssociation',
                    'Get-SPSAeriesDistrictAssetItem',
                    'Get-SPSAeriesDistrictAssetTitle',
                    'Get-SPSAeriesStaffEmail',
                    'Get-SPSAeriesConfiguration',
                    'New-SPSAeriesDistrictAssetAssociation',
                    'New-SPSAeriesDistrictAssetItem',
                    'New-SPSAeriesDistrictAssetTitle',
                    'New-SPSAeriesConfiguration',
                    'Set-SPSAeriesConfiguration',
                    'Update-SPSAeriesDistrictAssetTitle',
                    'Update-SPSAeriesStudent'
            )
}

Describe -Tags ('Unit', 'Acceptance') "$module Module Tests" {
    
    Context 'Module Setup' {
        
        It "has the root module $module.psm1"{
            "$moduleDirectory\$module.psm1" | Should -Exist
        }

        It "has the masifest file of $module.psd1" {
            "$moduleDirectory\$module.psd1" | Should -Exist
        }

        It "$module folder has functions" {
            (Get-ChildItem -Path "$moduleDirectory\Public" -Recurse -Include *.ps1).Count | Should -BeGreaterThan 0
        }

        It "$module is valid PowerShell code" {
            $psFile = Get-Content -Path "$moduleDirectory\$module.psm1" -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            $errors.Count | Should -Be 0
            }
    }
}


Context "Test Function $function" {
    It "Public .ps1 exists for each function" {
        foreach ($function in $functions) {
            "$moduleDirectory\Public\$function.ps1" | Should -Exist
        }
    }
}