Function Add-SPSAeriesAttendanceData {
    <#
    .SYNOPSIS
        Add a new attendance record to the Aeries ATT table.
    .DESCRIPTION
        The Add-SPSAeriesAttendanceData function creates a new attendance record in the Aeries ATT table.
        This function will fail if a record already exists for the same school, student, and day.
        Use Set-SPSAeriesAttendanceData to update existing records.
    .EXAMPLE
        Add-SPSAeriesAttendanceData -SchoolCode 13 -StudentNumber 123456 -SchoolDay 45
        Creates a basic attendance record for student 123456 at school 13 on day 45.
    .EXAMPLE
        Add-SPSAeriesAttendanceData -SchoolCode 13 -StudentNumber 123456 -SchoolDay 45 -Period1 'A' -Period2 'T' -TeacherNumber 98765
        Creates an attendance record with period-specific attendance codes.
    .EXAMPLE
        Add-SPSAeriesAttendanceData -SchoolCode 13 -StudentNumber 123456 -SchoolDay 45 -AllDay 'A' -Reason 'ILL'
        Creates an all-day absence record with a reason code.
    .PARAMETER SchoolCode
        The school code (SC). Required.
    .PARAMETER StudentNumber
        The student number (SN). Required.
    .PARAMETER SchoolDay
        The school day number (DY). Required.
    .PARAMETER EntryLeave
        The entry/leave code (CD). Optional.
    .PARAMETER Program
        The program code (PR). Optional.
    .PARAMETER Grade
        The grade level (GR). Defaults to 0 if not specified.
    .PARAMETER Track
        The track code (TR). Optional.
    .PARAMETER TeacherNumber
        The teacher number (TN). Optional.
    .PARAMETER AllDay
        The all-day attendance code (AL). Optional.
    .PARAMETER Period0
        Period 0 attendance code (A0). Optional.
    .PARAMETER Period1
        Period 1 attendance code (A1). Optional.
    .PARAMETER Period2
        Period 2 attendance code (A2). Optional.
    .PARAMETER Period3
        Period 3 attendance code (A3). Optional.
    .PARAMETER Period4
        Period 4 attendance code (A4). Optional.
    .PARAMETER Period5
        Period 5 attendance code (A5). Optional.
    .PARAMETER Period6
        Period 6 attendance code (A6). Optional.
    .PARAMETER Period7
        Period 7 attendance code (A7). Optional.
    .PARAMETER Period8
        Period 8 attendance code (A8). Optional.
    .PARAMETER Period9
        Period 9 attendance code (A9). Optional.
    .PARAMETER Date
        The attendance date (DT). If not specified, uses current date.
    .PARAMETER Reason
        The reason code (RS). Optional.
    .PARAMETER NoSchool
        No school indicator (NS). Defaults to 0.
    .PARAMETER AttProgram1
        Attendance program 1 (AP1). Optional.
    .PARAMETER AttProgram2
        Attendance program 2 (AP2). Optional.
    .PARAMETER ReportingSchool
        Reporting school code (HS). Defaults to 0.
    .PARAMETER Interdistrict
        Interdistrict code (IT). Defaults to 0.
    .PARAMETER NPSSpecialEducation
        NPS Special Education code (NPS). Defaults to 0.
    .PARAMETER DistrictOfResidence
        District of residence code (ITD). Defaults to 0.
    .PARAMETER ADACode
        ADA code (ADA). Optional.
    .PARAMETER ADADate
        ADA date (ADT). Optional.
    .PARAMETER ADAComment
        ADA comment (ACO). Optional.
    .PARAMETER FederalCode
        Federal code (FA). Defaults to 0.
    .INPUTS
        System.Int16
        System.Int64
        System.DateTime
        System.String
    .OUTPUTS
        System.Boolean - Returns $true if the record was created successfully.
    .NOTES
        This function requires an active SPSAeries configuration to connect to the database.
        Use Set-SPSAeriesConfiguration to configure the database connection before using this function.
        
        This function will fail if a record already exists for the same SchoolCode, StudentNumber, and SchoolDay.
        Use Set-SPSAeriesAttendanceData to update existing records.
    .LINK
        Set-SPSAeriesAttendanceData
        Invoke-SPSAeriesSqlQuery
        Set-SPSAeriesConfiguration
    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The school code (required)',
            Position = 0)]
        [ValidateRange(1, 9999)]
        [int16]$SchoolCode,

        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The student number (required)',
            Position = 1)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$StudentNumber,

        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The school day number (required)',
            Position = 2)]
        [ValidateRange(1, 9999)]
        [int16]$SchoolDay,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$EntryLeave = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Program = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0, 99)]
        [int16]$Grade = 0,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Track = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0, [int64]::MaxValue)]
        [int64]$TeacherNumber = 0,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$AllDay = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period0 = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period1 = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period2 = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period3 = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period4 = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period5 = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period6 = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period7 = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period8 = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period9 = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [DateTime]$Date = (Get-Date),

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 3)]
        [string]$Reason = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0, [int64]::MaxValue)]
        [int64]$NoSchool = 0,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 3)]
        [string]$AttProgram1 = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 3)]
        [string]$AttProgram2 = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0, 9999)]
        [int16]$ReportingSchool = 0,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 2)]
        [string]$Interdistrict = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 7)]
        [string]$NPSSpecialEducation = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 14)]
        [string]$DistrictOfResidence = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$ADACode = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [DateTime]$ADADate,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [string]$ADAComment = '',

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0, 9999)]
        [int16]$FederalCode = 0
    )

    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName)..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        
        # Check if SPSAeries configuration is available
        if (-not $Script:Config -or -not $Script:SQLCreds) {
            throw "No active SPSAeries configuration found. Please run Set-SPSAeriesConfiguration first."
        }
    }

    Process {
        try {
            $parameterDescription = "School: $SchoolCode, Student: $StudentNumber, Day: $SchoolDay"
            
            if ($PSCmdlet.ShouldProcess($parameterDescription, "Add attendance record")) {
                # First check if record already exists
                $existingRecordQuery = @"
SELECT COUNT(*) as RecordCount 
FROM ATT 
WHERE SC = $SchoolCode AND SN = $StudentNumber AND DY = $SchoolDay
"@
                
                Write-Verbose "Checking for existing record: $parameterDescription"
                $existingCount = Invoke-SPSAeriesSqlQuery -Query $existingRecordQuery -As PSObject
                
                if ($existingCount.RecordCount -gt 0) {
                    Write-Error "Attendance record already exists for $parameterDescription. Use Set-SPSAeriesAttendanceData to update existing records."
                    return $false
                }
                
                # Build the INSERT query
                $dateString = $Date.ToString('yyyy-MM-dd HH:mm:ss.fff')
                $adaDateValue = if ($PSBoundParameters.ContainsKey('ADADate')) { "'$($ADADate.ToString('yyyy-MM-dd HH:mm:ss.fff'))'" } else { 'NULL' }
                $adaCommentValue = "'$($ADAComment.Replace("'", "''"))'"
                
                $insertQuery = @"
INSERT INTO ATT (
    SC, SN, DY, CD, PR, GR, TR, TN, AL, 
    A0, A1, A2, A3, A4, A5, A6, A7, A8, A9,
    DT, RS, NS, AP1, AP2, HS, IT, NPS, ITD, 
    ADA, ADT, ACO, FA, DEL, DTS
) VALUES (
    $SchoolCode, 
    $StudentNumber, 
    $SchoolDay, 
    '$EntryLeave', 
    '$Program', 
    $Grade, 
    '$Track', 
    $TeacherNumber, 
    '$AllDay',
    '$Period0', 
    '$Period1', 
    '$Period2', 
    '$Period3', 
    '$Period4', 
    '$Period5', 
    '$Period6', 
    '$Period7', 
    '$Period8', 
    '$Period9',
    '$dateString', 
    '$Reason', 
    $NoSchool, 
    '$AttProgram1', 
    '$AttProgram2', 
    $ReportingSchool, 
    '$Interdistrict', 
    '$NPSSpecialEducation', 
    '$DistrictOfResidence',
    '$ADACode', 
    $adaDateValue, 
    $adaCommentValue, 
    $FederalCode, 
    0, 
    GETDATE()
)
"@
                
                Write-Verbose "Executing INSERT query for: $parameterDescription"
                Write-Verbose "Query: $insertQuery"
                
                # Execute the query
                Invoke-SPSAeriesSqlQuery -Query $insertQuery
                
                Write-Verbose "Successfully added attendance record for: $parameterDescription"
                return $true
            }
        }
        catch {
            Write-Error "Failed to add attendance record for $parameterDescription : $($_.Exception.Message)"
            throw
        }
    }

    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
