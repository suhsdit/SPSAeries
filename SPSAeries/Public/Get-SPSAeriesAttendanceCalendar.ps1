Function Get-SPSAeriesAttendanceCalendar {
    <#
    .SYNOPSIS
        Get attendance calendar information from the Aeries DAY table.
    .DESCRIPTION
        The Get-SPSAeriesAttendanceCalendar function retrieves attendance calendar information from the Aeries DAY table.
        It can return data for a specific school and date, all dates for a school year, or all calendar data.
        This function leverages Invoke-SPSAeriesSqlQuery for database access and returns DAY table 
        data with descriptive PowerShell-friendly property names.
    .EXAMPLE
        Get-SPSAeriesAttendanceCalendar -SchoolCode 13 -Date '2025-09-09'
        Returns basic attendance calendar information for school 13 on September 9, 2025.
    .EXAMPLE
        Get-SPSAeriesAttendanceCalendar -SchoolCode 13 -IncludeAllColumns
        Returns all attendance calendar data with all available columns for school 13.
    .EXAMPLE
        Get-SPSAeriesAttendanceCalendar -SchoolCode 13
        Returns basic attendance calendar information for all days in school 13.
    .EXAMPLE
        Get-SPSAeriesAttendanceCalendar
        Returns basic attendance calendar data for all schools.
    .PARAMETER SchoolCode
        The school code (SC) to query for. If not specified, returns data for all schools.
    .PARAMETER Date
        The specific date to query for. If not specified when SchoolCode is provided, 
        returns all dates for that school. If neither parameter is specified, returns all data.
    .PARAMETER IncludeAllColumns
        When specified, returns all available columns from the DAY table including all track fields,
        timestamps, and additional metadata. By default, returns only the most commonly used columns.
    .INPUTS
        System.Int16
        System.DateTime
    .OUTPUTS
        PSCustomObject with DAY table columns using descriptive property names.
        Basic output includes: SchoolCode, SchoolDay, Date, Holiday, Month, Apportionment, Enrollment, BellSchedule
        Full output includes all 35+ columns from the DAY table.
    .NOTES
        This function requires an active SPSAeries configuration to connect to the database.
        Use Set-SPSAeriesConfiguration to configure the database connection before using this function.
        
        By default, returns commonly used columns for better readability and performance.
        Use -IncludeAllColumns for complete data including all track fields and metadata.
    .LINK
        Invoke-SPSAeriesSqlQuery
        Set-SPSAeriesConfiguration
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The school code to query for (optional - if not specified, returns all schools)',
            Position = 0)]
        [ValidateRange(1, 9999)]
        [int16]$SchoolCode,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The specific date to query for (optional - if not specified, returns all dates)',
            Position = 1)]
        [DateTime]$Date,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Include all columns from the DAY table (tracks, timestamps, etc.)')]
        [switch]$IncludeAllColumns
    )

    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        
        # Check if SPSAeries configuration is available
        if (-not $Script:Config -or -not $Script:SQLCreds) {
            throw "No active SPSAeries configuration found. Please run Set-SPSAeriesConfiguration first."
        }
    }

    Process {
        try {
            # Build the SQL query dynamically based on provided parameters
            $whereClause = @()
            $queryParams = @()
            
            if ($SchoolCode) {
                $whereClause += "SC = $SchoolCode"
                $queryParams += "School Code: $SchoolCode"
            }
            
            if ($Date) {
                $dateString = $Date.ToString('yyyy-MM-dd')
                $whereClause += "CAST(DT AS DATE) = '$dateString'"
                $queryParams += "Date: $dateString"
            }
            
            # Build the complete query with conditional column selection
            if ($IncludeAllColumns) {
                # Full query with all columns and descriptive aliases
                $query = @"
SELECT 
    SC AS SchoolCode,
    DY AS SchoolDay,
    DT AS Date,
    HO AS Holiday,
    MO AS Month,
    T1 AS Track1,
    T2 AS Track2,
    T3 AS Track3,
    T4 AS Track4,
    T5 AS Track5,
    T6 AS Track6,
    AP AS Apportionment,
    EN AS Enrollment,
    BL AS BellLocation,
    AB AS ABDays,
    ML AS MakeLock,
    T7 AS Track7,
    T8 AS Track8,
    T9 AS Track9,
    T10 AS Track10,
    T11 AS Track11,
    T12 AS Track12,
    T13 AS Track13,
    T14 AS Track14,
    T15 AS Track15,
    T16 AS Track16,
    T17 AS Track17,
    T18 AS Track18,
    T19 AS Track19,
    T20 AS Track20,
    T21 AS Track21,
    T22 AS Track22,
    T23 AS Track23,
    T24 AS Track24,
    T25 AS Track25,
    T26 AS Track26,
    PD AS AttendancePeriod,
    BS AS BellSchedule,
    PAT AS PrimaryADATime,
    SAT AS SecondaryADATime,
    DTS AS DateTimestamp
FROM DAY
"@
            } else {
                # Basic query with commonly used columns
                $query = @"
SELECT 
    SC AS SchoolCode,
    DY AS SchoolDay,
    DT AS Date,
    HO AS Holiday,
    MO AS Month,
    AP AS Apportionment,
    EN AS Enrollment,
    BS AS BellSchedule
FROM DAY
"@
            }
            
            # Add WHERE clause if we have conditions
            if ($whereClause.Count -gt 0) {
                $query += "`nWHERE " + ($whereClause -join " AND ")
            }
            
            # Add ORDER BY for consistent results
            $query += "`nORDER BY SC, DY"
            
            if ($queryParams.Count -gt 0) {
                $columnInfo = if ($IncludeAllColumns) { " (all columns)" } else { " (basic columns)" }
                Write-Verbose "Executing query with parameters: $($queryParams -join ', ')$columnInfo"
            } else {
                $columnInfo = if ($IncludeAllColumns) { " (all columns)" } else { " (basic columns)" }
                Write-Verbose "Executing query for all attendance calendar data$columnInfo"
            }
            Write-Verbose "Query: $query"

            # Execute the query using Invoke-SPSAeriesSqlQuery
            $results = Invoke-SPSAeriesSqlQuery -Query $query -As PSObject
            
            if ($results) {
                # Return the results - they already have the descriptive property names from the SQL aliases
                $results | ForEach-Object {
                    # Convert the Date field to proper DateTime if it's not null
                    if ($_.Date) {
                        $_.Date = [DateTime]$_.Date
                    }
                    $_
                }
            } else {
                $parameterDescription = if ($queryParams.Count -gt 0) { 
                    " for $($queryParams -join ', ')" 
                } else { 
                    "" 
                }
                Write-Warning "No attendance calendar data found$parameterDescription"
                return $null
            }
        }
        catch {
            $parameterDescription = if ($queryParams.Count -gt 0) { 
                " for $($queryParams -join ', ')" 
            } else { 
                "" 
            }
            Write-Error "Failed to retrieve attendance calendar data$parameterDescription : $($_.Exception.Message)"
            throw
        }
    }

    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
