Function Test-DatabaseExists {
    param (
        $ssasServer,
        $ssasDatabase
    )
    $ssasDb = $ssasServer.Databases.FindByName($ssasDatabase)
    if (! $ssasDb) {
        Write-Verbose "No database called $ssasDatabase exists on $ssasServer" -Verbose
        return $null    
    }
    else {
        return $ssasDb
    }
}