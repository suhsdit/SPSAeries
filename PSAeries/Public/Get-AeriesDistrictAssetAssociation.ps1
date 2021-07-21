Function Get-AeriesDistrictAssetAssociation{
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

        [String[]]$AssetTitleNumber,

        [String[]]$AssetItemNumber,

        [String[]]$UserID,

        [Parameter(Mandatory=$false)]
        [ArgumentCompletions('CheckedOut','CheckedIn',  'All')]
        [String]$AssetStatus
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-AeriesSQLDB
        $result = @()
    }
    Process{
        $SQLData = $null
        $query = "SELECT * FROM $SQLDB.dbo.DRA WHERE "

        if ($AssetTitleNumber) {$query += "RID = $AssetTitleNumber AND "}
        if ($AssetItemNumber) {$query += "RIN = $AssetItemNumber AND "}
        if ($UserID) {$query += "ID = $UserID AND "}
        if ($AssetStatus -eq 'CheckedOut') {$query += "RD is Null AND "}
        if ($AssetStatus -eq 'CheckedIn') {$query += "RD is Not Null AND "}

        # Delete's the last ' AND ' on the query
        $query = $query -replace ".{5}$"

        if (!$AssetTitleNumber -and !$AssetItemNumber -and !$UserID) {$query = "SELECT * FROM $SQLDB.dbo.DRA"}

        Write-Verbose $query
        $SQLData = Invoke-Sqlcmd @InvokeSQLSplat -Query $query
        
        $SQLData | ForEach-Object {
            $Asset = [PSCustomObject]@{
                'AssetTitleNumber' = $_.RID;
                'AssetItemNumber' = $_.RIN;
                'SQ' = $_.SQ;
                'UserID' = $_.ID;
                'UserType' = $_.ST;
                'PD' = $_.PD; # Documentation says this is not used
                'RM' = $_.RM; # Documentation says this is not used
                'CN' = $_.CN; # Documentation says this is not used
                'SE' = $_.SE; # Documentation says this is not used
                'Condition' = $_.CC; # Documentation says not currently used. Populated blank.
                'Code' = $_.CD; # Documentation says not currently used. Populated blank.
                'Comment' = $_.CO;
                'School' = $_.SCL;
                'DateIssued' = $_.DT;
                'DateReturned' = $_.RD;
                'DueDate' = $_.DD;
                'TG' = $_.TG; # Documentation says this is not used
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