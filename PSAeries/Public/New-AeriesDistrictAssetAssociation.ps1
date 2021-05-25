# May want to reconsider how New-AeriesDistrictAssetAssociation and Update-AeriesDistrictAssetAssociation operate.
# One option would be to get rid of New- and run everything out of update and have -checkin and -checkout parameters
# Another option would be to make aliases the run those functions ex. CheckIn-AeriesDistrictAsset & CheckOut-AeriesDistrictAsset

Function New-AeriesDistrictAssetAssociation {
<#
.SYNOPSIS
    Create new District Asset Association in Aeries
.DESCRIPTION
    The New-AeriesDistrictAssetAssociation function uses SQL to create a new District Asset Association in the Aeries DB.
.EXAMPLE
    New-AeriesDistrictAssetAssociation
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

        [Parameter(Mandatory=$true)]
        [Alias("ID")]
        [int]$UserID,

        [Parameter(Mandatory=$true)]
        [ValidatePattern('[S,T]')]
        [ValidateLength(0,1)]
        [Alias("ST")]
        [string]$UserType,

        [Alias("CO")]
        [String]$Comment,

        [Parameter(Mandatory=$true)]
        [Alias("SCL")]
        [int]$School,

        [Alias("DT")]
        [datetime]$DateIssued,
        
        [Alias("RD")]
        [datetime]$DateReturned
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-AeriesSQLDB
    }
    Process{
        $Data = [pscustomobject]@{
            RID=$AssetTitleNumber
            RIN=$AssetItemNumber;
            SQ=((Get-AeriesDistrictAssetAssociation -AssetTitleNumber $AssetTitleNumber -AssetItemNumber $AssetItemNumber).'SQ' | Select-Object -Last 1) + 1;
            ID=$UserID
            ST=$UserType
            PD=0  # Not used
            RM='' # Not used
            CN='' # Not used
            SE=0  # Not used
            CC='' # Not currently used. Populated blank. (According to Aeries Documentation)
            CD='' # Not currently used. Populated blank. (According to Aeries Documentation)
            CO='' # Comment
            SCL=$School
            DT=Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'
            RD=$null
            DD=$null # Not currently used. Populated blank. (According to Aeries Documentation)
            TG='' # Not used
            DEL=0
            DTS=Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'
        }
        
        if ($Comment) {$Data.CO = $Comment}
        if ($DateIssued) {$Data.DT = $DateIssued}
        if ($DateReturned) {$Data.RD = $DateReturned}

        Write-Verbose $Data
        Write-SqlTableData @SQLSplat -TableName 'DRA' -InputData $Data 
    }
    End{
        $Script:SQLConnection.Close()
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}