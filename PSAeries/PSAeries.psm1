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

# Aeries Config Name
New-Variable -Name PSAeriesConfigName -Scope Script -Force
New-Variable -Name PSAeriesConfigDir -Scope Script -Force
# Location Of Config.txt
New-Variable -Name Config -Scope Script -Force
# Location of apikey.xml
New-Variable -Name APIKey -Scope Script -Force

Export-ModuleMember -Function $Public.Basename