Function Get-ConnectionString {
    param (
        $ssasServer,
        $ssasDatabase,
        $DataSourceName
    )
    try {
        $DataSource = $ssasDatabase.DataSources.FindByName($DataSourceName)
        $ConnectionString = $DataSource.ConnectionString
        return $ConnectionString
    }
    catch {
        throw $_.Exception
    }
}