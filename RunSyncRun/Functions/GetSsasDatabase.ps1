
Function Get-SsasDatabase {
    param (
        $ssasServer,
        $SsasDatabase
    )
    [Microsoft.AnalysisServices.Database[]] $ssasdb = @()
    if (!$asdatabase) {
        $ssasdb = $ssasServer.Databases
    }
    else {
        $ssasdb = Test-DatabaseExists -ssasServer $ssasServer -ssasDatabase $SsasDatabase
    }
    return $ssasdb
}