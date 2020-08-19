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
        [Parameter(Mandatory=$False)]
        [ValidatePattern('[0-9]')]
        [String]$SchoolCode,

        [Parameter(Mandatory=$False)]
        [ValidatePattern('[0-9]')]
        [Alias("User", "StudentID")]
        [String]$ID,

        [Parameter(Mandatory=$False)]
        [String]$Path
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-AeriesAPI
    }
    Process{
        $result = $null
        
        Write-Verbose -Message "Searching for Student Picture with ID Number $ID..."
        $path = $APIURL + 'schools/' + $SchoolCode + '/StudentPictures/' + $ID
        $result += Invoke-RestMethod $path -Headers $headers

        $result
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}