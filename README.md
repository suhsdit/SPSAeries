# SPSAeries

*PowerShell module for Aeries SIS*

## About

SPSAeries is a PowerShell module developed by Shasta Union High School District (SUHSD) to supplement the official Aeries PS Module. The 'SPS' prefix stands for 'Shasta PowerShell'. While developed by SUHSD, the module is designed for general use and is published on the PowerShell Gallery for public use.

This module is designed to address specific needs and design gaps in the official Aeries API and PowerShell module, providing additional functionality and improved workflows for Aeries SIS administration. Redundant commands have been removed to focus on extending and enhancing the official module's capabilities.

## Latest Updates (v0.3.0)

### New Features
- Added `Invoke-SPSAeriesSqlQuery` function for flexible SQL query execution
  - Execute queries directly or from .sql files
  - Multiple output formats: PSObject, DataTable, NonQuery, Scalar
  - Built-in safety checks for modifying queries
  - Uses existing SPSAeries configuration

### Improvements
- Standardized configuration management using `Set-SPSAeriesConfiguration`
- Improved error handling and verbose logging
- Removed dependency on SqlServer module
- More consistent function naming and parameter sets

**Disclaimer**

We hold no responsibility for any unintended consequences of running this module, some commands will write directly to your Aeries SQL Database. Use with caution.

**Installation Instructions**

* Run New-PSAeriesConfiguration to setup new Aeries DB/API
  * You will need to create an APIKey in Aeries and give it the appropriate read privileges.
  * You will also need your SQL DB info if you wish to write into Aeries
  * Your SQL DB will need to be updated from one year to the next after you do an end of the year rollover.

Your API Key and SQL Credentials will be securely stored encrypted by the user account.

After that, you should be set, you can run New-PSAeriesConfiguration again to setup additional schools, and run "Set-PSAeriesConfiguration ConfigName" to switch between configs.

**Examples:**

*This will list student with ID Number 1234*

Get-AeriesStudent -ID 1234

-------------------------------

*This will list all students at school code 1*

Get-AeriesStudent -SchoolCode 1

-------------------------------

*This will list all students under all school codes*

Get-AeriesStudent

-------------------------------

*Accepts pipeline input for multiple Student ID's*

1234, 1235, 5567 | Get-AeriesStudent

-------------------------------

### Basic SQL Query
```powershell
# Simple SELECT query
Invoke-SPSAeriesSqlQuery -Query "SELECT TOP 10 * FROM STU"

# Execute a query from a file
Invoke-SPSAeriesSqlQuery -Path "C:\queries\students.sql"

# Get a single value
Invoke-SPSAeriesSqlQuery -Query "SELECT COUNT(*) FROM STU" -As Scalar

# Execute an UPDATE (will prompt for confirmation)
Invoke-SPSAeriesSqlQuery -Query "UPDATE STU SET TG = 'X' WHERE ID = 12345" -Force
```

### Working with Results
```powershell
# Get results as a DataTable
$students = Invoke-SPSAeriesSqlQuery -Query "SELECT * FROM STU" -As DataTable
$students | Where-Object { $_.GR -eq '12' } | Format-Table

# Process results with ForEach-Object
Invoke-SPSAeriesSqlQuery -Query "SELECT ID, LN, FN FROM STU WHERE GR = '12'" | ForEach-Object {
    [PSCustomObject]@{
        StudentID = $_.ID
        FullName = "$($_.LN), $($_.FN)"
    }
}
```

### Using with Other Functions
```powershell
# Get configuration details
Get-SPSAeriesConfiguration

# Set active configuration
Set-SPSAeriesConfiguration -ConfigName "Production"
```

**To Do**

Update 7/22: Built out functions to interact with Aeries District Assets. In my limited testing, everything appears to work as expected. Need to build out help more on those commands.

- Add more examples to documentation
- Expand test coverage
- Add support for parameterized queries
- Add transaction support for batch operations

## Changelog

### v0.3.0 (2025-05-20)
- Added `Invoke-SPSAeriesSqlQuery` function
- Standardized configuration management
- Improved error handling and logging
- Removed SqlServer module dependency

### v0.2.0
- Initial release of SPSAeries (formerly PSAeries)
- Focused on supplementing the official Aeries PS Module
- Improved configuration management