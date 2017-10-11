Function Restore-ConnectionString {
    param(
        $ssasServer,
        $ssasDatabase,
        $DataSourceName,
        $ConnectionString
    )
    $exists = Test-DatabaseExists -ssasServer $ssasServer -ssasDatabase $ssasDatabase
    if ($null -ne $exists) {
        $DataSource = $exists.DataSources.FindByName($DataSourceName)
        if ($null -ne $ConnectionString) {
            try {
                $DataSource.ConnectionString = $ConnectionString
                $DataSource.Update()
                Write-Verbose "$(Get-Date): datasource updated for $exists to $ConnectionString" -Verbose
            }
            catch {
                throw $_.Exception
            }
        }
    }
    else {
        Write-Verbose "ConnectionString is null. Not updated." -Verbose
    }
}