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

    .PARAMETER As
        Determines how the query results are returned.
        - PSObject (Default): Returns an array of PSCustomObjects.
        - DataTable: Returns a System.Data.DataTable object.
        - NonQuery: For DML/DDL. Does not return data rows but indicates success/failure.
        - Scalar: For queries expected to return a single value.
    .PARAMETER QueryTimeout
        Specifies the query timeout in seconds. Defaults to 30.
    .PARAMETER MaxRetries
        Number of retry attempts for transient failures (e.g., deadlocks). Defaults to 5.
    .PARAMETER RetryDelaySeconds
        Delay in seconds between retry attempts. Defaults to 5.
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
    .NOTES
        Uses the existing SQL connection method from Connect-AeriesSQLDB.
        Ensure that the specified or active SPSAeries configuration has correct SQL server details and credentials.
    .LINK
        Get-SPSAeriesConfiguration
        Set-SPSAeriesConfiguration
        New-SPSAeriesConfiguration
    #>
    [CmdletBinding(DefaultParameterSetName = 'DirectQuery', 
                   SupportsShouldProcess = $true, 
                   ConfirmImpact = 'Medium')]
    Param(
        [Parameter(Mandatory = $true,
            ParameterSetName = 'DirectQuery',
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = 'The SQL query string.')]
        [ValidateNotNullOrEmpty()]
        [string]$Query,

        [Parameter(Mandatory = $true,
            ParameterSetName = 'FromFile',
            HelpMessage = 'Path to a .sql file containing the query.')]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$Path,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Output format: PSObject, DataTable, NonQuery, Scalar.')]
        [ValidateSet('PSObject', 'DataTable', 'NonQuery', 'Scalar')]
        [string]$As = 'PSObject',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Query timeout in seconds.')]
        [int]$QueryTimeout = 30,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Number of retry attempts for transient failures.')]
        [int]$MaxRetries = 5,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Delay in seconds between retry attempts.')]
        [int]$RetryDelaySeconds = 5,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Suppresses confirmation for modifying queries.')]
        [switch]$Force
    )

    Begin {
        Write-Verbose "Starting $($MyInvocation.InvocationName) with ParameterSetName '$($PsCmdlet.ParameterSetName)'"

        # Get the query from file if Path parameter is used
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
        # Use the global configuration set by Set-SPSAeriesConfig
        if (-not $Script:Config -or -not $Script:SQLCreds) {
            throw "No active SPSAeries configuration found. Please run Set-SPSAeriesConfiguration first."
        }
        
        # Set the config to use the existing Connect-AeriesSQLDB function
        $Script:Config = $Script:Config  # Keep existing config
        
        Write-Verbose "Using active SPSAeries configuration (Server: $($Script:Config.SQLServer), DB: $($Script:Config.SQLDB))"

        # Safety check for modifying queries
        $isModifyingQuery = $false
        $queryFirstWord = ($resolvedQuery -split '\s+', 2 | Select-Object -First 1).ToLower()
        $modifyingVerbs = @('insert', 'update', 'delete', 'create', 'alter', 'drop', 'truncate', 'execute', 'exec', 'merge', 'grant', 'revoke', 'deny')
        
        if ($modifyingVerbs -contains $queryFirstWord) {
            $isModifyingQuery = $true
            Write-Verbose "Query appears to be a data/schema modification query (starts with: $queryFirstWord)."
        }

        if ($isModifyingQuery -and (-not $Force)) {
            if (-not ($PSCmdlet.ShouldProcess("SQL Server: $($Script:Config.SQLServer), Database: $($Script:Config.SQLDB)", "Execute Modifying SQL Query"))) {
                Write-Warning "Execution cancelled by user."
                return
            }
        }

        # Retry loop for handling transient failures
        $attempt = 0
        $maxAttempts = $MaxRetries + 1  # Initial attempt + retries
        $success = $false
        $lastException = $null
        
        while (-not $success -and $attempt -lt $maxAttempts) {
            $attempt++
            
            try {
                if ($attempt -gt 1) {
                    Write-Warning "Retry attempt $($attempt - 1) of $MaxRetries after waiting $RetryDelaySeconds seconds..."
                    Start-Sleep -Seconds $RetryDelaySeconds
                }
                
                # Call the existing Connect-AeriesSQLDB function to set up the connection
                Connect-AeriesSQLDB
                
                # Check if connection was successful
                if (-not $Script:SQLConnection -or $Script:SQLConnection.State -ne 'Open') {
                    throw "Failed to establish SQL connection to $($Script:Config.SQLServer)."
                }
                
                # Create and execute the command
                $command = New-Object System.Data.SqlClient.SqlCommand($resolvedQuery, $Script:SQLConnection)
                $command.CommandTimeout = $QueryTimeout
                
                # Execute based on the output type
                if ($attempt -eq 1) {
                    Write-Verbose "Executing SQL query against $($Script:Config.SQLServer)/$($Script:Config.SQLDB)..."
                }
                
                if ($As -eq 'Scalar') {
                    $results = $command.ExecuteScalar()
                } elseif ($As -eq 'NonQuery') {
                    $results = $command.ExecuteNonQuery()
                } else {
                    # For PSObject or DataTable, we'll use a DataAdapter
                    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
                    $dataSet = New-Object System.Data.DataSet
                    $adapter.Fill($dataSet) | Out-Null
                    
                    if ($dataSet.Tables.Count -gt 0) {
                        if ($As -eq 'DataTable') {
                            $results = $dataSet.Tables[0]
                        } else {
                            # Convert DataTable to array of PSObjects
                            $results = @($dataSet.Tables[0] | ForEach-Object { [PSCustomObject]$_ })
                        }
                    } else {
                        # Create an appropriate empty result based on output type
                        if ($As -eq 'DataTable') {
                            $results = New-Object System.Data.DataTable
                        } else { # PSObject
                            $results = @()
                        }
                    }
                }
                
                # If we reach here, the query succeeded
                $success = $true
                
                # Add a verbose message for empty results in PSObject or DataTable
                if ($As -in @('PSObject', 'DataTable') -and 
                    (($As -eq 'PSObject' -and $results.Count -eq 0) -or 
                     ($As -eq 'DataTable' -and $results.Rows.Count -eq 0))) {
                    Write-Verbose "Query returned no data."
                }

                # Output the results based on the requested format
                switch ($As) {
                    'PSObject' {
                        # Results are already converted to PSObjects in the main execution block
                        Write-Output $results
                    }
                    'DataTable' {
                        # Results are already a DataTable when As is 'DataTable'
                        Write-Output $results
                    }
                    'NonQuery' {
                        # For NonQuery, output the number of rows affected
                        Write-Verbose "NonQuery operation completed. Rows affected: $results"
                        Write-Output $results
                    }
                    'Scalar' {
                        # For Scalar, output the single value
                        Write-Output $results
                    }
                }
            }
            catch {
                $lastException = $_
                $isRetriable = $false
                
                # Check if this is a retriable error (deadlock, timeout, connection issues)
                if ($_.Exception -is [System.Data.SqlClient.SqlException]) {
                    $sqlException = $_.Exception
                    # SQL Error codes for retriable errors:
                    # 1205 = Deadlock
                    # -2 = Timeout
                    # 40197, 40501, 40613, 49918, 49919, 49920 = Azure SQL transient errors
                    # 64 = Connection error
                    # 233 = Connection initialization error
                    $retriableErrorCodes = @(1205, -2, 40197, 40501, 40613, 49918, 49919, 49920, 64, 233)
                    
                    if ($retriableErrorCodes -contains $sqlException.Number) {
                        $isRetriable = $true
                        Write-Warning "Transient SQL error detected (Error $($sqlException.Number)): $($sqlException.Message)"
                    }
                }
                
                # If not retriable or we've exhausted retries, throw the error
                if (-not $isRetriable -or $attempt -ge $maxAttempts) {
                    $errorMessage = "An error occurred while executing the SQL query: $($_.Exception.Message)"
                    if ($_.Exception.InnerException) {
                        $errorMessage += "`nInner Exception: $($_.Exception.InnerException.Message)"
                    }
                    
                    # For SQL-specific errors
                    if ($_.Exception -is [System.Data.SqlClient.SqlException]) {
                        $sqlException = $_.Exception
                        $errorMessage += "`nSQL Error $($sqlException.Number): $($sqlException.Message)"
                        $errorMessage += "`nLine Number: $($sqlException.LineNumber)"
                        $errorMessage += "`nSource: $($sqlException.Source)"
                        $errorMessage += "`nServer: $($sqlException.Server)"
                        $errorMessage += "`nProcedure: $($sqlException.Procedure)"
                    }
                    
                    if ($attempt -ge $maxAttempts -and $isRetriable) {
                        $errorMessage += "`n`nQuery failed after $MaxRetries retry attempts."
                    }
                    
                    Write-Error $errorMessage -ErrorAction Stop
                }
            }
            finally {
                # Ensure the SQL connection is properly closed after each attempt
                if ($null -ne $Script:SQLConnection -and $Script:SQLConnection.State -eq 'Open') {
                    $Script:SQLConnection.Close()
                    $Script:SQLConnection.Dispose()
                    $Script:SQLConnection = $null
                }
            }
        }
    }

    End {
        Write-Verbose "Ending $($MyInvocation.InvocationName)."
    }
}
