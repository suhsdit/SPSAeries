Function Get-SPSAeriesAttendanceData {
    <#
    .SYNOPSIS
        Get attendance data from the Aeries ATT table.
    .DESCRIPTION
        The Get-SPSAeriesAttendanceData function retrieves attendance data from the Aeries ATT table.
        It can return data for a specific school, student, date, or combination of these parameters.
        This function leverages Invoke-SPSAeriesSqlQuery for database access and returns ATT table 
        data with descriptive PowerShell-friendly property names.
        
    .EXAMPLE
        Get-SPSAeriesAttendanceData -SchoolCode 13 -Date '2025-09-09'
        Returns attendance data for school 13 on September 9, 2025.
    .EXAMPLE
        Get-SPSAeriesAttendanceData -StudentNumber 123456 -IncludeAllColumns
        Returns all attendance data with all available columns for student 123456.
    .EXAMPLE
        Get-SPSAeriesAttendanceData -SchoolCode 13 -StudentNumber 123456
        Returns attendance data for student 123456 at school 13.
    .EXAMPLE
        Get-SPSAeriesAttendanceData -SchoolCode 13 -TeacherNumber 98765
        Returns attendance data for all students of teacher 98765 at school 13.
    .PARAMETER SchoolCode
        The school code (SC) to query for. If not specified, returns data for all schools.
    .PARAMETER StudentNumber
        The student number (SN) to query for. If not specified, returns data for all students.
    .PARAMETER Date
        The specific date to query for. If not specified, returns data for all dates.
    .PARAMETER SchoolDay
        The school day number (DY) to query for. Alternative to Date parameter.
    .PARAMETER TeacherNumber
        The teacher number (TN) to query for. If not specified, returns data for all teachers.
    .PARAMETER Grade
        The grade level (GR) to query for. If not specified, returns data for all grades.
    .PARAMETER Track
        The track (TR) to query for. If not specified, returns data for all tracks.
    .PARAMETER IncludeAllColumns
        When specified, returns all available columns from the ATT table including all period fields,
        timestamps, and additional metadata. By default, returns only the most commonly used columns.
    .INPUTS
        System.Int16
        System.Int64
        System.DateTime
        System.String
    .OUTPUTS
        PSCustomObject with ATT table columns using descriptive property names.
        Basic output includes: SchoolCode, StudentNumber, SchoolDay, EntryLeave, Program, Grade, Track, TeacherNumber, AllDay, Date
        Full output includes all 40+ columns from the ATT table including all period attendance fields.
    .NOTES
        This function requires an active SPSAeries configuration to connect to the database.
        Use Set-SPSAeriesConfiguration to configure the database connection before using this function.
        
        By default, returns commonly used columns for better readability and performance.
        Use -IncludeAllColumns for complete data including all period fields and metadata.
        
        The ATT table contains student attendance records with detailed period-by-period data.
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
            HelpMessage = 'The student number to query for (optional - if not specified, returns all students)',
            Position = 1)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$StudentNumber,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The specific date to query for (optional - if not specified, returns all dates)',
            Position = 2)]
        [DateTime]$Date,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The school day number to query for (alternative to Date parameter)')]
        [ValidateRange(1, 9999)]
        [int16]$SchoolDay,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The teacher number to query for (optional - if not specified, returns all teachers)')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$TeacherNumber,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The grade level to query for (optional - if not specified, returns all grades)')]
        [ValidateLength(1, 2)]
        [string]$Grade,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The track to query for (optional - if not specified, returns all tracks)')]
        [ValidateLength(1, 1)]
        [string]$Track,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Include all columns from the ATT table (periods, timestamps, etc.)')]
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
            
            if ($StudentNumber) {
                $whereClause += "SN = $StudentNumber"
                $queryParams += "Student Number: $StudentNumber"
            }
            
            if ($Date) {
                $dateString = $Date.ToString('yyyy-MM-dd')
                $whereClause += "CAST(DT AS DATE) = '$dateString'"
                $queryParams += "Date: $dateString"
            }
            
            if ($SchoolDay) {
                $whereClause += "DY = $SchoolDay"
                $queryParams += "School Day: $SchoolDay"
            }
            
            if ($TeacherNumber) {
                $whereClause += "TN = $TeacherNumber"
                $queryParams += "Teacher Number: $TeacherNumber"
            }
            
            if ($Grade) {
                $whereClause += "GR = '$Grade'"
                $queryParams += "Grade: $Grade"
            }
            
            if ($Track) {
                $whereClause += "TR = '$Track'"
                $queryParams += "Track: $Track"
            }
            
            # Build the complete query with conditional column selection
            if ($IncludeAllColumns) {
                # Full query with all columns and descriptive aliases
                $query = @"
SELECT 
    SC AS SchoolCode,
    SN AS StudentNumber,
    DY AS SchoolDay,
    CD AS EntryLeave,
    PR AS Program,
    GR AS Grade,
    TR AS Track,
    TN AS TeacherNumber,
    AL AS AllDay,
    A0 AS Period0,
    A1 AS Period1,
    A2 AS Period2,
    A3 AS Period3,
    A4 AS Period4,
    A5 AS Period5,
    A6 AS Period6,
    A7 AS Period7,
    A8 AS Period8,
    A9 AS Period9,
    DT AS Date,
    RS AS Reason,
    NS AS NoSchool,
    AP1 AS AttProgram1,
    AP2 AS AttProgram2,
    HS AS ReportingSchool,
    IT AS Interdistrict,
    NPS AS NPSSpecialEducation,
    ITD AS DistrictOfResidence,
    ADA AS ADACode,
    ADT AS ADADate,
    ACO AS ADAComment,
    DTS AS DateTimestamp
FROM ATT
"@
            } else {
                # Basic query with commonly used columns
                $query = @"
SELECT 
    SC AS SchoolCode,
    SN AS StudentNumber,
    DY AS SchoolDay,
    CD AS EntryLeave,
    PR AS Program,
    GR AS Grade,
    TR AS Track,
    TN AS TeacherNumber,
    AL AS AllDay,
    A0 AS Period0,
    A1 AS Period1,
    A2 AS Period2,
    A3 AS Period3,
    A4 AS Period4,
    A5 AS Period5,
    A6 AS Period6,
    A7 AS Period7,
    A8 AS Period8,
    A9 AS Period9,
    DT AS Date,
    RS AS Reason
FROM ATT
"@
            }
            
            # Add WHERE clause if we have conditions
            if ($whereClause.Count -gt 0) {
                $query += "`nWHERE " + ($whereClause -join " AND ")
            }
            
            # Add ORDER BY for consistent results
            $query += "`nORDER BY SC, SN, DY"
            
            if ($queryParams.Count -gt 0) {
                $columnInfo = if ($IncludeAllColumns) { " (all columns)" } else { " (basic columns)" }
                Write-Verbose "Executing query with parameters: $($queryParams -join ', ')$columnInfo"
            } else {
                $columnInfo = if ($IncludeAllColumns) { " (all columns)" } else { " (basic columns)" }
                Write-Verbose "Executing query for all attendance data$columnInfo"
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
                    
                    # Convert the DateTimestamp field to proper DateTime if it's not null
                    if ($_.DateTimestamp) {
                        $_.DateTimestamp = [DateTime]$_.DateTimestamp
                    }
                    
                    $_
                }
            } else {
                $parameterDescription = if ($queryParams.Count -gt 0) { 
                    " for $($queryParams -join ', ')" 
                } else { 
                    "" 
                }
                Write-Warning "No attendance data found$parameterDescription"
                return $null
            }
        }
        catch {
            $parameterDescription = if ($queryParams.Count -gt 0) { 
                " for $($queryParams -join ', ')" 
            } else { 
                "" 
            }
            Write-Error "Failed to retrieve attendance data$parameterDescription : $($_.Exception.Message)"
            throw
        }
    }

    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
