InModuleScope SPSAeries {
    Describe "Set-SPSAeriesConfiguration" {

        BeforeAll {
            Mock Get-Content { 
                return '{
                "SQLDB": "DST200024TEST",
                "APIURL": "https://test.school.net",
                "SQLServer": "db.school.net",
                "Config": "Testing123"
                }'
            }
            Mock Import-Clixml {
                return New-Object System.Management.Automation.PSCredential "dummyUser", (ConvertTo-SecureString "dummyPassword" -AsPlainText -Force)
            }
            Mock Write-Verbose {}
            Mock Initialize-AeriesApi {}
        }

        It "Should call Get-Content 1 times" {
            $expectedName = "TestSchool"
            Set-SPSAeriesConfiguration -Name $expectedName -Verbose
            Assert-MockCalled Get-Content -Times 1 -Exactly
        }

        It "Should call Import-Clixml mock 2 times" {
            $expectedName = "TestSchool"
            Set-SPSAeriesConfiguration -Name $expectedName -Verbose
            Assert-MockCalled Import-Clixml -Times 2 -Exactly
        }

        It "Should find config name in the config object returned by Import-Clixml" {
            $expectedName = "Testing123"

            Set-SPSAeriesConfiguration -Name $expectedName -Verbose

            $configurations = Get-SPSAeriesConfiguration
            $configurations | Should -Contain $expectedObject
        }
    }
}