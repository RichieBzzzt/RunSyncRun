Function Set-SyncRole {
    param (
        $SsasDatabase,
        $syncRole
    )
    $role = $null
    $role = $SsasDatabase.Roles.FindByName($syncRole)
    if ($role -eq $null) {
        $roleToCreate = new-Object([Microsoft.AnalysisServices.Role])($syncRole)
        $SsasDatabase.Roles.Add($roleToCreate)
        $roleToCreate.Update()
        Write-Verbose "$(Get-Date): role $syncRole created on $SsasDatabase" -Verbose  
    }  
    else{
        Write-Verbose "$(Get-Date): role $syncRole already exists on $SsasDatabase" -Verbose
    }
}