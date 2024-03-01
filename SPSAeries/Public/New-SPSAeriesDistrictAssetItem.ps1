Function New-SPSAeriesDistrictAssetItem {
<#
.SYNOPSIS
    Create new District Asset Item in Aeries
.DESCRIPTION
    The New-SPSAeriesDistrictAssetItem function uses SQL to create a new District Asset Item in the Aeries DB.
.EXAMPLE
    New-SPSAeriesDistrictAssetItem
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

        [ValidateLength(0,50)]
        [Alias("BC")]
        [String]$Barcode,

        [ValidateLength(0,6)]
        [Alias("RM")]
        [String]$Room,

        [ValidateLength(0,1)]
        [Alias("CC")]
        [String]$Condition,
        
        [ValidateLength(0,1)]
        [Alias("CD")]
        [String]$Code,
        
        [Alias("CO")]
        [String]$Comment,
        
        [Alias("SCL")]
        [int]$School,

        [ValidatePattern('[0-9]*\.[0-9]{2}')] # Check for money format
        [Alias("PR")]
        [String]$Price,
        
        [ValidateLength(0,3)]
        [Alias("WH")]
        [String]$Warehouse,
        
        [ValidateLength(0,255)]
        [Alias("SR")]
        [String]$SerialNumber,
        
        [ValidateLength(0,12)]
        [Alias("MAC")]
        [String]$MACAddress
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-AeriesSQLDB
    }
    Process{
        $Data = [pscustomobject]@{
            RID=$AssetTitleNumber
            RIN=((Get-SPSAeriesDistrictAssetItem -AssetTitleNumber $AssetTitleNumber).'AssetItemNumber' | Select-Object -Last 1) + 1;
            BC=''
            RM=''
            CC=''
            ST=''
            CD=''
            CO=''
            SCL=0
            PR=(Get-SPSAeriesDistrictAssetTitle -AssetTitleNumber $AssetTitleNumber).'Price'
            WH=''
            SR=''
            MAC=''
            DEL=0
            DTS=Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'
        }

        if ($Barcode) { $Data.BC = $Barcode}
        if ($Room) {$Data.RM = $Room}
        if ($Condition) {$Data.CC = $Condition}
        if ($Code) {$Data.CD = $Code}
        if ($Comment) {$Data.CO = $Comment}
        if ($School) {$Data.SCL = $School}
        if ($Price) {$Data.PR = $Price}
        if ($Warehouse) {$Data.WH = $Warehouse}
        if ($SerialNumber) {$Data.SR = $SerialNumber}
        if ($MACAddress) {$Data.MAC = $MACAddress}

        Write-SqlTableData @SQLSplat -TableName 'DRI' -InputData $Data 
    }
    End{
        $Script:SQLConnection.Close()
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}