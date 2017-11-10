
Function Get-SsasDatabase {
    param (
        $ssasServer,
        $SsasDatabase
    )
    [Microsoft.AnalysisServices.Database[]] $ssasdb = @()
    if (!$SsasDatabase) {
        $ssasdb = $ssasServer.Databases
        $msg = "Returning all SSAS databases."
    }
    else {
        $ssasdb = Test-DatabaseExists -ssasServer $ssasServer -ssasDatabase $SsasDatabase
        $msg = "Returning database $ssasDb from $ssasServer." 
    }
    if (!$ssasdb) {
        Write-Error "database not found."
        Throw
    }
    else {
        Write-Verbose $msg -Verbose
        return $ssasdb
    }
    
}