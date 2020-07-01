**PSAeries**
*Powershell module for Aeries SIS*

**Installation Instructions**
Currently requires population of the config.PSD1, do not populate APIKey in config.PSD1 at this time
Also need to generate secure APIKey and create by running Create-SecureCredFile.PS1

You will need to point to these files when running the commands.

**Examples:**

*This will list student with ID Number 1234 under school with school code 1*
Get-AeriesStudent -ID 1234 -APIKey .\APIKey.xml -ConfigPath .\config.PSD1 -SchoolCode 1

*This will list all students at school code 1*
Get-AeriesStudent -APIKey .\APIKey.xml -ConfigPath .\config.PSD1 -SchoolCode 1

*Accepts pipeline input for multiple Student ID's*
1234, 1235, 5567 | Get-AeriesStudent -APIKey .\APIKey.xml -ConfigPath .\config.PSD1 -SchoolCode 1

APIKey, ConfigPath, & SchoolCode are all currently required parameters.
I would like to code in direct access to the configpath and school code in different config files so you can switch which school you are working with.