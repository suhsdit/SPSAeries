Function Connect-AeriesAPI {
    try {
        Write-Verbose "Using Config: $Config"
        # URL to access Aeries API
        $script:APIURL = $Config.APIURL
        Write-Verbose "APIURL: $APIURL"
    
        #Headers for Aeries API
        $script:headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $script:headers.Add('AERIES-CERT', $APIKey.GetNetworkCredential().Password)
        $script:headers.Add('accept', 'application/json')
    }
    catch {
        Write-Error -Message "$_ went wrong."
    }
    
    
}