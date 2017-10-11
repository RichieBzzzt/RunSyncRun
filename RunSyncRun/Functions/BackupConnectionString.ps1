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
            return $ConnectionString
        }
        catch {
            throw $_.Exception
        }
    }
    else {
        return
    }
}