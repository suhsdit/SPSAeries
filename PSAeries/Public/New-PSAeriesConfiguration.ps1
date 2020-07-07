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
                $PSAeriesConfigDir = "$Env:USERPROFILE\AppData\Local\powershell\PSAeries"
                
                $config = ''

                if ($Name) {
                    $config = $Name
                }
                elseif (!$Name) {
                    $config = Read-Host "Config Name"
                }
                New-Item -ItemType Directory -Name $config -Path $PSAeriesConfigDir

                # Run once to create secure credential file
                Get-Credential -UserName ' ' -Message 'Enter your Aeries API Key' | Export-Clixml "$PSAeriesConfigDir\$config\apikey.xml"
                Get-credential -Message 'Enter your Aeries SQL credentials' | Export-Clixml "$PSAeriesConfigDir\$config\sqlcreds.xml"
                copy-item -Path $PSScriptRoot\blank_config.PSD1 -Destination "$PSAeriesConfigDir\$config\config.PSD1"

                # Eventually will ask for all values in this script. For now...
                Write-Host 'Edit Config file with proper values at' $PSAeriesConfigDir\$config\config.PSD1
            }
            catch{
                Write-Error -Message "$_ went wrong."
            }
            
            
            
        }
        End{
            Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
        }
    }