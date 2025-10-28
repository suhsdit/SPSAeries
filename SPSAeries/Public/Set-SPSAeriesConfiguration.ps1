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
            # Retry logic for the entire configuration process
            $maxRetries = 5
            $retryDelaySeconds = 5
            $attempt = 0
            $maxAttempts = $maxRetries + 1
            $configSuccess = $false
            
            while (-not $configSuccess -and $attempt -lt $maxAttempts) {
                $attempt++
                
                try {
                    if ($attempt -gt 1) {
                        Write-Verbose "Retry attempt $($attempt - 1) of $maxRetries after waiting $retryDelaySeconds seconds..."
                        Start-Sleep -Seconds $retryDelaySeconds
                    }
                    
                    Write-Verbose -Message "Changing Config from $($Script:SPSAeriesConfigName) to $($Name) (Attempt $attempt of $maxAttempts)"
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

                    # Initializes the official AeriesApi module
                    Write-Verbose "Initializing AeriesApi..."
                    Initialize-AeriesApi -URL $Config.APIURL -Certificate $APIKey.GetNetworkCredential().Password
                    Write-Verbose "AeriesApi initialized successfully."

                    # Create URL Path after initialization so we have the root API url in case we need to make any unique API calls of our own
                    $uri = New-Object System.Uri($Config.APIURL)
                    $Script:Config.APIURL = New-Object System.Uri($uri, "api/v5/")
                    
                    # If we reach here, configuration was successful
                    $configSuccess = $true
                    Write-Verbose "Configuration '$Name' set successfully."
                }
                catch {
                    if ($attempt -lt $maxAttempts) {
                        Write-Verbose "Error setting configuration: $($_.Exception.Message). Retrying... (Attempt $attempt of $maxAttempts)"
                    } else {
                        # Final attempt failed, throw a detailed error
                        $errorMessage = "Failed to set Aeries configuration for '$Name' after $maxRetries retry attempts: $($_.Exception.Message)"
                        if ($_.Exception.InnerException) {
                            $errorMessage += "`nInner Exception: $($_.Exception.InnerException.Message)"
                        }
                        Write-Error -Message $errorMessage -ErrorAction Stop
                    }
                }
            }
        }
        End{
            Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
        }
    }