Function Restore-ConnectionString {
    param(
        $ssasInstance,
        $ssasDatabase,
        $DataSourceName,
        $ConnectionString
    )
    $newTargetSvr = Connect-SsasServer -SsasServer $ssasInstance
    $newTargetDB = Get-SsasDatabase -ssasServer $newTargetSvr -SsasDatabase $ssasDatabase
    $tds = $newTargetDB.DataSources.FindByName($DataSourceName)
    $tds.ConnectionString = $ConnectionString
    try{
    $tds.Update()
    }
    catch{
        throw $_.Exception
    }
    Write-Verbose "$(Get-Date):      datasource updated for $newtargetdb to $ConnectionString" -Verbose
}