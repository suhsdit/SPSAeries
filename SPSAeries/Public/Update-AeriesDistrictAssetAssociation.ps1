# May want to reconsider how New-SPSAeriesDistrictAssetAssociation and Update-SPSAeriesDistrictAssetAssociation operate.
# One option would be to get rid of New- and run everything out of update and have -checkin and -checkout parameters
# Another option would be to make aliases the run those functions ex. CheckIn-AeriesDistrictAsset & CheckOut-AeriesDistrictAsset
Function Update-SPSAeriesDistrictAssetAssociation {
<#
.SYNOPSIS
    Updates District Asset Association in Aeries
.DESCRIPTION
    The Update-SPSAeriesDistrictAssetAssociation function uses SQL to update a new District Asset Association in the Aeries DB.
.EXAMPLE
    Update-SPSAeriesDistrictAssetAssociation
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
        $CurrentAsset = (Get-SPSAeriesDistrictAssetAssociation -AssetTitleNumber $AssetTitleNumber -AssetItemNumber $AssetItemNumber) | Select-Object -Last 1
        if (!$CurrentAsset) {
            Write-Error "No association to update. Try using New-SPSAeriesDistrictAssetAssociation."
            return
        }
        
        $query = "UPDATE $SQLDB.dbo.DRA SET "
        $DateTime = Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'
        
        if ($Comment) {$query += "CO = '$Comment', "}
        # Should probably build in a check to see if it's already checked in first.
        if ($CheckIn) {$query += "RD = '$DateTime', "
            Update-SPSAeriesDistrictAssetItem -AssetTitleNumber $AssetTitleNumber -AssetItemNumber $AssetItemNumber -NewStatus None
        }
        
        # Delete's the last ', ' on the query
        $query = $query -replace ".{2}$"

        $query += " WHERE RID = $AssetTitleNumber AND RIN = $AssetItemNumber AND SQ = $($CurrentAsset.SQ)"

        Write-Verbose $query
        Invoke-Sqlcmd @InvokeSQLSplat -Query $query
    }
    End{
        $Script:SQLConnection.Close()
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}