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
        $result = @()

        if ($Code) {
            # SQL command here
        }

        else {
            $SQLCommand.CommandText = "SELECT * FROM $($SQLDB).dbo.DRT"
            $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
            $SqlAdapter.SelectCommand = $SqlCommand
            $DataSet = New-Object System.Data.DataSet
            $SqlAdapter.Fill($DataSet)
        }
        
        $DataSet.Tables[0] | ForEach-Object {
            $Asset = [PSCustomObject]@{
                'Asset#' = $_.RID;
                'Title' = $_.TI;
                'Author' = $_.AU;
                'Edition' = $_.ED;
                'Copies' = $_.CP;
                'Available' = $_.AV;
                'First#' = $_.FC;
                'Last#' = $_.LC;
                'Price' = $_.PR;
                'Department' = $_.DP;
            }
            $result += $Asset
        }
        $result
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