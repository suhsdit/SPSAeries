Function Update-SPSAeriesStudent{
<#
.SYNOPSIS
    Updates data in SQL DB For an Aeries Student
.DESCRIPTION
    The Update-SPSAeriesStudent function specifically updates StudentEmail and NetworkLoginID in the Aeries SQL DB.
    This exists because the Aeries API does not allow for these fields to be updated via the API.
.EXAMPLE
    Update-SPSAeriesStudent -ID 12345 -email "littlejohnny@school.edu"
    Update student with ID number 12345 email address value to be littlejohny@school.edu in Aeries DB.
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
        [String]$ID,

        # New Email Address to be updated in the SQL DB for the provided StudentID
        [Parameter(Mandatory=$False)]
        [String]$Email,

        # New Network Login ID to be updated in the SQL DB for the provided StudentID
        [Parameter(Mandatory=$False)]
        [String]$NetworkLoginID #Should probably change this to SecureString
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
    }
    Process{
        if ($Email) {
            $query = "UPDATE STU SET SEM = '$($Email.Replace("'", "''"))' WHERE ID = $ID"
            Write-Verbose -Message "Updating email for student ID $ID"
            $null = Invoke-SPSAeriesSqlQuery -Query $query -As NonQuery -Force
        }

        if ($NetworkLoginID) {
            $query = "UPDATE STU SET NID = '$($NetworkLoginID.Replace("'", "''"))' WHERE ID = $ID"
            Write-Verbose -Message "Updating Network Login ID for student ID $ID"
            $null = Invoke-SPSAeriesSqlQuery -Query $query -As NonQuery -Force
        }
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}