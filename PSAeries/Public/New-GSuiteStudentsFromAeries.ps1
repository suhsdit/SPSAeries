# Logging
Start-Transcript -Path ".\New-GSuiteStudentsFromAeries.log"

# Need to setup PSGSuite Module for Google domain that you wish to create accounts on
#Requires -Module PSGSuite, PSAeries

Set-PSAeriesConfiguration NCCS
Switch-PSGSuiteConfig NCCS

# Get all GSuite Users, store in dict where every email alias is a key pointing to full user object
$gsUsers = Get-GSUser -Filter * -Verbose
$gsDict = @{}
$gsUsers | ForEach-Object {
    $user = $_
    foreach ($email in $_.emails | Where-Object {$_.address}) {
        $gsDict[$email.address] = $user
    }
}

$AeriesStudents = Get-AeriesStudent -SchoolCode 1
$ActiveStudents = @{}
$NewStudentsList = @()

$AeriesStudents | ForEach-Object {
    # Don't add student if something exists in InactiveStatusCode field
    if ($_.InactiveStatusCode -ne '') {
        $user = $_
        Write-Host "Inactive status of" $_.InactiveStatusCode "detected for PermanentID" $_.PermanentID
    } else {
        $email = $_.FirstName[0..1] + $_.LastName[0..2] + $_.PermanentID
        if ($_.StudentEmailAddress -eq $email) { #This is where I left off. haven't ran this yet.
            $user = $_
            $ActiveStudents[$user.StudentEmailAddress] = $user
            $NewStudentsList += $user.StudentEmailAddress
            Write-Host "Active student detected with PermanentID" $_.PermanentID
        } else {
            Write-Host "PermanentID:" $_.PermanentID "email field is empty. Not adding to list." -ForegroundColor Red
            # Maybe have this trigger off another script that checks for empty email address fields to create student emails.dd
        }
    }
}

# Iterate through all active students from Aeries
foreach ($user in $ActiveStudentList)
{
   if ($null -eq $gsDict[$user]){
       # Add the user since they don't exist in the current user list
       $NewStudent = $ActiveABIStudents[$user]
       Write-Host "add user:" $NewStudent.StudentEmailAddress -BackgroundColor Green
       #New-GSUser `
       # -PrimaryEmail $NewStudent.StudentEmailAddress `
       # -GivenName $NewStudent.FirstName `
       # -FamilyName $NewStudent.LastName `
       # -FullName $NewStudent.FirstName + $NewStudent.LastName`
       # -Password (ConvertTo-SecureString -String $config.StudentPassword -AsPlainText -Force)
       # -OrgUnitPath 'Student/Middle/Grade' + $NewStudent.Grade `
   } else {
       Write-Host "User exists:" $user
   }
}