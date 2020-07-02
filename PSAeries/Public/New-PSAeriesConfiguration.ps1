$PSAeriesConfigDir = "$Env:USERPROFILE\AppData\Local\powershell\PSAeries"

$config = Read-Host "Config Name"

New-Item -ItemType Directory -Name $config -Path $PSAeriesConfigDir

# Run once to create secure credential file
Get-Credential -UserName ' ' -Message 'Enter your Aeries API Key' | Export-Clixml "$PSAeriesConfigDir\$config\apikey.xml"
Get-credential -Message 'Enter your Aeries SQL credentials' | Export-Clixml "$PSAeriesConfigDir\$config\sqlcreds.xml"
copy-item -Path $PSScriptRoot\blank_config.PSD1 -Destination "$PSAeriesConfigDir\$config\config.PSD1"

# Eventually will ask for all values in this script. For now...
Write-Host 'Edit Config file with proper values at' $PSAeriesConfigDir\$config\config.PSD1