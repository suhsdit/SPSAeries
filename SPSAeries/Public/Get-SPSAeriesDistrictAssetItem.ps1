Function Get-SPSAeriesDistrictAssetItem{
<#
.SYNOPSIS
    Get district asset Item from SQL DB
.DESCRIPTION
    The Get-SPSAeriesDistrictAssetItem function gets each item that has a unique barcode and is what gets checked in/out to individuals (i.e. a textbook, chromebook, etc.). For example, an individual English textbook is considered an item.
.EXAMPLE
    Get-SPSAeriesDistrictAssetItem -Barcode 8675309
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
        [int]$AssetTitleNumber,
        [int]$AssetItemNumber
        #[String[]]$Barcode,
        #[String[]]$MACAddress,
        #[String[]]$Room
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-AeriesSQLDB
        $result = @()
    }
    Process{
        $SQLData = $null
        $query = "SELECT * FROM $SQLDB.dbo.DRI WHERE "

        if ($AssetTitleNumber) {$query += "RID = $AssetTitleNumber AND "}
        if ($AssetItemNumber) {$query += "RIN = $AssetItemNumber AND "}

        # Delete's the last ' AND ' on the query
        $query = $query -replace ".{5}$"
        
        if (!$AssetTitleNumber -and !$AssetItemNumber) {$query = "SELECT * FROM $SQLDB.dbo.DRI"}

        Write-Verbose "Query = $($query)"
        $SQLData = Invoke-Sqlcmd @InvokeSQLSplat -Query $query

        $SQLData | ForEach-Object {
            $Asset = [PSCustomObject]@{
                'AssetTitleNumber' = $_.RID;
                'AssetItemNumber' = $_.RIN;
                'Barcode' = $_.BC;
                'Room' = $_.RM;
                'Condition' = $_.CC;
                'Status' = $_.ST;
                'Code' = $_.CD;
                'Comment' = $_.CO;
                'School' = $_.SCL;
                'Price' = $_.PR;
                'Warehouse' = $_.WH;
                'SerialNumber' = $_.SR;
                'MACAddress' = $_.MAC;
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