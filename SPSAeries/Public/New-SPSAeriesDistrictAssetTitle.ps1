Function New-SPSAeriesDistrictAssetTitle {
<#
.SYNOPSIS
    Create new District Asset Title in Aeries
.DESCRIPTION
    The New-SPSAeriesDistrictAssetTitle function uses SQL to create a new District Asset Title in the Aeries DB.
.EXAMPLE
    New-SPSAeriesDistrictAssetTitle -Title "A Great book" -Author "The Man" -Edition "3rd" -Price 3.99 -Department 10 -Publisher "Old dude's publishing house" -CopyrightYear 2021 -Vendor 32 -Catalog 1234 -ReplacementCost 3.50 -LibraryOfCongressNumber 12345 -ISBN 1234-5432 -U1 34 -U2 abc -U3 123 -U4 456 
-U5 234 -U6 345 -U7 678 -U8 789 -Type TXT -Verbose
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
        [ValidateLength(0,60)]
        [Alias("TI")]
        [String]$Title,

        [ValidateLength(0,50)]
        [Alias("AU")]
        [String]$Author,

        [ValidateLength(0,4)]
        [Alias("ED")]
        [String]$Edition,

        [ValidatePattern('[0-9]*\.[0-9]{2}')] # Check for money format
        [Alias("PR")]
        [String]$Price,

        [ValidateLength(0,2)]
        [Alias("DP")]
        [String]$Department,

        [ValidateLength(0,50)]
        [Alias("PB")]
        [String]$Publisher,

        [ValidateLength(0,4)]
        [Alias("CR")]
        [String]$CopyrightYear,

        [ValidatePattern('[0-9]')]
        [Alias("VN")]
        [int]$Vendor,

        [ValidateLength(0,10)]
        [Alias("CT")]
        [String]$Catalog,

        [ValidatePattern('[0-9]*\.[0-9]{2}')] # Check for money format
        [Alias("RC")]
        [String]$ReplacementCost,

        [ValidateLength(0,16)]
        [Alias("LB")]
        [String]$LibraryOfCongressNumber,

        [ValidateLength(0,13)]
        [Alias("IS")]
        [String]$ISBN,

        [ValidateLength(0,3)]
        [String]$U1,

        [ValidateLength(0,3)]
        [String]$U2,

        [ValidateLength(0,3)]
        [String]$U3,

        [ValidateLength(0,3)]
        [String]$U4,

        [ValidateLength(0,3)]
        [String]$U5,

        [ValidateLength(0,3)]
        [String]$U6,

        [ValidateLength(0,3)]
        [String]$U7,

        [ValidateLength(0,3)]
        [String]$U8,

        [ValidateLength(0,3)]
        [Alias("TY")]
        [String]$Type
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-AeriesSQLDB
    }
    Process{
        $Data = [pscustomobject]@{
            RID=((Get-SPSAeriesDistrictAssetTitle).'AssetTitleNumber' | Select-Object -Last 1) + 1;
            TI=''
            AU=''
            ED=''
            CP=0
            AV=0
            FC=0
            LC=0
            PR=0.00
            DP=''
            PB=''
            CR=''
            AD=$null
            VN=0
            CT=''
            RC=0.00
            LB=''
            IS=''
            D1=0.00
            D2=0.00
            D3=0.00
            D4=0.00
            C1=''
            C2=''
            C3=''
            U1=''
            U2=''
            U3=''
            U4=''
            U5=''
            U6=''
            U7=''
            U8=''
            TY=''
            DEL=0
            DTS=Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'
        }

        if ($Title) { $Data.TI = $Title}
        if ($Author) { $Data.AU = $Author}
        if ($Edition) {$Data.ED = $Edition}
        if ($Price) {$Data.PR = $Price}
        if ($Department) {$Data.DP = $Department}
        if ($Publisher) {$Data.PB = $Publisher}
        if ($CopyrightYear) {$Data.CR = $CopyrightYear}
        if ($Vendor) {$Data.VN = $Vendor}
        if ($Catalog) {$Data.CT = $Catalog}
        if ($ReplacementCost) {$Data.RC = $ReplacementCost}
        if ($LibraryOfCongressNumber) {$Data.LB = $LibraryOfCongressNumber}
        if ($ISBN) {$Data.IS = $ISBN}
        if ($U1) {$Data.U1 = $U1}
        if ($U2) {$Data.U2 = $U2}
        if ($U3) {$Data.U3 = $U3}
        if ($U4) {$Data.U4 = $U4}
        if ($U5) {$Data.U5 = $U5}
        if ($U6) {$Data.U6 = $U6}
        if ($U7) {$Data.U7 = $U7}
        if ($U8) {$Data.U8 = $U8}
        if ($Type) {$Data.TY = $Type}

        Write-SqlTableData @SQLSplat -TableName 'DRT' -InputData $Data 
    }
    End{
        $Script:SQLConnection.Close()
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}