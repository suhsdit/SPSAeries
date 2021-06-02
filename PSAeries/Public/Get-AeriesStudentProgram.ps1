Function Get-AeriesStudentProgram{
<#
.SYNOPSIS
    Gets one or more Aeries Students
.DESCRIPTION
    The Get-AeriesStudent function gets a student object or performs a search to retrieve multiple student objects.
.EXAMPLE
    Get-AeriesStudent -SchoolCode 1
    Get all students under the school matching school code 1.
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
        [ValidatePattern('[0-9]')] #Validate that the string only contains Numbers
        [Alias("User", "StudentID")]
        [String[]]$ID,

        # School Code under whitch to search for students
        [Parameter(Mandatory=$False)]
            [String[]]$SchoolCode,

        # Grade level of students
        [Parameter(Mandatory=$False)]
        [String]$Grade,

        # StudentNumber by which to search for the student
        [Parameter(Mandatory=$False)]
        [String]$StudentNumber
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        
        
        Connect-AeriesAPI
        # Should probably edit root URL so we don't have to replace this.
        $APIURL = $APIURL -replace 'v3','v5'
    }
    Process{
        $result = $null
        $SchoolCodes = @()

        # If a school code is not provided, find all school codes
        # and add those school codes to the $SchoolCodes array
        if (!$SchoolCode) {
            $Schools = Get-AeriesSchool
            foreach ($School in $Schools) {
                $SchoolCodes += $School.SchoolCode
            }
        }
        else {
            $SchoolCodes += $SchoolCode
        }
        Write-Verbose -Message "Using School codes: $($SchoolCodes)"

        ForEach ($sc in $SchoolCodes) {
            Write-Verbose -Message "Working in SchoolCode $($sc)"

            # If no users are specified, get all students
            try{ 
                if ($ID.Count -lt 1 -and !$Grade -and !$StudentNumber) {
                    Write-Verbose -Message "Listing all students..."
                    $path = $APIURL + 'schools/' + $sc + '/students/0/programs'
                    Write-Verbose -Message "path $path"
                    $result += Invoke-RestMethod $path -Headers $headers
                    }
                elseif ($ID.Count -lt 1 -and $grade -and !$StudentNumber) {
                    Write-Verbose -Message "Listing all students in grade $Grade..."
                    $path = $APIURL + 'schools/' + $sc + '/students/grade/' + $Grade + '/programs'
                    $result += Invoke-RestMethod $path -Headers $headers
                }
            }
            catch{
                Write-Error -Message "$_ went wrong."
            }
            
            if ($ID.Count -gt 0)
            {
                ForEach($stu in $ID){ #Pipeline input
                    try{
                        Write-Verbose -Message "Searching for Student with ID Number $stu..."
                        $path = $APIURL + 'schools/' + $sc + '/students/' + $stu + '/programs'
                        $result += Invoke-RestMethod $path -Headers $headers
                    }
                    catch{
                        Write-Error -Message "$_ went wrong on $stu"
                    }
                }
            }
            
            if ($StudentNumber)
            {
                ForEach($stu in $StudentNumber){ 
                    try{
                        Write-Verbose -Message "Searching for Student with Student Number $stu..."
                        $path = $APIURL + 'schools/' + $sc + '/students/sn/' + $stu + '/programs'
                        $result += Invoke-RestMethod $path -Headers $headers
                    }
                    catch{
                        Write-Error -Message "$_ went wrong on $stu"
                    }
                }
            }
        }
        $result
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}