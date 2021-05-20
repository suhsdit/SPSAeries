Function Update-AeriesDistrictAssetTitle {
    <#
    .SYNOPSIS
        Update an existing District Asset Title in Aeries
    .DESCRIPTION
        The Update-AeriesDistrictAssetTitle function uses SQL to update an existing District Asset Title in the Aeries DB.
    .EXAMPLE
        Update-AeriesDistrictAssetTitle -AssetTitleNumber 70 -Title "A Great book" -Author "The Man" -Edition "3rd" -Price 3.99 -Department 10 -Publisher "Old dude's publishing house" -CopyrightYear 2021 -Vendor 32 -Catalog 1234 -ReplacementCost 3.50 -LibraryOfCongressNumber 12345 -ISBN 1234-5432 -U1 34 -U2 abc -U3 123 -U4 456 
    -U5 234 -U6 345 -U7 678 -U8 789 -Type TXT -Verbose
    .PARAMETER
    .INPUTS
    .OUTPUTS
    .NOTES
    .LINK
    #>
        [CmdletBinding()] #Enable all the default paramters, including -Verbose
        Param(
            [Parameter(Mandatory=$true,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true,
                # HelpMessage='HelpMessage',
                Position=0)]
            [Alias ("RID")]
            [int]$AssetTitleNumber, 

            [Alias("TI")]
            [ValidateLength(0,60)]
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
            $query = "UPDATE $SQLDB.dbo.DRT SET "
            if (Get-AeriesDistrictAssetTitle -AssetTitleNumber $AssetTitleNumber) {
                if ($Title) {$query += "TI = '$Title', "}
                if ($Author) {$query += "AU = '$Author', "}
                if ($Edition) {$query += "ED = '$Edition', "}
                if ($Price) {$query += "PR = $Price', "}
                if ($Department) {$query += "DP = $Department', "}
                if ($Publisher) {$query += "PB = $Publisher', "}
                if ($CopyrightYear) {$query += "CR = $CopyrightYear', "}
                if ($Vendor) {$query += "VN = $Vendor', "}
                if ($Catalog) {$query += "CT = $Catalog', "}
                if ($ReplacementCost) {$query += "RC = $ReplacementCost', "}
                if ($LibraryOfCongressNumber) {$query += "LB = $LibraryOfCongressNumber', "}
                if ($ISBN) {$query += "IS = $ISBN', "}
                if ($UserCode1) {$query += "C1 = $UserCode1', "}
                if ($UserCode2) {$query += "C2 = $UserCode2', "}
                if ($UserCode3) {$query += "C3 = $UserCode3', "}
                if ($UserCode4) {$query += "C4 = $UserCode4', "}
                if ($UserCode5) {$query += "C5 = $UserCode5', "}
                if ($UserCode6) {$query += "C6 = $UserCode6', "}
                if ($UserCode7) {$query += "C7 = $UserCode7', "}
                if ($UserCode8) {$query += "C8 = $UserCode8', "}
                if ($Type) {$query += "TY = $Type', "}
                
                # Delete's the last ', ' on the query
                $query = $query -replace ".{2}$"
            }
            $query += " Where RID = $AssetTitleNumber"
            Write-Verbose $query
            Invoke-Sqlcmd @InvokeSQLSplat -Query $query
        }
        End{
            $Script:SQLConnection.Close()
            Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
        }
    }