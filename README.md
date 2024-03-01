**PSAeries**

*Powershell module for Aeries SIS*

** 0.2.0 Updates **

This module is shifting from what was once a standalone module to a module that supplements the official Aeries PS Module. Redundant commands have been removed. This module is meant to address design issues with the Aeries API and Aeries PS Module. This first update has stripped old commands and working on getting a workflow down for publishing to the PS Gallery. The below instructions still need to be updated.

**Disclaimer**

We hold no responsibility for any unintended consequences of running this module, some commands will write directly to your Aeries SQL Database. Use with caution.

**Installation Instructions**

* Run New-PSAeriesConfiguration to setup new Aeries DB/API
  * You will need to create an APIKey in Aeries and give it the appropriate read privileges.
  * You will also need your SQL DB info if you wish to write into Aeries
  * Your SQL DB will need to be updated from one year to the next after you do an end of the year rollover.

Your API Key and SQL Credentials will be securely stored encrypted by the user account.

After that, you should be set, you can run New-PSAeriesConfiguration again to setup additional schools, and run "Set-PSAeriesConfiguration ConfigName" to switch between configs.

**Examples:**

*This will list student with ID Number 1234*

Get-AeriesStudent -ID 1234

-------------------------------

*This will list all students at school code 1*

Get-AeriesStudent -SchoolCode 1

-------------------------------

*This will list all students under all school codes*

Get-AeriesStudent

-------------------------------

*Accepts pipeline input for multiple Student ID's*

1234, 1235, 5567 | Get-AeriesStudent

-------------------------------

**To Do**

Update 7/22: Built out functions to interact with Aeries District Assets. In my limited testing, everything appears to work as expected. Need to build out help more on those commands.