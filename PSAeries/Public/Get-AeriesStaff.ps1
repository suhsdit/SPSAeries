Function Get-AeriesStaff{
    <#
    .SYNOPSIS
        Gets one or more Aeries Staff
    .DESCRIPTION
        The Get-AeriesStaff function gets a staff object or performs a search to retrieve multiple staff objects.
    .EXAMPLE
        Get-AeriesStaff
        Return data for all staff.
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
            [Alias("User", "StaffID")]
            [String[]]$ID
        )
    
        Begin{
            Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
            Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
            Connect-AeriesAPI
        }
        Process{
            $result = $null
            
            Write-Verbose -Message "Listing all staff..."
            $path = $APIURL + "staff/$($ID)"
            Write-Verbose -Message "path $path"
            $result += Invoke-RestMethod $path -Headers $headers

            $result
        }
        End{
            Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
        }
    }