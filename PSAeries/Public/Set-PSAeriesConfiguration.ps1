Function Set-PSAeriesConfiguration{
    <#
    .SYNOPSIS
        Set the configuration to use for the PSAeries Module
    .DESCRIPTION
        Set the configuration to use for the PSAeries Module
    .EXAMPLE
        Set-PSAeriesConfiguration -Name SchoolName
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
            # If no users are specified, get all students
            try{
                Write-Verbose -Message "Changing Config from $($Script:PSAeriesConfigName) to $($Name)"
                $Script:PSAeriesConfigName = $Name
                $Script:PSAeriesConfigDir = "$Env:USERPROFILE\AppData\Local\powershell\PSAeries\$Name"

                write-verbose "Triggered"
                Write-Verbose -Message "PSAeriesConfigDir: $($Script:PSAeriesConfigDir)"
                write-verbose "Triggered"
                $Script:Config = Import-PowerShellDataFile -Path "$Script:PSAeriesConfigDir\config.PSD1"
                write-verbose "Triggered"
                $Script:APIKey = Import-Clixml -Path "$Script:PSAeriesConfigDir\apikey.xml"
                write-verbose "Triggered"
            }
            catch{
                Write-Error -Message "$_ went wrong."
            }
            
            
            
        }
        End{
            Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
        }
    }