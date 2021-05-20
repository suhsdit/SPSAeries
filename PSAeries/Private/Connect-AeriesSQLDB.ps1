function Connect-AeriesSQLDB {
    $Script:SQLServer = $Config.SQLServer
    $Script:SQLUser = $SQLCreds.GetNetworkCredential().UserName
    $Script:SQLPassword = $SQLCreds.GetNetworkCredential().Password
    $Script:SQLDB = $Config.SQLDB

    $Script:SQLConnection = New-Object System.Data.SqlClient.SqlConnection
    $Script:SQLCommand = New-Object System.Data.SqlClient.SqlCommand

    $Script:SQLConnection.ConnectionString = "Server="+$SQLServer+";Database="+$SQLDB+";User ID="+$SQLUser+";Password="+$SQLPassword
    $Script:SQLConnection.Open()
    $Script:SQLCommand.Connection = $SQLConnection

    $Script:SQLSplat = @{
        ServerInstance = $SQLSERVER
        Credential = $SQLCreds
        DatabaseName = $SQLDB
        SchemaName = 'dbo'
    }

    $Script:InvokeSQLSplat = @{
        ServerInstance = $SQLSERVER
        Credential = $SQLCreds
        Database = $SQLDB
    }
}