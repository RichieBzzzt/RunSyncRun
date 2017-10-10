Function Connect-SsasServer {
    param
    (
        $SsasServer
    )
    $s = new-Object Microsoft.AnalysisServices.Server
    try {
        $s.Connect($ssasServer)
        return $s
    }
    catch {
        throw $_.Exception
    }
}