Function Get-AeriesDistrictAsset{
<#
.SYNOPSIS
    Get district asset from SQL DB
.DESCRIPTION
    The Get-AeriesDistrictAsset function gets asset data from the Aeries DB.
.EXAMPLE
    Get-AeriesDistrictAsset -Code CB
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
        [String[]]$Code
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-AeriesSQLDB
    }
    Process{
        if ($Code) {
            # SQL command here
        }

        else {
            $SQLCommand.CommandText = "SELECT * FROM $($SQLDB).dbo.DRT"
            $reader = $SQLCommand.ExecuteReader()
            $Counter = $Reader.FieldCount
            while ($Reader.Read()) {
                for ($i = 0; $i -lt $Counter; $i++) {
                    @{ $Reader.GetName($i) = $Reader.GetValue($i); }
                }
            }
        }
       <#
       .SYNOPSIS
       Short description
       
       .DESCRIPTION
       Long description
       
       .PARAMETER Code
       Parameter description
       
       .EXAMPLE
       An example
       
       .NOTES
       General notes
       #>
    }
    End{
        $Script:SQLConnection.Close()
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}