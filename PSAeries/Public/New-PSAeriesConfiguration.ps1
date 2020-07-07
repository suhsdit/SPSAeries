Function New-PSAeriesConfiguration{
    <#
    .SYNOPSIS
        Setup new configuration to use for the PSAeries Module
    .DESCRIPTION
        Setup new configuration to use for the PSAeries Module
    .EXAMPLE
        New-PSAeriesConfiguration
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

                if(!(Test-Path -path "$PSAeriesConfigRoot\$Name")) {
                    New-Item -ItemType Directory -Name $Name -Path $Script:PSAeriesConfigRoot
                    $Script:PSAeriesConfigDir = "$Script:PSAeriesConfigRoot\$Name"

                    Write-Verbose -Message "Setting new Config file"

                    $APIURL = Read-Host 'Aeries API URL'
                    Get-Credential -UserName ' ' -Message 'Enter your Aeries API Key' | Export-Clixml "$PSAeriesConfigDir\apikey.xml"

                    $SQLServer = Read-Host 'Aeries SQL DB Server Address'
                    $SQLDB = Read-Host 'Aeries SQL DB'
                    Get-credential -Message 'Enter your Aeries SQL credentials' | Export-Clixml "$PSAeriesConfigDir\sqlcreds.xml"
                    
                    @{Config=$Name;APIURL=$APIURL;SQLServer=$SQLServer;SQLDB=$SQLDB} | ConvertTo-Json | Out-File "$PSAeriesConfigDir\config.json"

                    # Set the new files as active
                    Set-PSAeriesConfiguration $Name
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