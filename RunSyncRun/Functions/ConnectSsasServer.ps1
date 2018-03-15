Function Connect-SsasServer {
    param
    (
        $SsasServer
    )
    $s = New-Object Microsoft.AnalysisServices.Server
    try {
        $s.Connect($ssasServer)
        Write-Verbose "Successfully connected to $ssasServer" -Verbose
        return $s
    }
    catch {
        throw $_.Exception
    }
}