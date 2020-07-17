Function Get-AeriesSchool{
<#
.SYNOPSIS
    Gets one or more Aeries Schools
.DESCRIPTION
    The Get-AeriesSchool function gets a student object or performs a search to retrieve multiple student objects.
.EXAMPLE
    Get-AeriesSchool -SchoolCode 1
    Get all users under the school matching school code 1.
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
        [String[]]$SchoolCode
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-AeriesAPI
    }
    Process{
        # If no school is specified, get all schools
        try{
            if (!($SchoolCode)) {
                Write-Verbose -Message "Listing all Schools..."
                $path = $APIURL + 'schools/'
                Invoke-RestMethod $path -Headers $headers
                }
            else {
                Write-Verbose -Message "Listing school matching school code $SchoolCode..."
                $path = $APIURL + 'schools/' + $SchoolCode
                Invoke-RestMethod $path -Headers $headers
            }
        }
        catch{
            Write-Error -Message "$_ went wrong."
        }
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}