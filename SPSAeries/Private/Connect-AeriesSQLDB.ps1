function Connect-AeriesSQLDB {
    if (-not $Config) {
        Write-Error "Config is null"
        return
    }

    if (-not $SQLCreds) {
        Write-Error "SQLCreds is null"
        return
    }

    $Script:SQLServer = $Config.SQLServer
    $Script:SQLUser = $SQLCreds.GetNetworkCredential().UserName
    $Script:SQLPassword = $SQLCreds.GetNetworkCredential().Password
    $Script:SQLDB = $Config.SQLDB

    $Script:SQLConnection = New-Object System.Data.SqlClient.SqlConnection
    $Script:SQLCommand = New-Object System.Data.SqlClient.SqlCommand

    $Script:SQLConnection.ConnectionString = "Server=$SQLServer;Database=$SQLDB;User ID=$SQLUser;Password=$SQLPassword"
    
    try {
        $Script:SQLConnection.Open()
    } catch {
        Write-Error "Failed to open SQL connection: $_"
        return
    }

    $Script:SQLCommand.Connection = $SQLConnection

    $Script:SQLSplat = @{
        ServerInstance = $SQLSERVER
        Credential = New-Object System.Management.Automation.PSCredential($SQLUser, (ConvertTo-SecureString $SQLPassword -AsPlainText -Force))
        DatabaseName = $SQLDB
        SchemaName = 'dbo'
    }

    $Script:InvokeSQLSplat = @{
        ServerInstance = $SQLSERVER
        Credential = New-Object System.Management.Automation.PSCredential($SQLUser, (ConvertTo-SecureString $SQLPassword -AsPlainText -Force))
        Database = $SQLDB
    }
}