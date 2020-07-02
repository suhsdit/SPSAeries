# Template for module courtesy of RamblingCookieMonster
#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($Public + $Private))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Here I might...
# Read in or create an initial config file and variable


# Export Public functions ($Public.BaseName) for WIP modules
# Set variables visible to the module and its functions only
$PSAeriesConfigDir = "$Env:USERPROFILE\AppData\Local\powershell\PSAeries"
New-Variable -Name PSAeriesConfigDir -Value $Config -Scope Script -Force
$Config = Import-PowerShellDataFile -Path "$PSAeriesConfigDir\config.PSD1"
New-Variable -Name Config -Value $Config -Scope Script -Force
$APIKey = Import-Clixml -Path "$PSAeriesConfigDir\apikey.xml"
New-Variable -Name APIKey -Value $APIKey -Scope Script -Force

Export-ModuleMember -Function $Public.Basename