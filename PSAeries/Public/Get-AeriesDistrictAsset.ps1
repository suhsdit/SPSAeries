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
        [String[]]$AssetNumber
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-AeriesSQLDB
    }
    Process{
        $result = @()

        if ($AssetNumber) {
            $SQLCommand.CommandText = "SELECT * FROM $SQLDB.dbo.DRT WHERE RID = $AssetNumber"
        } else {
            $SQLCommand.CommandText = "SELECT * FROM $SQLDB.dbo.DRT"
        }

        $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCommand
        $DataSet = New-Object System.Data.DataSet
        $SqlAdapter.Fill($DataSet)
        
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
                'Publiser' = $_.PB;
                'Copyright Year' = $_.CR;
                'Approval Date' = $_.AD;
                'Vendor' = $_.VN;
                'Catalog' = $_.CT;
                'Replacement Cost' = $_.RC;
                'Library of Congress Number' = $_.LB;
                'ISBN' = $_.IS;
                # Aeries API says these fields are Not used
                #'D1' = $_.D1;
                #'D2' = $_.D2;
                #'D3' = $_.D3;
                #'D4' = $_.D4;
                'C1' = $_.C1;
                'C2' = $_.C2;
                'C3' = $_.C3;
                'User Code 1' = $_.U1;
                'User Code 2' = $_.U2;
                'User Code 3' = $_.U3;
                'User Code 4' = $_.U4;
                'User Code 5' = $_.U5;
                'User Code 6' = $_.U6;
                'User Code 7' = $_.U7;
                'User Code 8' = $_.U8;
                'Type' = $_.TY;
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