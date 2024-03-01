# I think this is deprecated, as  API calls should be made using the AeriesAPI module.
# If the AeriesApi module is lacking endpoints, then the AeriesApi module should be updated to support those.

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