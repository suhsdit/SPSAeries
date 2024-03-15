BeforeAll {
    . $PSScriptRoot\..\SPSAeries\SPSAeries.psm1
    Mock Get-Credential { return New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'user', (ConvertTo-SecureString 'password' -AsPlainText -Force) }
    $params = @{
        Name = 'test'
        APIURL = 'http://example.com'
        APIKey = Get-Credential -UserName 'user' -Message 'Enter your Aeries API Key'
        SQLServer = 'server'
        SQLDB = 'database'
        SQLCredentials = Get-Credential -UserName 'user' -Message 'Enter your Aeries SQL credentials'
    }
}

Describe "New-SPSAeriesConfiguration" {
    Context "when called with a new name" {
        BeforeEach {
            Mock Read-Host { return 'test' }
            Mock Get-Credential { return New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'user', (ConvertTo-SecureString 'password' -AsPlainText -Force) }
            Mock Test-Path { return $false }
            Mock New-Item {} -Verifiable
            Mock Out-File {} -Verifiable
            Mock Set-SPSAeriesConfiguration {}
            Mock Export-Clixml {}

            New-SPSAeriesConfiguration @params
        }

        It "creates a new configuration" {
            Should -Invoke New-Item -Times 1 -Exactly
        }
    }

    Context "when called with an existing name" {
        BeforeEach {
            Mock Read-Host { return 'test' }
            Mock Get-Credential { return New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'user', (ConvertTo-SecureString 'password' -AsPlainText -Force) }
            Mock Test-Path { return $true }
            Mock New-Item {}
            Mock Out-File {}
            Mock Set-SPSAeriesConfiguration {}
            Mock Export-Clixml {}

            New-SPSAeriesConfiguration @params
        }

        It "gives a warning and does not create a new configuration" {
            Should -Invoke New-Item -Times 0 -Exactly
        }
    }
}