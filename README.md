**PSAeries**

*Powershell module for Aeries SIS*

**Disclaimer**

This is my very first Powershell module. I still consider myself to be an advanced novice with Powershell, so use with caution! Inspect the code before running in your own production environment! I am not responsible for any unintended consequences, some commands will write directly to your Aeries SQL Database. Again, use with caution.

That said, I could use help from anyone with any level of powershell experience!

**Installation Instructions**

1. Put the PSAeries folder into your User Module repository at: %UserProfile%\Documents\WindowsPowerShell\Modules
2. Run Import-Module PSAeries
3. Run New-PSAeriesConfiguration to setup new Aeries DB/API
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

Update 7/22: Built out functions to interact with Aeries District Assets. In my limited testing, everything appears to work as expected. Need to build out help more on those commands. Also, an update to the below paragraph, I've noticed more fields are available to write into via the API now, so I'd like to look to move the writing capability over to the API where it's supported. There is no API for District Assets though, so there will continue to be some commands that communicate directly with the SQL DB.

Build out more functionality. It currently does the bare minimum that I need for account provisioning for students.
Aeries API Documentation can be found here: https://support.aeries.com/support/solutions/articles/14000077926-aeries-api-full-documentation
The API only allows writing into certain fields, so SQL has to be used for writing. I'm trying to rely on the API for pulling data.
