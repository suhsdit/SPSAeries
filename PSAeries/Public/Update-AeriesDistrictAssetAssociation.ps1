# May want to reconsider how New-AeriesDistrictAssetAssociation and Update-AeriesDistrictAssetAssociation operate.
# One option would be to get rid of New- and run everything out of update and have -checkin and -checkout parameters
# Another option would be to make aliases the run those functions ex. CheckIn-AeriesDistrictAsset & CheckOut-AeriesDistrictAsset
Function Update-AeriesDistrictAssetAssociation {
<#
.SYNOPSIS
    Updates District Asset Association in Aeries
.DESCRIPTION
    The Update-AeriesDistrictAssetAssociation function uses SQL to update a new District Asset Association in the Aeries DB.
.EXAMPLE
    Update-AeriesDistrictAssetAssociation
.PARAMETER
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>
    [CmdletBinding()] #Enable all the default paramters, including -Verbose
    Param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$true,
            # HelpMessage='HelpMessage',
            Position=0)]
        [Alias("RID")]
        [int]$AssetTitleNumber,

        [Parameter(Mandatory=$true,
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$true,
            # HelpMessage='HelpMessage',
            Position=1)]
        [Alias("RIN")]
        [int]$AssetItemNumber,

        [Alias("CO")]
        [String]$Comment,

        [switch]$CheckIn
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-AeriesSQLDB
    }
    Process{
        $CurrentAsset = (Get-AeriesDistrictAssetAssociation -AssetTitleNumber $AssetTitleNumber -AssetItemNumber $AssetItemNumber) | Select-Object -Last 1
        $query = "UPDATE $SQLDB.dbo.DRA SET "
        $DateTime = Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'

        if ($CurrentAsset) {
            if ($CheckIn) {$query += "RD = '$DateTime', "}
            if ($Comment) {$query += "CO = '$Comment', "}
        }
        
        # Delete's the last ', ' on the query
        $query = $query -replace ".{2}$"

        $query += " WHERE RID = $AssetTitleNumber AND RIN = $AssetItemNumber AND SQ = $($CurrentAsset.SQ)"

        Write-Verbose $query
        Invoke-Sqlcmd @InvokeSQLSplat -Query $query

        #check this, left off here
        #if ($CheckIn) {$query = "UPDATE $SQLDB.dbo.DRI SET ST = '' WHERE RID = $AssetTitleNumber AND RIN = $AssetItemNumber AND SQ = $($CurrentAsset.SQ)"}
    }
    End{
        $Script:SQLConnection.Close()
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}