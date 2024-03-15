Function New-SPSAeriesConfiguration{
    [CmdletBinding()] 
    Param(
        [Parameter(Mandatory=$false,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [String]$Name,

        [Parameter(Mandatory=$false)]
        [String]$APIURL,

        [Parameter(Mandatory=$false)]
        [PSCredential]$APIKey,

        [Parameter(Mandatory=$false)]
        [String]$SQLServer,

        [Parameter(Mandatory=$false)]
        [String]$SQLDB,

        [Parameter(Mandatory=$false)]
        [PSCredential]$SQLCredentials
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
    }

    Process{
        try{
            if (!$Name) {
                $Name = Read-Host "Config Name"
            }

            if(!(Test-Path -path "$SPSAeriesConfigRoot\$Name")) {
                New-Item -ItemType Directory -Name $Name -Path $Script:SPSAeriesConfigRoot
                $Script:SPSAeriesConfigDir = "$Script:SPSAeriesConfigRoot\$Name"

                Write-Verbose -Message "Setting new Config file"

                if (!$APIURL) {
                    $APIURL = Read-Host 'Aeries API URL'
                }

                if (!$APIKey) {
                    $APIKey = Get-Credential -UserName ' ' -Message 'Enter your Aeries API Key'
                }
                $APIKey | Export-Clixml "$SPSAeriesConfigDir\apikey.xml"

                if (!$SQLServer) {
                    $SQLServer = Read-Host 'Aeries SQL DB Server Address'
                }

                if (!$SQLDB) {
                    $SQLDB = Read-Host 'Aeries SQL DB'
                }

                if (!$SQLCredentials) {
                    $SQLCredentials = Get-credential -Message 'Enter your Aeries SQL credentials'
                }
                $SQLCredentials | Export-Clixml "$SPSAeriesConfigDir\sqlcreds.xml"
                
                @{Config=$Name;APIURL=$APIURL;SQLServer=$SQLServer;SQLDB=$SQLDB} | ConvertTo-Json | Out-File "$SPSAeriesConfigDir\config.json"

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