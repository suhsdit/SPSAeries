Function Invoke-SPSAeriesSqlQuery {
    <#
    .SYNOPSIS
        Executes SQL queries against the Aeries database specified in an SPSAeries configuration.
    .DESCRIPTION
        This function allows you to run arbitrary SQL queries against the configured Aeries SQL database.
        It can take a query as a string, or read it from a .sql file.
        It leverages saved SPSAeries configurations for database connection details, simplifying ad-hoc data access and manipulation.
        The function supports returning data as PowerShell objects, DataTables, a single scalar value, or executing non-query commands.
        Safety checks are in place for queries that appear to modify data, requiring confirmation unless -Force is used.
    .PARAMETER Query
        The SQL query string to execute. Mutually exclusive with -Path.
    .PARAMETER Path
        The full path to a .sql file containing the SQL query to execute. Mutually exclusive with -Query.
    .PARAMETER ConfigName
        The name of the SPSAeries configuration to use. 
        If not specified, the function will attempt to use the currently active configuration (set by Set-SPSAeriesConfiguration).
    .PARAMETER As
        Determines how the query results are returned.
        - PSObject (Default): Returns an array of PSCustomObjects.
        - DataTable: Returns a System.Data.DataTable object.
        - NonQuery: For DML/DDL. Does not return data rows but indicates success/failure.
        - Scalar: For queries expected to return a single value.
    .PARAMETER QueryTimeout
        Specifies the query timeout in seconds. Defaults to 30.
    .PARAMETER Force
        Suppresses the confirmation prompt for queries that appear to modify data or schema.
    .EXAMPLE
        Invoke-SPSAeriesSqlQuery -Query "SELECT TOP 10 STU.ID, STU.LN, STU.FN FROM STU" -ConfigName "MySchool"
        # Executes the SELECT query against 'MySchool' configuration and returns results as PSObjects.

    .EXAMPLE
        Invoke-SPSAeriesSqlQuery -Path ".\MyQueries\GetStudentCount.sql" -As Scalar
        # Executes query from file, expects a single value, uses active configuration.

    .EXAMPLE
        Invoke-SPSAeriesSqlQuery -Query "UPDATE STU SET TG = 'X' WHERE ID = 12345" -Force
        # Executes an UPDATE query, bypassing the confirmation prompt, using active configuration.

    .EXAMPLE
        Get-Content ".\MyQueries\ComplexQuery.sql" | Invoke-SPSAeriesSqlQuery -As DataTable
        # Pipes a query from a file into the function, returns a DataTable, using active configuration.
    .NOTES
        Requires the 'SqlServer' PowerShell module for Invoke-Sqlcmd.
        Ensure that the specified or active SPSAeries configuration has correct SQL server details and credentials.
    .LINK
        Get-SPSAeriesConfiguration
        Set-SPSAeriesConfiguration
        New-SPSAeriesConfiguration
    #>
    [CmdletBinding(DefaultParameterSetName = 'DirectQuery', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]પરા
    Param(
        [Parameter(Mandatory = $true,
            ParameterSetName = 'DirectQuery',
            HelpMessage = 'The SQL query string.')]
        [string]$Query,

        [Parameter(Mandatory = $true,
            ParameterSetName = 'FromFile',
            HelpMessage = 'Path to a .sql file containing the query.')]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$Path,

        [Parameter(Mandatory = $false,
            HelpMessage = 'SPSAeries configuration name to use.')]
        [string]$ConfigName,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Output format: PSObject, DataTable, NonQuery, Scalar.')]
        [ValidateSet('PSObject', 'DataTable', 'NonQuery', 'Scalar')]
        [string]$As = 'PSObject',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Query timeout in seconds.')]
        [int]$QueryTimeout = 30,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Suppresses confirmation for modifying queries.')]
        [switch]$Force
    )

    Begin {
        Write-Verbose "Starting $($MyInvocation.InvocationName) with ParameterSetName '$($PsCmdlet.ParameterSetName)'"

        if (-not (Get-Command Invoke-Sqlcmd -ErrorAction SilentlyContinue)) {
            Throw "The 'SqlServer' PowerShell module is not installed or 'Invoke-Sqlcmd' is not available. Please install it by running: Install-Module SqlServer -Scope CurrentUser"
        }

        $resolvedQuery = $null
        if ($PsCmdlet.ParameterSetName -eq 'FromFile') {
            try {
                $resolvedQuery = Get-Content -Path $Path -Raw -ErrorAction Stop
                Write-Verbose "Successfully read query from file: $Path"
            }
            catch {
                Throw "Failed to read query from file '$Path': $($_.Exception.Message)"
            }
        }
        else {
            $resolvedQuery = $Query
        }

        if ([string]::IsNullOrWhiteSpace($resolvedQuery)) {
            Throw "The SQL query is empty or could not be loaded."
        }
    }

    Process {
        try {
            # Determine the configuration name
            $effectiveConfigName = $null
            $spsAeriesConfigRootPath = "$Env:USERPROFILE\AppData\Local\powershell\SPSAeries"

            if ($PSBoundParameters.ContainsKey('ConfigName')) {
                $effectiveConfigName = $ConfigName
                Write-Verbose "Using specified configuration: $effectiveConfigName"
            }
            elseif ($Script:SPSAeriesConfigName) {
                $effectiveConfigName = $Script:SPSAeriesConfigName
                Write-Verbose "Using active SPSAeries configuration: $effectiveConfigName"
            }
            else {
                $availableConfigs = Get-ChildItem -Path $spsAeriesConfigRootPath -Directory | Select-Object -ExpandProperty Name
                $availableConfigsString = $availableConfigs -join ', '
                Throw "No -ConfigName specified and no active SPSAeries configuration found. Available configurations: $($availableConfigsString). Please use Set-SPSAeriesConfiguration or specify -ConfigName."
            }

            $targetConfigPath = Join-Path -Path $spsAeriesConfigRootPath -ChildPath $effectiveConfigName

            if (-not (Test-Path $targetConfigPath -PathType Container)) {
                Throw "Configuration directory '$effectiveConfigName' not found at '$targetConfigPath'."
            }

            # Load configuration details
            $configJsonPath = Join-Path -Path $targetConfigPath -ChildPath "config.json"
            $sqlCredsXmlPath = Join-Path -Path $targetConfigPath -ChildPath "sqlcreds.xml"

            if (-not (Test-Path $configJsonPath -PathType Leaf)) {
                Throw "config.json not found for configuration '$effectiveConfigName' at '$configJsonPath'."
            }
            if (-not (Test-Path $sqlCredsXmlPath -PathType Leaf)) {
                Throw "sqlcreds.xml not found for configuration '$effectiveConfigName' at '$sqlCredsXmlPath'."
            }

            $loadedConfig = Get-Content -Raw -Path $configJsonPath | ConvertFrom-Json -ErrorAction Stop
            $loadedSqlCreds = Import-Clixml -Path $sqlCredsXmlPath -ErrorAction Stop

            Write-Verbose "Successfully loaded configuration for '$effectiveConfigName' (Server: $($loadedConfig.SQLServer), DB: $($loadedConfig.SQLDB))"

            # Safety check for modifying queries
            $isModifyingQuery = $false
            if ($resolvedQuery.ToLower() -match '^\s*(insert|update|delete|create|alter|drop|truncate|execute|exec|merge)\s') {
                $isModifyingQuery = $true
                Write-Verbose "Query appears to be a data/schema modification query."
            }

            if ($isModifyingQuery -and (-not $Force)) {
                if (-not ($PSCmdlet.ShouldProcess("SQL Server: $($loadedConfig.SQLServer), Database: $($loadedConfig.SQLDB)", "Execute Modifying SQL Query"))) {
                    Write-Warning "Execution cancelled by user."
                    return
                }
            }

            $sqlCmdParams = @{
                ServerInstance = $loadedConfig.SQLServer
                Database       = $loadedConfig.SQLDB
                Credential     = $loadedSqlCreds
                QueryTimeout   = $QueryTimeout
                TrustServerCertificate = $true
                ErrorAction    = 'Stop' # Ensure script stops on SQL errors
            }

            if ($PsCmdlet.ParameterSetName -eq 'FromFile') {
                $sqlCmdParams.InputFile = $Path
            } else {
                $sqlCmdParams.Query = $resolvedQuery
            }

            if ($As -eq 'Scalar') {
                $sqlCmdParams.ExecuteAs = 'Scalar'
            }

            Write-Verbose "Executing SQL query against $($loadedConfig.SQLServer)/$($loadedConfig.SQLDB)..."
            $results = Invoke-Sqlcmd @sqlCmdParams
            
            if ($null -eq $results -and $As -ne 'NonQuery' -and $As -ne 'Scalar') {
                 Write-Verbose "Query returned no data."
                 return # Return nothing explicitly for empty PSObject/DataTable if results are null
            }

            switch ($As) {
                'PSObject' {
                    if ($results -is [System.Data.DataRow]) { $results = @($results) } # Handle single row result
                    if ($results -is [System.Data.DataRow[]]) {
                        $output = @()
                        foreach ($row in $results) {
                            $obj = New-Object PSCustomObject
                            foreach ($col in $row.Table.Columns) {
                                $obj | Add-Member -MemberType NoteProperty -Name $col.ColumnName -Value $row[$col.ColumnName]
                            }
                            $output += $obj
                        }
                        Write-Output $output
                    } else {
                        # This case might occur if Invoke-Sqlcmd returns something unexpected for PSObject that isn't DataRows
                        Write-Output $results 
                    }
                }
                'DataTable' {
                    if ($results -is [System.Data.DataRow]) { $results = @($results) } # Handle single row result
                    if ($results -is [System.Data.DataRow[]] -and $results.Count -gt 0) {
                        Write-Output $results[0].Table
                    }
                    # If $results is null or not DataRow[], it means no data for DataTable or already a different type
                    # Or if it was a non-SELECT query that still returned null (NonQuery would be better 'As' type here)
                }
                'NonQuery' {
                    Write-Verbose "NonQuery operation completed."
                    # Invoke-Sqlcmd typically doesn't return output for DML/DDL unless there's an error (which ErrorAction Stop would catch)
                    # Or it might return messages if -Verbose is passed to Invoke-Sqlcmd, but we're not doing that directly.
                    # We can assume success if no exception was thrown.
                }
                'Scalar' {
                    Write-Output $results
                }
            }
        }
        catch {
            Write-Error "An error occurred while executing the SQL query: $($_.Exception.Message)"
            if ($_.Exception.InnerException) {
                Write-Error "Inner Exception: $($_.Exception.InnerException.Message)"
            }
            # For more detailed SQL errors if available from Invoke-Sqlcmd exception
            if ($_.Exception.ErrorRecord.Exception -is [System.Data.SqlClient.SqlException]) {
                 foreach ($sqlError in $_.Exception.ErrorRecord.Exception.Errors) {
                    Write-Error "SQL Error $($sqlError.Number) on Line $($sqlError.LineNumber): $($sqlError.Message)"
                 }
            }
        }
    }

    End {
        Write-Verbose "Ending $($MyInvocation.InvocationName)."
    }
}
