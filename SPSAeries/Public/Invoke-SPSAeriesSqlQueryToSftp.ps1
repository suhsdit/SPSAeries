Function Invoke-SPSAeriesSqlQueryToSftp {
    <#
    .SYNOPSIS
        Executes a SQL query against Aeries database and uploads the results as CSV to an SFTP server.
    .DESCRIPTION
        This function combines the functionality of Invoke-SPSAeriesSqlQuery with SFTP upload capabilities.
        It executes a SQL query from a file against the configured Aeries database, exports the results
        to a CSV file, and then uploads that file to a specified SFTP server.
        
        The function leverages saved SPSAeries configurations for database connection details,
        simplifying the process of extracting data and transferring it to external systems.
    .PARAMETER SqlFilePath
        The full path to a .sql file containing the SQL query to execute.
    .PARAMETER SftpHost
        The hostname or IP address of the SFTP server.
    .PARAMETER SftpPort
        The port number for the SFTP server. Defaults to 22.
    .PARAMETER SftpUsername
        The username for authenticating with the SFTP server.
    .PARAMETER SftpPassword
        The password for authenticating with the SFTP server. Should be provided as a SecureString.
    .PARAMETER SftpKeyFile
        The path to a private key file for authenticating with the SFTP server. 
        If specified, this will be used instead of a password.
    .PARAMETER RemotePath
        The directory path on the SFTP server where the CSV file should be uploaded.
    .PARAMETER CsvFileName
        The name to use for the CSV file. If not specified, a name will be generated based on
        the SQL file name and current timestamp.
    .PARAMETER TempDirectory
        The local directory where the temporary CSV file will be created before upload.
        Defaults to the system's temporary directory.
    .PARAMETER QueryTimeout
        Specifies the SQL query timeout in seconds. Defaults to 30.
    .PARAMETER Force
        Suppresses the confirmation prompt for queries that appear to modify data or schema.
    .PARAMETER DeleteAfterUpload
        If specified, the local CSV file will be deleted after successful upload to the SFTP server.
    .EXAMPLE
        $cred = Get-Credential -Message "Enter SFTP credentials"
        Invoke-SPSAeriesSqlQueryToSftp -SqlFilePath "C:\Queries\StudentData.sql" -SftpHost "sftp.example.com" -SftpCredential $cred -RemotePath "/uploads"
        # Executes the SQL query from file, exports results to CSV, and uploads to the SFTP server using credential-based authentication.
    .EXAMPLE
        Invoke-SPSAeriesSqlQueryToSftp -SqlFilePath "C:\Queries\DailyReport.sql" -SftpHost "sftp.example.com" -SftpKeyFile "C:\Keys\sftp_key.ppk" -SftpCredential (Get-Credential) -RemotePath "/reports" -CsvFileName "DailyReport_$(Get-Date -Format 'yyyyMMdd').csv" -DeleteAfterUpload
        # Executes the SQL query, uploads the CSV with a custom filename using key authentication, and deletes the local file after upload.
    .NOTES
        Requires the SPSAeries module with a configured connection (Set-SPSAeriesConfiguration).
        Uses SSH.NET library (via Posh-SSH module) for SFTP operations if available, otherwise falls back to .NET SSH libraries.
    .LINK
        Invoke-SPSAeriesSqlQuery
        Set-SPSAeriesConfiguration
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    Param(
        [Parameter(Mandatory = $true,
            Position = 0,
            HelpMessage = 'Path to a .sql file containing the query.')]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$SqlFilePath,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The hostname or IP address of the SFTP server.')]
        [string]$SftpHost,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The port number for the SFTP server.')]
        [int]$SftpPort = 22,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specify a PSCredential object for SFTP authentication.')]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SftpCredential,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The path to a private key file for authenticating with the SFTP server.')]
        [string]$SftpKeyFile,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The directory path on the SFTP server where the CSV file should be uploaded.')]
        [string]$RemotePath,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The name to use for the CSV file.')]
        [string]$CsvFileName,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The local directory where the temporary CSV file will be created before upload.')]
        [string]$TempDirectory = [System.IO.Path]::GetTempPath(),

        [Parameter(Mandatory = $false,
            HelpMessage = 'Query timeout in seconds.')]
        [int]$QueryTimeout = 30,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Suppresses confirmation for modifying queries.')]
        [switch]$Force,

        [Parameter(Mandatory = $false,
            HelpMessage = 'If specified, the local CSV file will be deleted after successful upload.')]
        [switch]$DeleteAfterUpload,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specifies the delimiter for the output file. Valid values are "Comma" and "Tab". Defaults to "Comma".')]
        [ValidateSet("Comma", "Tab")]
        [string]$Delimiter = "Comma",

        [Parameter(Mandatory = $false,
            HelpMessage = 'If specified, verifies the upload was successful by checking if the file exists on the server with an updated timestamp.')]
        [switch]$ConfirmSftpUpload
    )

    Begin {
        Write-Verbose "Starting $($MyInvocation.InvocationName)"

        # Validate parameters
        if (-not $SftpCredential) {
            throw "SftpCredential is required for authentication, even when using key-based authentication."
        }

        if ($SftpKeyFile -and -not (Test-Path $SftpKeyFile -PathType Leaf)) {
            throw "The specified SSH key file does not exist: $SftpKeyFile"
        }

        # Ensure the SQL file exists and has a .sql extension
        if (-not $SqlFilePath.EndsWith('.sql', [StringComparison]::OrdinalIgnoreCase)) {
            throw "The SQL file path must have a .sql extension."
        }

        # Generate CSV filename if not provided
        if (-not $CsvFileName) {
            $sqlFileName = [System.IO.Path]::GetFileNameWithoutExtension($SqlFilePath)
            $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
            $CsvFileName = "$sqlFileName`_$timestamp.csv"
        }

        # Ensure the temporary directory exists
        if (-not (Test-Path $TempDirectory -PathType Container)) {
            try {
                New-Item -Path $TempDirectory -ItemType Directory -Force | Out-Null
                Write-Verbose "Created temporary directory: $TempDirectory"
            }
            catch {
                throw "Failed to create temporary directory '$TempDirectory': $($_.Exception.Message)"
            }
        }

        # Full path for the temporary CSV file
        $tempCsvPath = Join-Path -Path $TempDirectory -ChildPath $CsvFileName
        Write-Verbose "Temporary CSV file will be created at: $tempCsvPath"

        # Check if Posh-SSH module is available
        $poshSshAvailable = $false
        try {
            if (Get-Module -ListAvailable -Name Posh-SSH) {
                $poshSshAvailable = $true
                Write-Verbose "Posh-SSH module is available and will be used for SFTP operations."
            }
            else {
                Write-Verbose "Posh-SSH module not found. Will use .NET SSH libraries instead."
                # If using key file, ensure SSH.NET is available
                if ($SftpKeyFile) {
                    try {
                        Add-Type -AssemblyName System.Security
                        # Try multiple potential locations for SSH.NET library
                        $sshNetPaths = @(
                            (Join-Path $PSScriptRoot "..\lib\SSH.NET\Renci.SshNet.dll"),
                            "$env:ProgramFiles\SSH.NET\Renci.SshNet.dll",
                            "$env:ProgramFiles(x86)\SSH.NET\Renci.SshNet.dll"
                        )
                        
                        $loaded = $false
                        foreach ($path in $sshNetPaths) {
                            if (Test-Path $path) {
                                try {
                                    Add-Type -Path $path -ErrorAction Stop
                                    $loaded = $true
                                    break
                                } catch {
                                    Write-Verbose "Could not load SSH.NET from $path : $($_.Exception.Message)"
                                }
                            }
                        }
                        
                        if (-not $loaded) {
                            throw "SSH.NET library not found in expected locations."
                        }
                    }
                    catch {
                        Write-Warning "SSH.NET library not found. Please install Posh-SSH module for key-based authentication: Install-Module -Name Posh-SSH -Force -AllowClobber -Scope CurrentUser"
                        throw "SSH.NET library not found and Posh-SSH module is not available. Cannot use key-based authentication. Error: $($_.Exception.Message)"
                    }
                }
            }
        }
        catch {
            Write-Verbose "Error checking for Posh-SSH module: $($_.Exception.Message)"
        }
    }

    Process {
        try {
            # Step 1: Execute SQL query and get results
            Write-Verbose "Executing SQL query from file: $SqlFilePath"
            
            if ($Force) {
                $queryParams = @{
                    Path = $SqlFilePath
                    As = 'PSObject'
                    QueryTimeout = $QueryTimeout
                    Force = $true
                }
            }
            else {
                $queryParams = @{
                    Path = $SqlFilePath
                    As = 'PSObject'
                    QueryTimeout = $QueryTimeout
                }
            }

            # Execute the SQL query
            $queryTarget = "SQL query from file '$SqlFilePath'"
            if ($PSCmdlet.ShouldProcess($queryTarget, "Execute and export to CSV")) {
                $queryResults = Invoke-SPSAeriesSqlQuery @queryParams
                
                # Check if we got any results
                if ($null -eq $queryResults -or ($queryResults -is [array] -and $queryResults.Count -eq 0)) {
                    Write-Warning "The SQL query returned no results. No CSV file will be created or uploaded."
                    return
                }
                
                # Step 2: Export results to CSV/TSV
                Write-Verbose "Exporting query results to $Delimiter-delimited file: $tempCsvPath"
                
                # Set the delimiter based on parameter
                $delimiterChar = if ($Delimiter -eq "Tab") { "`t" } else { "," }
                
                $queryResults | Export-Csv -Path $tempCsvPath -NoTypeInformation -Encoding UTF8 -Delimiter $delimiterChar
                
                if (-not (Test-Path $tempCsvPath)) {
                    throw "Failed to create CSV file at: $tempCsvPath"
                }
                
                # Step 3: Upload CSV to SFTP server
                $uploadTarget = "SFTP server '$SftpHost' as user '$($SftpCredential.UserName)'"
                if ($PSCmdlet.ShouldProcess($uploadTarget, "Upload CSV file")) {
                    # Normalize remote path (ensure it has a trailing slash)
                    if (-not $RemotePath.EndsWith('/') -and -not $RemotePath.EndsWith('\')) {
                        $RemotePath = "$RemotePath/"
                    }
                    
                    $remoteFilePath = "$RemotePath$CsvFileName"
                    Write-Verbose "Uploading CSV to SFTP server: $remoteFilePath"
                    
                    # Use Posh-SSH if available, otherwise use .NET SSH libraries
                    if ($poshSshAvailable) {
                        # Import the module
                        Import-Module Posh-SSH
                        
                        # Create SFTP session
                        $sftpSession = $null
                        
                        if ($SftpKeyFile) {
                            Write-Verbose "Authenticating with SSH key file: $SftpKeyFile"
                            $sftpSession = New-SFTPSession -ComputerName $SftpHost -Port $SftpPort -Credential $SftpCredential -KeyFile $SftpKeyFile -AcceptKey
                        }
                        else {
                            Write-Verbose "Authenticating with PSCredential"
                            $sftpSession = New-SFTPSession -ComputerName $SftpHost -Port $SftpPort -Credential $SftpCredential -AcceptKey
                        }
                        
                        # Upload the file
                        $uploadResult = Set-SFTPItem -SFTPSession $sftpSession -Path $tempCsvPath -Destination $RemotePath -Force
                        
                        # Get the remote file path (combine destination path with filename)
                        $remoteFileName = [System.IO.Path]::GetFileName($tempCsvPath)
                        $remoteFilePath = "$RemotePath/$remoteFileName"
                        if (-not $remoteFilePath.StartsWith('/')) {
                            $remoteFilePath = "/$remoteFilePath"
                        }
                        
                        # Only verify upload if ConfirmSftpUpload is specified
                        if ($ConfirmSftpUpload) {
                            # Get local file timestamp for comparison
                            $localFileInfo = Get-Item -Path $tempCsvPath
                            $localFileTimestamp = $localFileInfo.LastWriteTime
                            
                            # Verify the upload was successful by checking if file exists on server
                            $fileExists = Get-SFTPChildItem -SFTPSession $sftpSession -Path $RemotePath | 
                                          Where-Object { $_.FullName -eq $remoteFilePath -or $_.Name -eq $remoteFileName }
                            
                            if ($fileExists) {
                                # Check if timestamp is recent (within 5 minutes of local file)
                                $remoteTimestamp = $fileExists.LastWriteTime
                                $timeDifference = [Math]::Abs(($remoteTimestamp - $localFileTimestamp).TotalMinutes)
                                
                                if ($timeDifference -lt 5) {
                                    Write-Verbose "File successfully uploaded via Posh-SSH: $remoteFilePath (Timestamp verified)"
                                } else {
                                    Write-Warning "File exists on server but timestamp differs significantly from local file. Remote: $remoteTimestamp, Local: $localFileTimestamp"
                                }
                            } else {
                                Write-Warning "Upload verification failed - could not find file on SFTP server"
                            }
                        } else {
                            Write-Verbose "File successfully uploaded via Posh-SSH: $remoteFilePath (Upload verification skipped)"
                        }
                        
                        # Clean up the session
                        Remove-SFTPSession -SFTPSession $sftpSession | Out-Null
                    }
                    else {
                        # Use .NET SSH libraries
                        Add-Type -AssemblyName System.Security
                        
                        # Load SSH.NET library if available, otherwise use built-in .NET functionality
                        try {
                            # Try to use SSH.NET via reflection (assuming it's installed)
                            $sshNetAssembly = [System.Reflection.Assembly]::LoadWithPartialName("Renci.SshNet")
                            if ($sshNetAssembly) {
                                Write-Verbose "Using SSH.NET library for SFTP operations"
                                
                                # Create connection info
                                $connectionInfo = $null
                                
                                if ($SftpKeyFile) {
                                    $privateKeyFile = New-Object Renci.SshNet.PrivateKeyFile($SftpKeyFile)
                                    $connectionInfo = New-Object Renci.SshNet.ConnectionInfo($SftpHost, $SftpPort, $SftpCredential.UserName, [Renci.SshNet.AuthenticationMethod[]]@(New-Object Renci.SshNet.PrivateKeyAuthenticationMethod($SftpCredential.UserName, $privateKeyFile)))
                                }
                                else {
                                    # Get the password from the credential
                                    $credPassword = $SftpCredential.GetNetworkCredential().Password
                                    $connectionInfo = New-Object Renci.SshNet.ConnectionInfo($SftpHost, $SftpPort, $SftpCredential.UserName, [Renci.SshNet.AuthenticationMethod[]]@(New-Object Renci.SshNet.PasswordAuthenticationMethod($SftpCredential.UserName, $credPassword)))
                                }
                                
                                # Create SFTP client and upload file
                                $sftpClient = New-Object Renci.SshNet.SftpClient($connectionInfo)
                                $sftpClient.Connect()
                                
                                try {
                                    # Ensure remote directory exists
                                    if (-not $sftpClient.Exists($RemotePath)) {
                                        Write-Verbose "Remote directory does not exist. Attempting to create: $RemotePath"
                                        $sftpClient.CreateDirectory($RemotePath)
                                    }
                                    
                                    # Upload file
                                    $fileStream = [System.IO.File]::OpenRead($tempCsvPath)
                                    $sftpClient.UploadFile($fileStream, $remoteFilePath, $true)
                                    $fileStream.Close()
                                }
                                finally {
                                    $sftpClient.Disconnect()
                                    $sftpClient.Dispose()
                                }
                            }
                            else {
                                throw "SSH.NET library not found and Posh-SSH module is not available. Cannot perform SFTP operations."
                            }
                        }
                        catch {
                            throw "Failed to upload file to SFTP server: $($_.Exception.Message)"
                        }
                    }
                    
                    Write-Verbose "Successfully uploaded CSV file to SFTP server"
                    
                    # Return a custom object with upload results instead of Write-Output
                    [PSCustomObject]@{
                        Success = $true
                        Host = $SftpHost
                        RemoteFile = $remoteFilePath
                        LocalFile = $tempCsvPath
                        UploadTime = [DateTime]::Now
                    }
                    
                    # Step 4: Delete temporary CSV file if requested
                    if ($DeleteAfterUpload) {
                        Write-Verbose "Deleting temporary CSV file: $tempCsvPath"
                        Remove-Item -Path $tempCsvPath -Force
                    }
                }
            }
        }
        catch {
            $errorMessage = "An error occurred: $($_.Exception.Message)"
            if ($_.Exception.InnerException) {
                $errorMessage += "`nInner Exception: $($_.Exception.InnerException.Message)"
            }
            Write-Error $errorMessage -ErrorAction Stop
        }
    }

    End {
        Write-Verbose "Ending $($MyInvocation.InvocationName)"
    }
}
