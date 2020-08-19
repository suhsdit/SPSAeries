Function Get-AeriesStudentPicture{
<#
.SYNOPSIS
    Retrieve Aeries Student Picture
.DESCRIPTION
    
.EXAMPLE
    Get-AeriesStudentPicture -SchoolCode 1 -ID 12345
.PARAMETER
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>
    [CmdletBinding()] #Enable all the default paramters, including -Verbose
    Param(
        # School Code under whitch to search for students
        [Parameter(Mandatory=$True)]
            [ValidatePattern('[0-9]')]
            [String[]]$SchoolCode,

        [Parameter(Mandatory=$False)]
        [ValidatePattern('[0-9]')]
        [Alias("User", "StudentID")]
        [String[]]$ID,

        [Parameter(Mandatory=$True)]
        [String[]]$Path
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-AeriesAPI
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
                    Write-Verbose -Message "Retrieving pictures for all students..."
                    $path = $APIURL + 'schools/' + $sc + '/StudentPictures/'
                    Write-Verbose -Message "path $path"
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
                        Write-Verbose -Message "Searching for Student Picture with ID Number $stu..."
                        $path = $APIURL + 'schools/' + $sc + '/StudentPictures/' + $stu
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