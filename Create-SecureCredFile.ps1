# Run once to create secure credential file
Get-Credential -UserName ' ' | Export-Clixml apikey.xml