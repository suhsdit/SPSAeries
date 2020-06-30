<#
Config for Create-NewGSuiteStudentsFromAeries.ps1
#>

@{
    #Log Location
    LogLocation = 'C:\Scripts\New-GSuiteStudentsFromAeries.log'
    #URL to access Aeries API
    APIURL = ''
    # Aeries API Key
    APIKey = ''
    # PSGSuite config to use
    PSGSConfig = ''
    # Array of Aeries School Codes to pull students from
    schoolcodes = @("1")
    EmailRegex = ''
    StudentPassword = ''
}