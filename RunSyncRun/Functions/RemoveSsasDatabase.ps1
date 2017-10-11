Function Remove-SsasDatabase {
    param 
    (
        $ssasServer,
        $ssasDatabase
    )
    $exists = Test-DatabaseExists -ssasServer $ssasServer -ssasDatabase $ssasDatabase
    if ($null -ne $exists) {
        try {
            Write-Verbose "Removing $($ssasDatabase)." -Verbose
            $ssasDatabase.Drop()
        }
        catch {
            throw $_.Exception
        }
    }
    else {
        return
    }

}