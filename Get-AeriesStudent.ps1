#AdvancedFunction
Function Get-AeriesStudent{
<#
.SYNOPSIS
    Gets one or more Aeries Students
.DESCRIPTION
    The Get-AeriesStudent function gets a student object or performs a search to retrieve multiple student objects.
.EXAMPLE
    Get-ADUser -Filter * -SchoolCode 1
    Get all users under the school matching school code 1.
    .PARAMETER
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>
    [CmdletBinding()] #Enable all the default paramters, including -Verbose
    Param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            # HelpMessage='HelpMessage',
            Position=0)]
        [ValidatePattern('[0-9]')] #Validate that the string only contains letters
        [String[]]$ID,

        # Path to encrypted API Key
        [Parameter(Mandatory=$True)]
            [IO.FileInfo]$APIKey,

        # Path to the config that will hold API Key & API URL. Potentially SQL credentials for writing data into as well.
        [Parameter(Mandatory=$True)]
            [IO.FileInfo]$ConfigPath
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        #Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        
        # Import config and apikey
        $Config = Import-PowerShellDataFile -Path $ConfigPath
        $key = Import-Clixml $APIKey
        # Get all of the schools
        $SchoolCode = $Config.schoolcode
        # URL to access Aeries API
        $APIURL = $Config.APIURL
        #Headers for Aeries API
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        # Insert Certificate here
        $headers.Add('AERIES-CERT', $key.GetNetworkCredential().Password)
        $headers.Add('accept', 'application/json')
    }
    Process{
        ForEach($stu in $ID){ #Pipeline input
            try{ #Error handling
                $path = $APIURL + $SchoolCode + '/students/' + $ID
                Write-Verbose -Message "Doing something on $stu..."
                
                $path = $APIURL + $SchoolCode + '/students/' + $stu

                $Result = Invoke-RestMethod $path -Headers $headers

                #Generate Output
                New-Object -TypeName PSObject -Property @{
                    Result = $Result
                    Object = $stu
                }
            }
            catch{
                Write-Error -Message "$_ went wrong on $stu"
            }
        }
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}