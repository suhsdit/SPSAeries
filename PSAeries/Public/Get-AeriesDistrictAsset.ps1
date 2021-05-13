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
        [String]$Email,

        # Update Password
        [Parameter(Mandatory=$False)]
        [String]$Password #Should probably change this to SecureString
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-AeriesSQLDB
    }
    Process{
        if ($Email) {
            $SQLCommand.CommandText = "UPDATE $($SQLDB).dbo.STU SET STU.SEM = ('"+$Email+"') Where STU.ID = '"+$ID+"'"
            Write-Verbose $SQLCommand.CommandText
            $SQLCommand.ExecuteNonQuery()|Out-Null
        }

        if ($Password) {
            $SQLCommand.CommandText = "UPDATE $($SQLDB).dbo.STU SET STU.NID = ('"+$Password+"') Where STU.ID = '"+$ID+"'"
		    $SQLCommand.ExecuteNonQuery()|Out-Null
        }
    }
    End{
        $Script:SQLConnection.Close()
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}