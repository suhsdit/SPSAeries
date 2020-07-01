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
            # [ValidatePattern('[A-Z]')] #Validate that the string only contains letters
            [String[]]$ID,

            # Path to encrypted API Key
            [Parameter(Mandatory=$True)]
                [IO.FileInfo]$APIKey

            # Path to the config that will hold API Key & API URL. Potentially SQL credentials for writing data into as well.
            [Parameter(Mandatory=$True)]
                [IO.FileInfo]$ConfigPath
        )

        Begin{
            Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
            #Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
            
            # Import config and apikey
            $Config = Import-PowerShellDataFile -Path .\config.PSD1
            $apikey = Import-Clixml $ConfigPath

            # URL to access Aeries API
            $APIURL = $Config.APIURL
            #Headers for Aeries API
            $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            # Insert Certificate here
            $headers.Add('AERIES-CERT', $apikey.GetNetworkCredential().Password)
            $headers.Add('accept', 'application/json')

            #the path to pull the student and invoke the request
            $path = $APIURL + $SchoolCode + '/students/' + $ID
            Invoke-RestMethod $path -Headers $headers
        }
        Process{
            ForEach($Object in $PipelineInput){ #Pipeline input
                try{ #Error handling
                    Write-Verbose -Message "Doing something on $Object..."
                    $Result = $Object | Do-SomeThing -ErrorAction Stop
                    
                    #Generate Output
                    New-Object -TypeName PSObject -Property @{
                        Result = $Result
                        Object = $Object
                    }
                }
                catch{
                    Write-Error -Message "$_ went wrong on $Object"
                }
            }
        }
        End{
            Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
        }
    }