Function Update-AeriesStudent{
<#
.SYNOPSIS
    Updates data in SQL DB For an Aeries Student
.DESCRIPTION
    The Update-AeriesStudent function updates data for a student in the Aeries DB.
.EXAMPLE
    Update-AeriesStudent -ID 12345 -email "littlejohnny@school.edu"
    Update student with ID number 12345 email address value to be littlejohny@school.edu in Aeries DB.
.PARAMETER
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>
    [CmdletBinding()] #Enable all the default paramters, including -Verbose
    Param(
        [Parameter(Mandatory=$false,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            # HelpMessage='HelpMessage',
            Position=0)]
        [ValidatePattern('[0-9]')] #Validate that the string only contains Numbers
        [Alias("User", "StudentID")]
        [String[]]$ID,

        # Email address to update
        [Parameter(Mandatory=$False)]
        [String]$Email
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        
        #SQL Params (move this into a private function?)
        #SQL Server Settings
        $SQLServer = $Config.SQLServer
        $SQLUser = $SQLCreds.GetNetworkCredential().UserName
        $SQLPassword = $SQLCreds.GetNetworkCredential().Password
        $SQLDB = $Config.SQLDB
        $SQLTable = "STU"

        $SQLConnection = New-Object System.Data.SqlClient.SqlConnection
        $SQLCommand = New-Object System.Data.SqlClient.SqlCommand

        $SQLConnection.ConnectionString = "Server="+$SQLServer+";Database="+$SQLDB+";User ID="+$SQLUser+";Password="+$SQLPassword
        $SQLConnection.Open()
        $SQLCommand.Connection = $SQLConnection

    }
    Process{
        $SQLCommand.CommandText = "UPDATE $($SQLDB).dbo.STU SET STU.SEM = ('"+$Email+"') Where STU.ID = '"+$ID+"'"
        Write-Verbose $SQLCommand.CommandText
		$SQLCommand.ExecuteNonQuery()|Out-Null
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}