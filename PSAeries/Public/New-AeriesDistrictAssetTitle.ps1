Function New-AeriesDistrictAssetTitle {
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
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$true,
            # HelpMessage='HelpMessage',
            Position=0)]
        [Alias("Title")]
        [String[]]$TI,

        [Alias("Author")]
        [String[]]$AU,

        [Alias("Edition")]
        [String[]]$ED,

        [Alias("Copies")]
        [String[]]$CP,

        [Alias("Available")]
        [String[]]$AV,

        [Alias("First Number")]
        [String[]]$FC,
        [String[]]$LC,
        [String[]]$PR,
        [String[]]$DP,

        
        [String[]]$PB,

        
        [String[]]$CR,

        
        [String[]]$AD,

        
        [String[]]$VN,

        
        [String[]]$CT,

        
        [String[]]$RC,

        
        [String[]]$LB,

        
        [String[]]$IS,

        
        [String[]]$D1,

        
        [String[]]$D2,

        
        [String[]]$D3,

        
        [String[]]$D4,

        
        [String[]]$C1,

        
        [String[]]$C2,

        
        [String[]]$C3,

        
        [String[]]$U1,

        
        [String[]]$U2,

        
        [String[]]$U3,

        
        [String[]]$U4,

        
        [String[]]$U5,

        
        [String[]]$U6,

        
        [String[]]$U7,

        
        [String[]]$U8,

        
        [String[]]$TY
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-AeriesSQLDB
    }
    Process{
        $RID = $null

        #
        # Build this into it's own private function??
        #
        #$SQLCommand.CommandText = "SELECT MAX(RID) FROM $sqldb.dbo.DRT"
        #$Reader = $SQLCommand.ExecuteReader()
        #while ($Reader.Read())
        #    {
        #        $RID = $Reader.GetValue(0) + 1;
        #    }
        #$Script:SQLConnection.Close()
        #
        #Connect-AeriesSQLDB

        # AU, ED, CP, AV, FC, LC, PR, DP, PB, CR, AD, VN, CT, RC, LB, IS, D1, D2, D3, D4, C1, C2, C3, U1, U2, U3, U4, U5, U6, U7, U8, TY)
        #'$AU', '$ED', '$CP', '$AV', '$FC', '$LC', '$PR', '$DP', '$PB', '$CR', '$AD', '$VN', '$CT', '$RC', '$LB', '$IS', '$D1', '$D2', '$D3', '$D4', '$C1', '$C2', '$C3', '$U1', '$U2', '$U3', '$U4', '$U5', '$U6', '$U7', '$U8', '$TY')

        $SQLCommand.CommandText = "INSERT INTO DST20000TEST.dbo.DRT (RID,TI) VALUES (@rid,@title)";
        $SQLCommand.Parameters.Add("@rid", 74) | Out-Null
        $SQLCommand.Parameters.Add("@title", 'Yet Another Test') | Out-Null
        $SQLCommand.ExecuteNonQuery();
    }
    End{
        $Script:SQLConnection.Close()
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}