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
        # ToDo - better build parameters to work together / separately.
        [String[]]$AssetTitleNumber,
        [String[]]$AssetItemNumber,
        [String[]]$UserID
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-AeriesSQLDB
        $result = @()
    }
    Process{
        $SQLData = $null

        if ($AssetTitleNumber) {
            $SQLData = Invoke-Sqlcmd @InvokeSQLSplat -Query "SELECT * FROM $SQLDB.dbo.DRA WHERE RID = $AssetTitleNumber"
        } elseif ($AssetItemNumber) {
            $SQLData = Invoke-Sqlcmd @InvokeSQLSplat -Query "SELECT * FROM $SQLDB.dbo.DRA WHERE RIN = $AssetItemNumber"
        } else {
            $SQLData = Invoke-Sqlcmd @InvokeSQLSplat -Query "SELECT * FROM $SQLDB.dbo.DRA"
        }
        
        $SQLData | ForEach-Object {
            $Asset = [PSCustomObject]@{
                'Asset Title Number' = $_.RID;
                'Asset Item Number' = $_.RIN;
                'SQ' = $_.SQ;
                'User ID' = $_.ID;
                'User Type' = $_.ST;
                'PD' = $_.PD; # Documentation says this is not used
                'RM' = $_.RM; # Documentation says this is not used
                'CN' = $_.CN; # Documentation says this is not used
                'SE' = $_.SE; # Documentation says this is not used
                'Condition' = $_.CC; # Documentation says not currently used. Populated blank.
                'Code' = $_.CD; # Documentation says not currently used. Populated blank.
                'Comment' = $_.CO;
                'School' = $_.SCL;
                'Date Issued' = $_.DT;
                'Date Returned' = $_.RD;
                'Due Date' = $_.DD;
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