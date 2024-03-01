Function New-SPSAeriesConfiguration{
    <#
    .SYNOPSIS
        Setup new configuration to use for the SPSAeries Module
    .DESCRIPTION
        Setup new configuration to use for the SPSAeries Module
    .EXAMPLE
        New-SPSAeriesConfiguration
        Start the process of setting config. Follow prompts.
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
            [String]$Name
        )
    
        Begin{
            Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
            Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
            
        }
        Process{
            # If no users are specified, get all students
            try{
                if (!$Name) {
                    $Name = Read-Host "Config Name"
                }

                if(!(Test-Path -path "$SPSAeriesConfigRoot\$Name")) {
                    New-Item -ItemType Directory -Name $Name -Path $Script:SPSAeriesConfigRoot
                    $Script:SPSAeriesConfigDir = "$Script:SPSAeriesConfigRoot\$Name"

                    Write-Verbose -Message "Setting new Config file"

                    $APIURL = Read-Host 'Aeries API URL'
                    Get-Credential -UserName ' ' -Message 'Enter your Aeries API Key' | Export-Clixml "$SPSAeriesConfigDir\apikey.xml"

                    $SQLServer = Read-Host 'Aeries SQL DB Server Address'
                    $SQLDB = Read-Host 'Aeries SQL DB'
                    Get-credential -Message 'Enter your Aeries SQL credentials' | Export-Clixml "$SPSAeriesConfigDir\sqlcreds.xml"
                    
                    @{Config=$Name;APIURL=$APIURL;SQLServer=$SQLServer;SQLDB=$SQLDB} | ConvertTo-Json | Out-File "$SPSAeriesConfigDir\config.json"

                    # Set the new files as active
                    Set-SPSAeriesConfiguration $Name
                }
                else {
                    Write-Warning -Message "Config already exists."
                    break
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