#region: Mock a config and load it for other functions to use
Mock 'Set-PSAeriesConfiguration' -ModuleName PSAeries -MockWith {
    Write-Verbose "Getting mocked PSAeries config"
    $script:PSAeries = [PSCustomObject][Ordered]@{
        ConfigName = 'Pester'
        APIKey = ([System.IO.Path]::Combine($PSScriptRoot,"fake_api_key.xml"))
        SQLCreds = ([System.IO.Path]::Combine($PSScriptRoot,"fake_sql_creds.xml"))
        SQLDB = "PesterDB"
        SQLServer = "AERIES-SERVER"
        APIURL = 'https://prefix.domain.com/api/v3/'
    }
}
Set-PSAeriesConfiguration -Verbose
#endregion

