function Connect-AeriesSQLDB {
    #SQL Params (move this into a private function?)
    #SQL Server Settings
    $Script:SQLServer = $Config.SQLServer
    $Script:SQLUser = $SQLCreds.GetNetworkCredential().UserName
    $Script:SQLPassword = $SQLCreds.GetNetworkCredential().Password
    $Script:SQLDB = $Config.SQLDB

    $Script:SQLConnection = New-Object System.Data.SqlClient.SqlConnection
    $Script:SQLCommand = New-Object System.Data.SqlClient.SqlCommand

    $Script:SQLConnection.ConnectionString = "Server="+$SQLServer+";Database="+$SQLDB+";User ID="+$SQLUser+";Password="+$SQLPassword
    $Script:SQLConnection.Open()
    $Script:SQLCommand.Connection = $SQLConnection
}