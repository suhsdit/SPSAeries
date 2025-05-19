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
        try {
            # Determine the configuration name
            $effectiveConfigName = $null
            $spsAeriesConfigRootPath = Join-Path -Path $env:USERPROFILE -ChildPath 'AppData\Local\powershell\SPSAeries'

            # Ensure the config root directory exists
            if (-not (Test-Path -Path $spsAeriesConfigRootPath -PathType Container)) {
                throw "SPSAeries configuration directory not found at '$spsAeriesConfigRootPath'. Please create a configuration first using New-SPSAeriesConfiguration."
            }

            if ($PSBoundParameters.ContainsKey('ConfigName')) {
                $effectiveConfigName = $ConfigName
                Write-Verbose "Using specified configuration: $effectiveConfigName"
            }
            elseif ($Script:SPSAeriesConfigName) {
                $effectiveConfigName = $Script:SPSAeriesConfigName
                Write-Verbose "Using active SPSAeries configuration: $effectiveConfigName"
            }
            else {
                $availableConfigs = Get-ChildItem -Path $spsAeriesConfigRootPath -Directory | 
                    Where-Object { 
                        Test-Path -Path (Join-Path $_.FullName 'config.json') -PathType Leaf -and
                        Test-Path -Path (Join-Path $_.FullName 'sqlcreds.xml') -PathType Leaf
                    } | 
                    Select-Object -ExpandProperty Name
                
                if (-not $availableConfigs) {
                    throw "No valid SPSAeries configurations found in '$spsAeriesConfigRootPath'. Please create a configuration first using New-SPSAeriesConfiguration."
                }
                
                $availableConfigsString = $availableConfigs -join ', '
                throw "No -ConfigName specified and no active SPSAeries configuration found. Available configurations: $availableConfigsString. Please use Set-SPSAeriesConfiguration or specify -ConfigName."
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
            $queryFirstWord = ($resolvedQuery -split '\s+', 2 | Select-Object -First 1).ToLower()
            $modifyingVerbs = @('insert', 'update', 'delete', 'create', 'alter', 'drop', 'truncate', 'execute', 'exec', 'merge', 'grant', 'revoke', 'deny')
            
            if ($modifyingVerbs -contains $queryFirstWord) {
                $isModifyingQuery = $true
                Write-Verbose "Query appears to be a data/schema modification query (starts with: $queryFirstWord)."
            }

            if ($isModifyingQuery -and (-not $Force)) {
                if (-not ($PSCmdlet.ShouldProcess("SQL Server: $($loadedConfig.SQLServer), Database: $($loadedConfig.SQLDB)", "Execute Modifying SQL Query"))) {
                    Write-Warning "Execution cancelled by user."
                    return
                }
            }

            # Set the config and creds to use the existing Connect-AeriesSQLDB function
            $Script:Config = $loadedConfig
            $Script:SQLCreds = $loadedSqlCreds
            
            # Call the existing Connect-AeriesSQLDB function to set up the connection
            . $PSScriptRoot\..\Private\Connect-AeriesSQLDB.ps1
            Connect-AeriesSQLDB
            
            # Check if connection was successful
            if (-not $Script:SQLConnection -or $Script:SQLConnection.State -ne 'Open') {
                throw "Failed to establish SQL connection to $($loadedConfig.SQLServer)."
            }
            
            # Create and execute the command
            $command = New-Object System.Data.SqlClient.SqlCommand($resolvedQuery, $Script:SQLConnection)
            $command.CommandTimeout = $QueryTimeout
            
            # Execute based on the output type
            Write-Verbose "Executing SQL query against $($loadedConfig.SQLServer)/$($loadedConfig.SQLDB)..."
            
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
                    $results = $null
                }
            }
            
            # Only check for null results if not a NonQuery or Scalar operation
            if ($As -notin @('NonQuery', 'Scalar') -and $null -eq $results) {
                Write-Verbose "Query returned no data."
                return # Return nothing explicitly for empty PSObject/DataTable if results are null
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
            
            Write-Error $errorMessage -ErrorAction Stop
        }
        finally {
            # Ensure the SQL connection is properly closed
            if ($null -ne $Script:SQLConnection -and $Script:SQLConnection.State -eq 'Open') {
                $Script:SQLConnection.Close()
                $Script:SQLConnection.Dispose()
                $Script:SQLConnection = $null
            }
        }
    }

    End {
        Write-Verbose "Ending $($MyInvocation.InvocationName)."
    }
}
