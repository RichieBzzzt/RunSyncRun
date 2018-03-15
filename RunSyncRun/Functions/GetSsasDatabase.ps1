
Function Get-SsasDatabase {
    <#
        .SYNOPSIS
            Get one or more or all of the databases that are on the instance passed in and return them
        
        .DESCRIPTION
            Use this function to return the database(s) that we are syncing. We then loop through these to sync.
        
        .PARAMETER ssasServer
            The connection to the Analysis Services. Created from "Connect-SsasServer"
        
        .PARAMETER ssasDatabase
            A name(s) of a database that exists on the server. If not included then will grab all ssas databases

        .PARAMETER actionOnError
            Pass in ErrorActionPreference. This is because we exeucte this function when getting the target database to backup the connection string. If however database doesn't ecxist the nwe can just continue.
        
        .NOTES
            Internal function.

        .EXAMPLE
            $db = Get-ssasDatabase -ssasServer $sourcesvr -SsasDatabase $database
        
        .EXAMPLE
            $targetSsasDatabase = Get-ssasDatabase -ssasServer $targetsvr -ssasDatabase $database -ActionOnError "Continue"
    #>
    param (
        $ssasServer,
        $SsasDatabase,
        $actionOnError
    )
    $ErrorActionPreference = $actionOnError
    [Microsoft.AnalysisServices.Database[]] $ssasdb = @()
    if (!$SsasDatabase) {
        $ssasdb = $ssasServer.Databases
        $msg = "Returning all SSAS databases."
    }
    else {
        foreach ($asd in $SsasDatabase) {
            $db += $ssasServer.Databases.FindByName($asd)
            if (!$db) {
                Write-Warning "No database called $asd exists on $ssasServer"
            }
            else {
                $ssasDb += $db
            }
            $msg = "Databases $($ssasDb.Name) returned"
        }
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










