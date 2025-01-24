Function Get-SPSAeriesStudentVerificationPassCode{
<#
.SYNOPSIS
    Get Student Verification Pass Code from SQL DB - STU.VPC
.DESCRIPTION
    The Get-SPSAeriesStudentVerificationPassCode function retrieves the Student's Aeries VPC from the Aeries DB.
.EXAMPLE
    Get-SPSAeriesStudentVerificationPassCode -ID 12345
.PARAMETER
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            # HelpMessage='HelpMessage',
            Position=0)]
        # ToDo - better build parameters to work together / separately.
        [int]$ID
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-AeriesSQLDB
        $result = @()
    }
    Process{
        $query = "SELECT ID, VPC FROM $SQLDB.dbo.STU "
        if ($ID) {
            $query += "WHERE ID = '$ID'"
        }

        Write-Verbose "Query = $($query)"

        try {
            $SQLData = Invoke-Sqlcmd @InvokeSQLSplat -Query $query
        } catch {
            Write-Error "Failed to execute SQL query: $_"
            return
        }

        $result = [System.Collections.ArrayList]::new()
        $SQLData | ForEach-Object {
            $row = [PSCustomObject]@{
                'StudentID' = $_.ID
                'VerificationPassCode' = $_.VPC
            }
            $result.Add($row) | Out-Null
        }
        $result.ToArray() # Return as an array for pipeline compatibility
    }
    End{
        $Script:SQLConnection.Close()
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}