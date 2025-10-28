Function Set-SPSAeriesConfiguration{
    <#
    .SYNOPSIS
        Set the configuration to use for the SPSAeries Module
    .DESCRIPTION
        Set the configuration to use for the SPSAeries Module
    .EXAMPLE
        Set-SPSAeriesConfiguration -Name SchoolName
        Set the configuration to SchoolName
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
            [String]$Name
        )
    
        Begin{
            Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
            Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
            
        }
        Process{
            try{
                Write-Verbose -Message "Changing Config from $($Script:SPSAeriesConfigName) to $($Name)"
                $Script:SPSAeriesConfigName = $Name

                $Script:SPSAeriesConfigDir = "$Env:USERPROFILE\AppData\Local\powershell\SPSAeries\$Name"
                Write-Verbose -Message "Config dir: $SPSAeriesConfigDir"

                $Script:Config = Get-Content -Raw -Path "$Script:SPSAeriesConfigDir\config.json" | ConvertFrom-Json
                Write-Verbose -Message "Importing config.json"

                $Script:APIKey = Import-Clixml -Path "$Script:SPSAeriesConfigDir\apikey.xml"
                Write-Verbose -Message "Importing apikey.xml"

                $Script:SQLCreds = Import-Clixml -Path "$Script:SPSAeriesConfigDir\sqlcreds.xml"
                Write-Verbose -Message "Importing sqlcreds.xml"

                Write-Verbose "Config: $Config"
                Write-Verbose "URL: $($Config.APIURL)"

                # Initializes the official AeriesApi module with retry logic
                $maxRetries = 5
                $retryDelaySeconds = 5
                $attempt = 0
                $maxAttempts = $maxRetries + 1
                $initSuccess = $false
                $lastInitException = $null
                
                while (-not $initSuccess -and $attempt -lt $maxAttempts) {
                    $attempt++
                    
                    try {
                        if ($attempt -gt 1) {
                            Write-Verbose "Retry attempt $($attempt - 1) of $maxRetries after waiting $retryDelaySeconds seconds..."
                            Start-Sleep -Seconds $retryDelaySeconds
                        }
                        
                        Write-Verbose "Initializing AeriesApi (Attempt $attempt of $maxAttempts)..."
                        Initialize-AeriesApi -URL $Config.APIURL -Certificate $APIKey.GetNetworkCredential().Password
                        $initSuccess = $true
                        Write-Verbose "AeriesApi initialized successfully."
                    }
                    catch {
                        $lastInitException = $_
                        
                        if ($attempt -lt $maxAttempts) {
                            Write-Verbose "Error initializing AeriesApi: $($_.Exception.Message). Retrying... (Attempt $attempt of $maxAttempts)"
                        } else {
                            # Final attempt failed, throw the error
                            throw "Failed to initialize AeriesApi after $maxRetries retry attempts: $($_.Exception.Message)"
                        }
                    }
                }

                # Create URL Path after initialization so we have the root API url in case we need to make any unique API calls of our own
                $uri = New-Object System.Uri($Config.APIURL)
                $Script:Config.APIURL = New-Object System.Uri($uri, "api/v5/")
            }
            catch{
                Write-Error -Message "$_ went wrong."
            }
        }
        End{
            Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
        }
    }