Function Get-AeriesStudent{
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
        
        Write-Verbose "Using Config: $Config"
        # URL to access Aeries API
        $APIURL = $Config.APIURL
        Write-Verbose "APIURL: $APIURL"

        #Headers for Aeries API
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add('AERIES-CERT', $APIKey.GetNetworkCredential().Password)
        $headers.Add('accept', 'application/json')
    }
    Process{
        $result

        $SchoolCodes = @()
        if (!$SchoolCode) {
            $Schools = Get-AeriesSchool
            foreach ($School in $Schools) {
                $SchoolCodes += $School.SchoolCode
                write-verbose -Message "School Code Detected: $($School.SchoolCode)"
            }
        }
        else {
            $SchoolCodes += $SchoolCode
        }
        Write-Verbose -Message "All School codes: $($SchoolCodes)"
        Write-Verbose -Message "First SchoolCode $($SchoolCodes[0])"

        ForEach ($sc in $SchoolCodes) {
            Write-Verbose -Message "Working in SchoolCode $($sc)"

            # If no users are specified, get all students
            try{ #Error handling
                if ($ID.Count -lt 1 -and !$Grade -and !$StudentNumber) {
                    Write-Verbose -Message "Listing all students..."
                    $path = $APIURL + 'schools/' + $sc + '/students/'
                    Write-Verbose -Message "path $path"
                    $result += Invoke-RestMethod $path -Headers $headers
                    }
                elseif ($grade) {
                    Write-Verbose -Message "Listing all students in grade $Grade..."
                    $path = $APIURL + 'schools/' + $sc + '/students/grade/' + $Grade
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
                        $path = $APIURL + 'schools/' + $sc + '/students/' + $stu
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
                        $path = $APIURL + 'schools/' + $sc + '/students/sn/' + $stu
                        $result += Invoke-RestMethod $path -Headers $headers
                    }
                    catch{
                        Write-Error -Message "$_ went wrong on $stu"
                    }
                }
            }
            
        }
        return $result
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}