Function Get-SPSAeriesStaffEmail{
<#
.SYNOPSIS
    Get Staff Email from SQL DB - STF.EM
.DESCRIPTION
    The Get-SPSAeriesStaffEmail function retrieves the email address for a staff member from the Aeries DB.
    This differs from the Get-SPSAeriesStaff function in that it only returns the email address from STF.EM,
    whereas Get-SPSAeriesStaff's EmailAddress property will return from STF.EM only if UGN.EM does not exist,
    otherwise it will return UGN.EM.
.EXAMPLE
    Get-SPSAeriesStaffEmail -ID 12345
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
        $query = "SELECT ID, [EM] FROM $SQLDB.dbo.STF "
        if ($ID) {$query += "WHERE ID = $ID"}

        Write-Verbose "Query = $($query)"
        $SQLData = Invoke-Sqlcmd @InvokeSQLSplat -Query $query

        $SQLData | ForEach-Object {
            $Asset = [PSCustomObject]@{
                'StaffID' = $_.ID
                'EmailAddress' = $_.EM
            }
            $result += $Asset
        }
        $result
    }
    End{
        $Script:SQLConnection.Close()
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}