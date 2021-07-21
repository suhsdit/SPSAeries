Function Update-AeriesDistrictAssetItem {
<#
.SYNOPSIS
    Update a District Asset Item in Aeries
.DESCRIPTION
    The Update-AeriesDistrictAssetItem function uses SQL to update an existing District Asset Item in the Aeries DB.
.EXAMPLE
    Update-AeriesDistrictAssetItem
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
        [String]$MACAddress,
################### VALUES TO UPDATE ###################
        [ValidateLength(0,50)]
        [Alias("NewBC")]
        [String]$NewBarcode,

        [ValidateLength(0,6)]
        [Alias("NewRM")]
        [String]$NewRoom,

        [ValidateLength(0,1)]
        [Alias("NewCC")]
        [String]$NewCondition,
        
        [ValidateLength(0,1)]
        [Alias("NewCD")]
        [String]$NewCode,
        
        [Alias("NewCO")]
        [String]$NewComment,
        
        [Alias("NewSCL")]
        [int]$NewSchool,

        [ValidatePattern('[0-9]*\.[0-9]{2}')] # Check for money format
        [Alias("NewPR")]
        [String]$NewPrice,
        
        [ValidateLength(0,3)]
        [Alias("NewWH")]
        [String]$NewWarehouse,
        
        [ValidateLength(0,255)]
        [Alias("NewSR")]
        [String]$NewSerialNumber,
        
        [ValidateLength(0,12)]
        [Alias("NewMAC")]
        [String]$NewMACAddress
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-AeriesSQLDB
    }
    Process{
        $item = Get-AeriesDistrictAssetItem -AssetTitleNumber $AssetTitleNumber -AssetItemNumber $AssetItemNumber

        $Data = [pscustomobject]@{
            RID=    $item.AssetTitleNumber
            RIN=    $item.AssetItemNumber
            BC=     $item.Barcode
            RM=     $item.Room
            CC=     $item.Condition
            ST=     $item.Status
            CD=     $item.Code
            CO=     $item.Comment
            SCL=    $item.School
            PR=     $item.Price
            WH=     $item.Warehouse
            SR=     $item.SerialNumber
            MAC=    $item.MACAddress
            DEL=0
            DTS=Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'
        }

        if ($NewBarcode) { $Data.BC = $NewBarcode}
        if ($NewRoom) {$Data.RM = $NewRoom}
        if ($NewCondition) {$Data.CC = $NewCondition}
        if ($NewStatus) {$Data.ST = $NewStatus}
        if ($NewCode) {$Data.CD = $NewCode}
        if ($NewComment) {$Data.CO = $NewComment}
        if ($NewSchool) {$Data.SCL = $NewSchool}
        if ($NewPrice) {$Data.PR = $NewPrice}
        if ($NewWarehouse) {$Data.WH = $NewWarehouse}
        if ($NewSerialNumber) {$Data.SR = $NewSerialNumber}
        if ($NewMACAddress) {$Data.MAC = $NewMACAddress}

        Write-SqlTableData @SQLSplat -TableName 'DRI' -InputData $Data 
    }
    End{
        $Script:SQLConnection.Close()
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}