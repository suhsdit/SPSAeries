Function Get-AeriesDistrictAssetItem{
<#
.SYNOPSIS
    Get district asset Item from SQL DB
.DESCRIPTION
    The Get-AeriesDistrictAssetItem function gets each item that has a unique barcode and is what gets checked in/out to individuals (i.e. a textbook, chromebook, etc.). For example, an individual English textbook is considered an item.
.EXAMPLE
    Get-AeriesDistrictAssetItem -Barcode 8675309
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
        # ToDo - better build parameters to work together / separately.
        [String[]]$Barcode
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-AeriesSQLDB
    }
    Process{
        $result = @()

        if ($Barcode) {
            $SQLCommand.CommandText = "SELECT * FROM $SQLDB.dbo.DRI WHERE RID = $AssetNumber"
        } else {
            $SQLCommand.CommandText = "SELECT * FROM $SQLDB.dbo.DRI"
        }

        $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCommand
        $DataSet = New-Object System.Data.DataSet
        $SqlAdapter.Fill($DataSet)
        
        $DataSet.Tables[0] | ForEach-Object {
            $Asset = [PSCustomObject]@{
                'Asset Title Number' = $_.RID;
                'Asset Item Number' = $_.RIN;
                'Barcode' = $_.BC;
                'Room' = $_.RM;
                'Condition' = $_.CC;
                'Status' = $_.ST;
                'Code' = $_.CD;
                'Comment' = $_.CO;
                'School' = $_.SCL;
                'Price' = $_.PR;
                'Warehouse' = $_.WH;
                'Serial Number' = $_.SR;
                'MAC Address' = $_.MAC;
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