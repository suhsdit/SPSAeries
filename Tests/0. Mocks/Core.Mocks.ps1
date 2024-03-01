#region: Mock a config and load it for other functions to use
Mock 'Set-SPSAeriesConfiguration' -ModuleName SPSAeries -MockWith {
    Write-Verbose "Getting mocked SPSAeries config"
    $script:SPSAeries = [PSCustomObject][Ordered]@{
        ConfigName = 'Pester'
        APIKey = ([System.IO.Path]::Combine($PSScriptRoot,"fake_api_key.xml"))
        SQLCreds = ([System.IO.Path]::Combine($PSScriptRoot,"fake_sql_creds.xml"))
        SQLDB = "PesterDB"
        SQLServer = "AERIES-SERVER"
        APIURL = 'https://prefix.domain.com/api/v3/'
    }
}
Set-SPSAeriesConfiguration -Verbose
#endregion

