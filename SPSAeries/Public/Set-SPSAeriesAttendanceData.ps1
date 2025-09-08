Function Set-SPSAeriesAttendanceData {
    <#
    .SYNOPSIS
        Update an existing attendance record in the Aeries ATT table.
    .DESCRIPTION
        The Set-SPSAeriesAttendanceData function updates an existing attendance record in the Aeries ATT table.
        The record is identified by SchoolCode, StudentNumber, and SchoolDay (the primary key fields).
        This function will fail if no record exists for the specified combination.
        Use Add-SPSAeriesAttendanceData to create new records.
    .EXAMPLE
        Set-SPSAeriesAttendanceData -SchoolCode 13 -StudentNumber 123456 -SchoolDay 45 -Period1 'P'
        Updates period 1 attendance to 'P' for the specified record.
    .EXAMPLE
        Set-SPSAeriesAttendanceData -SchoolCode 13 -StudentNumber 123456 -SchoolDay 45 -AllDay 'A' -Reason 'ILL'
        Updates the record to show an all-day absence with illness reason.
    .EXAMPLE
        Set-SPSAeriesAttendanceData -SchoolCode 13 -StudentNumber 123456 -SchoolDay 45 -Period1 '' -Period2 '' -Period3 'T'
        Clears period 1 and 2 attendance and sets period 3 to tardy.
    .PARAMETER SchoolCode
        The school code (SC). Required to identify the record.
    .PARAMETER StudentNumber
        The student number (SN). Required to identify the record.
    .PARAMETER SchoolDay
        The school day number (DY). Required to identify the record.
    .PARAMETER EntryLeave
        The entry/leave code (CD). Optional.
    .PARAMETER Program
        The program code (PR). Optional.
    .PARAMETER Grade
        The grade level (GR). Optional.
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
        The attendance date (DT). Optional.
    .PARAMETER Reason
        The reason code (RS). Optional.
    .PARAMETER NoSchool
        No school indicator (NS). Optional.
    .PARAMETER AttProgram1
        Attendance program 1 (AP1). Optional.
    .PARAMETER AttProgram2
        Attendance program 2 (AP2). Optional.
    .PARAMETER ReportingSchool
        Reporting school code (HS). Optional.
    .PARAMETER Interdistrict
        Interdistrict code (IT). Optional.
    .PARAMETER NPSSpecialEducation
        NPS Special Education code (NPS). Optional.
    .PARAMETER DistrictOfResidence
        District of residence code (ITD). Optional.
    .PARAMETER ADACode
        ADA code (ADA). Optional.
    .PARAMETER ADADate
        ADA date (ADT). Optional.
    .PARAMETER ADAComment
        ADA comment (ACO). Optional.
    .PARAMETER FederalCode
        Federal code (FA). Optional.
    .INPUTS
        System.Int16
        System.Int64
        System.DateTime
        System.String
    .OUTPUTS
        System.Boolean - Returns $true if the record was updated successfully.
    .NOTES
        This function requires an active SPSAeries configuration to connect to the database.
        Use Set-SPSAeriesConfiguration to configure the database connection before using this function.
        
        This function will fail if no record exists for the specified SchoolCode, StudentNumber, and SchoolDay.
        Use Add-SPSAeriesAttendanceData to create new records.
        
        Only specified parameters will be updated. Unspecified parameters will remain unchanged.
    .LINK
        Add-SPSAeriesAttendanceData
        Invoke-SPSAeriesSqlQuery
        Set-SPSAeriesConfiguration
    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The school code (required to identify record)',
            Position = 0)]
        [ValidateRange(1, 9999)]
        [int16]$SchoolCode,

        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The student number (required to identify record)',
            Position = 1)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$StudentNumber,

        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The school day number (required to identify record)',
            Position = 2)]
        [ValidateRange(1, 9999)]
        [int16]$SchoolDay,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$EntryLeave,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Program,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0, 99)]
        [int16]$Grade,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Track,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0, [int64]::MaxValue)]
        [int64]$TeacherNumber,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$AllDay,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period0,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period1,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period2,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period3,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period4,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period5,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period6,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period7,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period8,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$Period9,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [DateTime]$Date,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 3)]
        [string]$Reason,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0, [int64]::MaxValue)]
        [int64]$NoSchool,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 3)]
        [string]$AttProgram1,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 3)]
        [string]$AttProgram2,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0, 9999)]
        [int16]$ReportingSchool,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 2)]
        [string]$Interdistrict,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 7)]
        [string]$NPSSpecialEducation,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 14)]
        [string]$DistrictOfResidence,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(0, 1)]
        [string]$ADACode,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [DateTime]$ADADate,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [string]$ADAComment,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0, 9999)]
        [int16]$FederalCode
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
            
            if ($PSCmdlet.ShouldProcess($parameterDescription, "Update attendance record")) {
                # First check if record exists
                $existingRecordQuery = @"
SELECT COUNT(*) as RecordCount 
FROM ATT 
WHERE SC = $SchoolCode AND SN = $StudentNumber AND DY = $SchoolDay
"@
                
                Write-Verbose "Checking for existing record: $parameterDescription"
                $existingCount = Invoke-SPSAeriesSqlQuery -Query $existingRecordQuery -As PSObject
                
                if ($existingCount.RecordCount -eq 0) {
                    Write-Error "No attendance record found for $parameterDescription. Use Add-SPSAeriesAttendanceData to create new records."
                    return $false
                }
                
                # Build the UPDATE query dynamically based on provided parameters
                $updateFields = @()
                
                # Handle each possible field update
                if ($PSBoundParameters.ContainsKey('EntryLeave')) {
                    $updateFields += "CD = '$EntryLeave'"
                }
                if ($PSBoundParameters.ContainsKey('Program')) {
                    $updateFields += "PR = '$Program'"
                }
                if ($PSBoundParameters.ContainsKey('Grade')) {
                    $updateFields += "GR = $Grade"
                }
                if ($PSBoundParameters.ContainsKey('Track')) {
                    $updateFields += "TR = '$Track'"
                }
                if ($PSBoundParameters.ContainsKey('TeacherNumber')) {
                    $updateFields += "TN = $TeacherNumber"
                }
                if ($PSBoundParameters.ContainsKey('AllDay')) {
                    $updateFields += "AL = '$AllDay'"
                }
                if ($PSBoundParameters.ContainsKey('Period0')) {
                    $updateFields += "A0 = '$Period0'"
                }
                if ($PSBoundParameters.ContainsKey('Period1')) {
                    $updateFields += "A1 = '$Period1'"
                }
                if ($PSBoundParameters.ContainsKey('Period2')) {
                    $updateFields += "A2 = '$Period2'"
                }
                if ($PSBoundParameters.ContainsKey('Period3')) {
                    $updateFields += "A3 = '$Period3'"
                }
                if ($PSBoundParameters.ContainsKey('Period4')) {
                    $updateFields += "A4 = '$Period4'"
                }
                if ($PSBoundParameters.ContainsKey('Period5')) {
                    $updateFields += "A5 = '$Period5'"
                }
                if ($PSBoundParameters.ContainsKey('Period6')) {
                    $updateFields += "A6 = '$Period6'"
                }
                if ($PSBoundParameters.ContainsKey('Period7')) {
                    $updateFields += "A7 = '$Period7'"
                }
                if ($PSBoundParameters.ContainsKey('Period8')) {
                    $updateFields += "A8 = '$Period8'"
                }
                if ($PSBoundParameters.ContainsKey('Period9')) {
                    $updateFields += "A9 = '$Period9'"
                }
                if ($PSBoundParameters.ContainsKey('Date')) {
                    $dateString = $Date.ToString('yyyy-MM-dd HH:mm:ss.fff')
                    $updateFields += "DT = '$dateString'"
                }
                if ($PSBoundParameters.ContainsKey('Reason')) {
                    $updateFields += "RS = '$Reason'"
                }
                if ($PSBoundParameters.ContainsKey('NoSchool')) {
                    $updateFields += "NS = $NoSchool"
                }
                if ($PSBoundParameters.ContainsKey('AttProgram1')) {
                    $updateFields += "AP1 = '$AttProgram1'"
                }
                if ($PSBoundParameters.ContainsKey('AttProgram2')) {
                    $updateFields += "AP2 = '$AttProgram2'"
                }
                if ($PSBoundParameters.ContainsKey('ReportingSchool')) {
                    $updateFields += "HS = $ReportingSchool"
                }
                if ($PSBoundParameters.ContainsKey('Interdistrict')) {
                    $updateFields += "IT = '$Interdistrict'"
                }
                if ($PSBoundParameters.ContainsKey('NPSSpecialEducation')) {
                    $updateFields += "NPS = '$NPSSpecialEducation'"
                }
                if ($PSBoundParameters.ContainsKey('DistrictOfResidence')) {
                    $updateFields += "ITD = '$DistrictOfResidence'"
                }
                if ($PSBoundParameters.ContainsKey('ADACode')) {
                    $updateFields += "ADA = '$ADACode'"
                }
                if ($PSBoundParameters.ContainsKey('ADADate')) {
                    $adaDateString = $ADADate.ToString('yyyy-MM-dd HH:mm:ss.fff')
                    $updateFields += "ADT = '$adaDateString'"
                }
                if ($PSBoundParameters.ContainsKey('ADAComment')) {
                    $escapedComment = $ADAComment.Replace("'", "''")
                    $updateFields += "ACO = '$escapedComment'"
                }
                if ($PSBoundParameters.ContainsKey('FederalCode')) {
                    $updateFields += "FA = $FederalCode"
                }
                
                # Always update the timestamp
                $updateFields += "DTS = GETDATE()"
                
                if ($updateFields.Count -eq 1) {
                    # Only DTS would be updated, which means no actual data was provided
                    Write-Warning "No attendance data fields were specified for update. Record for $parameterDescription was not modified."
                    return $false
                }
                
                $updateQuery = @"
UPDATE ATT 
SET $($updateFields -join ', ')
WHERE SC = $SchoolCode AND SN = $StudentNumber AND DY = $SchoolDay
"@
                
                Write-Verbose "Executing UPDATE query for: $parameterDescription"
                Write-Verbose "Updating fields: $($updateFields[0..($updateFields.Count-2)] -join ', ')"
                Write-Verbose "Query: $updateQuery"
                
                # Execute the query
                Invoke-SPSAeriesSqlQuery -Query $updateQuery
                
                Write-Verbose "Successfully updated attendance record for: $parameterDescription"
                return $true
            }
        }
        catch {
            Write-Error "Failed to update attendance record for $parameterDescription : $($_.Exception.Message)"
            throw
        }
    }

    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
