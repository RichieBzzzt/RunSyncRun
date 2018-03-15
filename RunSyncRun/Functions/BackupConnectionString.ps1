Function Backup-ConnectionString {
    param (
        $ssasServer,
        $ssasDatabase,
        $DataSourceName
    )
    $exists = Test-DatabaseExists -ssasServer $ssasServer -ssasDatabase $ssasDatabase
    if ($null -ne $exists) {
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
    else {
        return
    }
}