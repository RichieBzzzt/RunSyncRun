Function Remove-SsasDatabase {
    param 
    (
        $ssasServer,
        $ssasDatabase
    )
    $exists = Test-DatabaseExists -ssasServer $ssasServer -ssasDatabase $ssasDatabase
    if ($null -ne $exists) {
        try {
            Write-Verbose "$(Get-Date): Dropping $($ssasDatabase)." -Verbose
            $ssasDatabase.Drop()
            Write-Verbose "$(Get-Date): $($ssasDatabase) dropped." -Verbose
        }
        catch {
            throw $_.Exception
        }
    }
    else {
        return
    }

}