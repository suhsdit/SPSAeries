Function Get-AeriesDistrictAssetTitle{
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
        [String[]]$Type
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
            $SQLData = Invoke-Sqlcmd @InvokeSQLSplat -Query "SELECT * FROM $SQLDB.dbo.DRT WHERE RID = $AssetTitleNumber"
        } elseif ($Type) {
            $SQLData = Invoke-Sqlcmd @InvokeSQLSplat -Query "SELECT * FROM $SQLDB.dbo.DRT WHERE TY = '$Type'"
        } else {
            $SQLData = Read-SqlTableData @SQLSplat -TableName "DRT"
        }

        $SQLData | ForEach-Object {
            $AssetTitle = [PSCustomObject]@{
                'AssetTitleNumber' = $_.RID;
                'Title' = $_.TI;
                'Author' = $_.AU;
                'Edition' = $_.ED;
                'Copies' = $_.CP;
                'Available' = $_.AV;
                'FirstNumber' = $_.FC;
                'LastNumber' = $_.LC;
                'Price' = $_.PR;
                'Department' = $_.DP;
                'Publiser' = $_.PB;
                'CopyrightYear' = $_.CR;
                'ApprovalDate' = $_.AD;
                'Vendor' = $_.VN;
                'Catalog' = $_.CT;
                'ReplacementCost' = $_.RC;
                'LibraryOfCongressNumber' = $_.LB;
                'ISBN' = $_.IS;
                # Aeries API says these fields are Not used
                # Grab them anyways
                'D1' = $_.D1;
                'D2' = $_.D2;
                'D3' = $_.D3;
                'D4' = $_.D4;
                'C1' = $_.C1;
                'C2' = $_.C2;
                'C3' = $_.C3;
                # End of unused fields
                'UserCode1' = $_.U1;
                'UserCode2' = $_.U2;
                'UserCode3' = $_.U3;
                'UserCode4' = $_.U4;
                'UserCode5' = $_.U5;
                'UserCode6' = $_.U6;
                'UserCode7' = $_.U7;
                'UserCode8' = $_.U8;
                'Type' = $_.TY;
            }
            $result += $AssetTitle
        }
        $result
    }
    End{
        $Script:SQLConnection.Close()
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}