Function Restore-ConnectionString {
    param(
        $ssasServer,
        $ssasDatabase,
        $DataSourceName,
        $ConnectionString
    )
    $DataSource = $exists.DataSources.FindByName($DataSourceName)
    if ($null -ne $ConnectionString) {
        try {
            $DataSource.ConnectionString = $ConnectionString
            $DataSource.Update() | Out-Null
            Write-Verbose "$(Get-Date): datasource updated for $exists to $ConnectionString" -Verbose
        }
        catch {
            throw $_.Exception
        }
    }
}