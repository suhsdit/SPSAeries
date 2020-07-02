<#
Config for PSAeries Module
#>

@{
    # URL to access Aeries API
    APIURL = ''
    # Aeries API Key
    APIKey = ''
    # Array of Aeries School Codes to pull students from
    schoolcodes = @("1")
    # SQLServer address
    $SQLServer = ''
    # Which database to use
    $SQLDB = ''
    # Will probably move this to individual functions, placing here as a reminder
    $SQLTable = ''
}