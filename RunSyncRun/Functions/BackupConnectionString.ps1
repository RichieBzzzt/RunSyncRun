Function Backup-ConnectionString {
    param (
        $ssasServer,
        $ssasDatabase,
        $DataSourceName
    )
    try {
        $DataSource = $ssasDatabase.DataSources.FindByName($DataSourceName)
        $ConnectionString = $DataSource.ConnectionString
        Write-Verbose "Connection string $connectionString for $($dataSource.Name) found!" -Verbose 
        return $ConnectionString
    }
    catch {
        Write-Error "Connection string not found for $DataSourceName"
        throw $_.Exception
    }
}